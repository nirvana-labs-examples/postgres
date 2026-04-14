<div align="center">
  <a href="https://nirvanalabs.io">
    <img src="https://nirvanalabs.io/brand-kit/logo/nirvana-logo-color-black-text.svg" alt="Nirvana Labs" width="320" />
  </a>

  [Sign Up](https://nirvanalabs.io/sign-up) · [Docs](https://docs.nirvanalabs.io) · [API](https://docs.nirvanalabs.io/api) · [Examples](https://github.com/nirvana-labs-examples) · [Terraform](https://registry.terraform.io/providers/nirvana-labs/nirvana/latest) · [TypeScript SDK](https://www.npmjs.com/package/@nirvana-labs/nirvana) · [Go SDK](https://github.com/Nirvana-Labs/nirvana-go) · [CLI](https://github.com/nirvana-labs/nirvana-cli) · [MCP](https://www.npmjs.com/package/@nirvana-labs/nirvana-mcp)
</div>

---

# PostgreSQL on Nirvana Labs

Deploy a production-ready PostgreSQL database on Nirvana Labs cloud infrastructure with optimized configuration.

## Features

- PostgreSQL 16 with latest security patches
- Pre-tuned memory and performance settings
- Remote access with scram-sha-256 authentication
- Automatic database and user creation
- WAL and checkpoint optimization
- Parallel query support enabled

## Structure

```
.
├── terraform/          # Infrastructure provisioning
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/            # PostgreSQL installation & configuration
│   ├── playbook.yml
│   ├── ansible.cfg
│   └── inventory.ini.example
├── scripts/
│   └── generate-inventory.sh
└── README.md
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.9 (for automated method)
- Nirvana Labs account and API key
- SSH key pair

## Resources Created

| Resource | Specification |
|----------|---------------|
| VPC | With subnet in us-sva-2 |
| Firewall | Ports 22 (SSH), 5432 (PostgreSQL) |
| VM | 2 vCPU, 4 GB RAM, 64 GB SSD |

## Quick Start

### 1. Provision Infrastructure

```bash
cd terraform

export NIRVANA_LABS_API_KEY="your-api-key"

terraform init
terraform plan -var='ssh_public_key=ssh-ed25519 AAAA...' -var='project_id=your-project-id'
terraform apply -var='ssh_public_key=ssh-ed25519 AAAA...' -var='project_id=your-project-id'
```

Note the `vm_public_ip` output.

---

### 2. Install PostgreSQL

Choose one of the following methods:

---

#### Option A: Automated (Ansible)

```bash
# Generate inventory from terraform output
cd ..
./scripts/generate-inventory.sh

# Run playbook
cd ansible
ansible-playbook playbook.yml
```

The playbook will:
- Install PostgreSQL 16
- Apply optimized configuration
- Create a database and user
- Display connection credentials

---

#### Option B: Manual Installation

SSH into the VM:

```bash
ssh ubuntu@<vm_public_ip>
```

Install PostgreSQL:

```bash
# Add PostgreSQL repository
sudo apt update
sudo apt install -y gnupg wget lsb-release
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /usr/share/keyrings/postgresql-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" | sudo tee /etc/apt/sources.list.d/postgresql.list

# Install PostgreSQL 16
sudo apt update
sudo apt install -y postgresql-16 postgresql-contrib-16
```

Configure remote access:

```bash
# Edit postgresql.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf

# Add to pg_hba.conf
echo "host all all 0.0.0.0/0 scram-sha-256" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf

# Restart PostgreSQL
sudo systemctl restart postgresql
```

Create database and user:

```bash
sudo -u postgres psql << EOF
CREATE USER appuser WITH PASSWORD 'your-secure-password';
CREATE DATABASE appdb OWNER appuser;
GRANT ALL PRIVILEGES ON DATABASE appdb TO appuser;
EOF
```

---

### 3. Connect to PostgreSQL

Using psql:

```bash
psql -h <vm_public_ip> -p 5432 -U appuser -d appdb
```

Connection string:

```
postgresql://appuser:password@<vm_public_ip>:5432/appdb
```

## Terraform Variables

| Name | Description | Default |
|------|-------------|---------|
| `project_id` | Nirvana Labs project ID | - |
| `region` | Deployment region | `us-sva-2` |
| `vm_name` | VM name | `postgres` |
| `vcpu` | Number of vCPUs | `2` |
| `memory_gb` | Memory in GB | `4` |
| `boot_volume_gb` | Boot volume in GB (min 64) | `64` |
| `ssh_public_key` | SSH public key | - |
| `postgres_port` | PostgreSQL port | `5432` |
| `postgres_allowed_cidr` | CIDR allowed for PostgreSQL access | `0.0.0.0/0` |
| `ssh_allowed_cidr` | CIDR allowed for SSH access | `0.0.0.0/0` |

## Outputs

| Name | Description |
|------|-------------|
| `vm_id` | PostgreSQL VM ID |
| `vm_public_ip` | PostgreSQL VM public IP |
| `vm_private_ip` | PostgreSQL VM private IP |
| `vpc_id` | VPC ID |
| `postgres_port` | PostgreSQL port |
| `connection_string` | Connection string template |

## PostgreSQL Configuration

The Ansible playbook applies these optimized settings:

### Memory Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| `shared_buffers` | 1GB | Shared memory for caching |
| `effective_cache_size` | 3GB | Planner's assumption of available cache |
| `work_mem` | 16MB | Memory per operation (sort, hash) |
| `maintenance_work_mem` | 256MB | Memory for maintenance operations |

### WAL Settings

| Parameter | Default | Description |
|-----------|---------|-------------|
| `wal_buffers` | 64MB | WAL buffer size |
| `min_wal_size` | 1GB | Minimum WAL size |
| `max_wal_size` | 4GB | Maximum WAL size |
| `checkpoint_completion_target` | 0.9 | Checkpoint spread |

### Parallel Query

| Parameter | Default | Description |
|-----------|---------|-------------|
| `max_worker_processes` | 4 | Maximum background workers |
| `max_parallel_workers_per_gather` | 2 | Workers per parallel query |
| `max_parallel_workers` | 4 | Maximum parallel workers |

### Logging

| Parameter | Default | Description |
|-----------|---------|-------------|
| `log_statement` | ddl | Log DDL statements |
| `log_min_duration_statement` | 1000ms | Log slow queries |

## Customizing Configuration

Override Ansible variables when running the playbook:

```bash
ansible-playbook playbook.yml \
  -e "postgres_max_connections=200" \
  -e "postgres_shared_buffers=2GB" \
  -e "postgres_db=myapp" \
  -e "postgres_user=myuser"
```

## Security Recommendations

1. **Restrict access**: Set `postgres_allowed_cidr` to your application's IP range
2. **Use strong passwords**: The playbook generates a 24-character random password
3. **Enable SSL**: For production, configure SSL certificates
4. **Regular backups**: Set up pg_dump or WAL archiving

## Backup and Restore

### Create backup

```bash
ssh ubuntu@<vm_public_ip>
sudo -u postgres pg_dump appdb > backup.sql
```

### Restore backup

```bash
sudo -u postgres psql appdb < backup.sql
```

## Clean Up

```bash
cd terraform
terraform destroy -var='ssh_public_key=...' -var='project_id=...'
```
