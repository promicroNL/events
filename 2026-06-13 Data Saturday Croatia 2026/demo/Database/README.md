# SQL Simple Schema Model

This repository defines the database schema and uses a separate **Automation**
repository for deployment scripts and configuration. The Azure DevOps pipeline
pulls in the external repository during the build so published artifacts include
the scripts, configuration and database files needed to provision and verify a database.

## Structure

- `pipeline/azure-pipeline.yml`: Azure DevOps pipeline definition which fetches
  the **Automation** repository containing PowerShell scripts and shared
  configuration.
