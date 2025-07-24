# Automation Repository

This repository contains PowerShell scripts to support various automation processes, including CI/CD workflows, deployments, and environment management. The scripts are designed to be modular and reusable, helping to streamline repetitive tasks.

## Getting Started

To use these scripts in your your Azure Pipelines.
Reference the desired templates in your `azure-pipelines.yml`:
   ```yaml
        resources:
        repositories:
        - repository: automation
            type: git
            name: DatabaseDevOpsPrecon/Automation

# start the script

        - task: PowerShell@1
        displayName: 'PowerShell ScriptName.ps1'
        inputs:
            scriptName: '$(agent.builddirectory)\s\automation\.automation\ScriptName\ScriptName.ps1'
        continueOnError: true

# copy the scripts 

        - task: CopyFiles@2
            inputs:
                SourceFolder: '$(agent.builddirectory)\s\automation'
                Contents: |
                **\.automation\**
                **\.nuget\**
                TargetFolder: '$(Build.ArtifactStagingDirectory)'
                OverWrite: true

   ```

