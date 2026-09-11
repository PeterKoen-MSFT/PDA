using './main.bicep'

// The pipeline overrides webImage, acrName, and deployerPrincipalId on the command line.
// Values here are defaults for manual/local `az deployment group create` runs.

param namePrefix = 'pda'
param webImage = 'mcr.microsoft.com/k8se/quickstart:latest'
param deployOllama = true
param ollamaModel = 'llama3.1'
param ollamaWorkloadProfileType = 'Consumption-GPU-NC8as-T4'
param immutabilityDays = 365
