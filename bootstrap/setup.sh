#!/bin/bash
set -e

AWS_REGION="us-east-2"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="it-tools-terraform-state-${AWS_ACCOUNT_ID}"
PROJECT_NAME="it-tools"

echo "Setting up bootstrap infrastructure..."
echo "Account ID: $AWS_ACCOUNT_ID"
echo "Region: $AWS_REGION"
echo "Bucket: $BUCKET_NAME"

# Create S3 bucket for Terraform state
echo "Creating S3 state bucket..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$AWS_REGION" \
  --create-bucket-configuration LocationConstraint="$AWS_REGION" 2>/dev/null || echo "S3 bucket already exists"

# Enable versioning on S3 bucket
echo "Enabling versioning..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Enable S3 native state locking
echo "Enabling S3 native locking..."
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

# Block public access
echo "Blocking public access..."
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Create ECR repository
echo "Creating ECR repository..."
aws ecr create-repository \
  --repository-name "$PROJECT_NAME" \
  --image-tag-mutability IMMUTABLE \
  --region "$AWS_REGION" 2>/dev/null || echo "ECR repository already exists"

# Create OIDC provider for GitHub Actions
echo "Creating OIDC provider..."
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 2>/dev/null || echo "OIDC provider already exists"

# Create IAM role for GitHub Actions
echo "Creating IAM role..."
aws iam create-role \
  --role-name github-actions-role \
  --assume-role-policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [{
      \"Effect\": \"Allow\",
      \"Principal\": {
        \"Federated\": \"arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com\"
      },
      \"Action\": \"sts:AssumeRoleWithWebIdentity\",
      \"Condition\": {
        \"StringLike\": {
          \"token.actions.githubusercontent.com:sub\": \"repo:abdijalilimam/it-tools-ecs:*\"
        }
      }
    }]
  }" 2>/dev/null || echo "IAM role already exists"

# Attach policies to IAM role
echo "Attaching policies..."
aws iam attach-role-policy \
  --role-name github-actions-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess

aws iam attach-role-policy \
  --role-name github-actions-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo ""
echo "Bootstrap complete!"
echo "S3 Bucket: $BUCKET_NAME"
echo "IAM Role ARN: arn:aws:iam::${AWS_ACCOUNT_ID}:role/github-actions-role"
echo ""
echo "Add this to GitHub Secrets:"
echo "AWS_ROLE_ARN = arn:aws:iam::${AWS_ACCOUNT_ID}:role/github-actions-role"
echo "AWS_ACCOUNT_ID = ${AWS_ACCOUNT_ID}"