terraform {
  required_providers {
    nirvana = {
      source = "nirvana-labs/nirvana"
    }
  }
}

provider "nirvana" {}

# VPC for PostgreSQL
resource "nirvana_networking_vpc" "postgres" {
  name        = var.vpc_name
  region      = var.region
  project_id  = var.project_id
  subnet_name = var.subnet_name
  tags        = var.tags
}

# Firewall rule - SSH access
resource "nirvana_networking_firewall_rule" "postgres_ssh" {
  vpc_id              = nirvana_networking_vpc.postgres.id
  name                = "postgres-ssh"
  protocol            = "tcp"
  source_address      = var.ssh_allowed_cidr
  destination_address = nirvana_networking_vpc.postgres.subnet.cidr
  destination_ports   = ["22"]
  tags                = var.tags
}

# Firewall rule - PostgreSQL access
resource "nirvana_networking_firewall_rule" "postgres_db" {
  vpc_id              = nirvana_networking_vpc.postgres.id
  name                = "postgres-db"
  protocol            = "tcp"
  source_address      = var.postgres_allowed_cidr
  destination_address = nirvana_networking_vpc.postgres.subnet.cidr
  destination_ports   = [tostring(var.postgres_port)]
  tags                = var.tags
}

# PostgreSQL VM
resource "nirvana_compute_vm" "postgres" {
  name              = var.vm_name
  project_id        = var.project_id
  region            = var.region
  os_image_name     = var.os_image
  public_ip_enabled = var.public_ip_enabled
  subnet_id         = nirvana_networking_vpc.postgres.subnet.id

  cpu_config = {
    vcpu = var.vcpu
  }

  memory_config = {
    size = var.memory_gb
  }

  boot_volume = {
    size = var.boot_volume_gb
    type = "abs"
    tags = var.tags
  }

  ssh_key = {
    public_key = var.ssh_public_key
  }

  tags = var.tags
}
