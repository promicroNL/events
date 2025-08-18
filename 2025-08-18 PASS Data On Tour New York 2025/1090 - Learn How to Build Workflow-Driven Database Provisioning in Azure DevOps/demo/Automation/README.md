# SQL MI Automation

This repository contains PowerShell scripts and an Azure DevOps pipeline to provision and verify a SQL Managed Instance (SQL MI) database.

## Prerequisites
- PowerShell 7+
- `SqlServer` module for `Invoke-Sqlcmd`
- Set the admin password in the environment variable `SQLMIADMINPASS`

## Structure
- `scripts/`: PowerShell provisioning scripts
- `config/sqlmi-xxx.json`: Shared parameters (resource group, MI FQDN, database name, admin login)
- `config/approver-environment.json`: Approver to Azure DevOps environment mapping

## Usage
1. `01-precheck.ps1` – Validate configuration, credentials and required modules
2. `02-create-db.ps1` – Create or unstash a database, tagging it with the current build number
3. `03-apply-sql.ps1` – Run ordered `.sql` migration files in `../database`
4. `04-verify.ps1` – Run a verification query and fail if no rows are returned
5. `05-stash.ps1` – Rename the database to include the build number
6. `06-resolve-approver-env.ps1` – Map the approver of a manual validation step to an environment
7. `07-cleanup-stash.ps1` – Remove stashed databases whose builds have completed successfully

Ensure credentials and other secrets are supplied via environment variables or secure variables in the pipeline and **not** committed to source control.
