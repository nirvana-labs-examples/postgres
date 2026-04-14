output "vm_id" {
  description = "PostgreSQL VM ID"
  value       = nirvana_compute_vm.postgres.id
}

output "vm_public_ip" {
  description = "PostgreSQL VM public IP"
  value       = nirvana_compute_vm.postgres.public_ip
}

output "vm_private_ip" {
  description = "PostgreSQL VM private IP"
  value       = nirvana_compute_vm.postgres.private_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = nirvana_networking_vpc.postgres.id
}

output "postgres_port" {
  description = "PostgreSQL port"
  value       = var.postgres_port
}

output "connection_string" {
  description = "PostgreSQL connection string template"
  value       = "postgresql://USERNAME:PASSWORD@${nirvana_compute_vm.postgres.public_ip}:${var.postgres_port}/DATABASE"
}
