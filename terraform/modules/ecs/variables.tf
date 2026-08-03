variable "ecs_name" {
  description = "The name of the ecs"
  type        = string
}

variable "vpc_id" {
  description = "The id of the vpc"
  type        = string
}

variable "private_subnet_ids" {
  description = "The private subnet ids"
  type        = list(string)
}

variable "container_image" {
  description = "The container image"
  type        = string
}

variable "cpu" {
  description = "How much cpu"
  type        = string
}

variable "memory" {
  description = "How much memory"
  type        = string
}

variable "desired_count" {
  description = "Number of ECS tasks to run"
  type        = number
  default     = 1
}

variable "target_group_arn" {
  description = "The target group that is in"
  type        = string
}

variable "alb_security_group_id" {
  description = "The id of the security group"
  type        = string
}