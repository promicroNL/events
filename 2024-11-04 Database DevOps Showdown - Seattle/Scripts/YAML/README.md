# YAML Template Repository

This repository contains reusable YAML templates for Azure Pipelines. The templates are designed to streamline CI/CD workflows by providing modular and customizable building blocks for common tasks.

## Getting Started

To use these templates in your Azure Pipelines.
Reference the desired templates in your `azure-pipelines.yml`:
   ```yaml
   resources:
     repositories:
       - repository: templates
         type: git
         name: DatabaseDevOpsShowdown\YAML-Templates

   stages:
     - template: template-name.yml@templates
       parameters:
         param1: value1
         param2: value2
   ```

