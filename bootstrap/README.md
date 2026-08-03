# Bootstrap

Run this script once before using the project for the first time.
It creates the important infrastructure that Terraform depends on.

## What it creates
- S3 bucket for Terraform remote state
- ECR repository for Docker images
- IAM OIDC provider for GitHub Actions authentication
- IAM role with required permissions

## How to run
```bash
chmod +x setup.sh
./setup.sh
```

## After running
Add the output values to your GitHub repository secrets:
- `AWS_ROLE_ARN`
- `AWS_ACCOUNT_ID`