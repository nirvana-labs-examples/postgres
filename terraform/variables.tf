variable "project_id" {
  description = "Nirvana Labs project ID"
  type        = string
}

variable "region" {
  description = "Region to deploy resources"
  type        = string
  default     = "us-sva-2"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "postgres-vpc"
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "postgres-subnet"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "postgres"
}

variable "vcpu" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "memory_gb" {
  description = "Memory size in GB"
  type        = number
  default     = 4
}

variable "boot_volume_gb" {
  description = "Boot volume size in GB (min 64 for ABS)"
  type        = number
  default     = 64
}

variable "os_image" {
  description = "OS image name"
  type        = string
  default     = "ubuntu-noble-2025-10-01"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}

variable "public_ip_enabled" {
  description = "Enable public IP for the VM"
  type        = bool
  default     = true
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "postgres_allowed_cidr" {
  description = "CIDR allowed for PostgreSQL access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "postgres_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = list(string)
  default     = ["postgres", "terraform"]
}
