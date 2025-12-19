# 🚀 Production-Grade Azure AKS Deployment with Terraform & GitHub Actions

This project demonstrates a **full DevOps pipeline** for deploying and managing Azure Kubernetes Service (AKS) infrastructure using **modular Terraform** and **GitHub Actions**. A sample Nginx application is deployed to AKS and made available via a public LoadBalancer IP.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture Diagram](#architecture-diagram)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Setup Guide](#setup-guide)
- [CI/CD Workflow](#cicd-workflow)
- [Application Deployment](#application-deployment)
- [Screenshots](#screenshots)
- [Key Learnings](#key-learnings)
- [Future Improvements](#future-improvements)
- [Author](#author)

---

## Project Overview

This project provisions and demonstrates:

- Azure Resource Group & Storage Account for remote state
- Virtual Network (VNet) & Subnet for AKS
- Azure Container Registry (ACR), admin access disabled
- AKS Cluster using system-assigned managed identity
- Modular Terraform for infrastructure as code
- CI/CD Pipeline using GitHub Actions (OIDC authentication)
- Sample Nginx application running in AKS

---

## Architecture Diagram


```
+------------------+       +-------------------+
|  GitHub Actions  | ----> |  Terraform Apply   |
+------------------+       +-------------------+
                                    |
                                    v
                           +-------------------+
                           | Azure Infrastructure|
                           +-------------------+
                                    |
             +----------------------+--------------------+
             |                      |                    |
         +--------+             +--------+          +--------+
         |  VNet  |             |  ACR   |          |  AKS   |
         +--------+             +--------+          +--------+
                                    |
                                    v
                             Kubernetes App
```

* AKS deployed into its own subnet
* ACR stores container images (no admin credentials)
* Terraform modules separate network, ACR, AKS for clarity and reuse



---

## Features

- Fully automated AKS infrastructure provisioning
- Modular Terraform code for scalability and reuse
- Secure authentication via OIDC (no secrets exposed)
- Remote state for safe team-based collaboration
- Sample application deployed and exposed via LoadBalancer

---

## Tech Stack

- **Azure**: Resource Group, VNet/Subnet, AKS, ACR, Storage Account
- **Terraform**: Modular infrastructure as code
- **GitHub Actions**: CI/CD workflow, OIDC authentication
- **Kubernetes**: Deployment and Service for applications
- **nginx**: Sample web application

---

## Repository Structure

aks-terraform-azure-devops/ ├── .github/ │ └── workflows/ │ └── terraform.yml ├── app/ │ └── Dockerfile ├── k8s/ │ └── deployment.yaml ├── terraform/ │ ├── backend.tf │ ├── providers.tf │ ├── versions.tf │ ├── modules/ │ │ ├── network/ │ │ │ ├── main.tf │ │ │ ├── variables.tf │ │ │ └── outputs.tf │ │ ├── acr/ │ │ │ ├── main.tf │ │ │ ├── variables.tf │ │ │ └── outputs.tf │ │ └── aks/ │ │ ├── main.tf │ │ ├── variables.tf │ │ └── outputs.tf │ └── envs/ │ └── dev/ │ └── main.tf ├── docs/ │ └── screenshots/ ├── README.md └── .gitignore

---

## Prerequisites

- Azure subscription & CLI (`az login`)
- Terraform >= 1.6.0
- GitHub account (Actions enabled)
- kubectl installed for Kubernetes management

---

## Setup Guide

**1. Clone the Repository**

```bash
git clone https://github.com/sharedee2776/aks-terraform-azure-devops.git
cd aks-terraform-azure-devops

---



---

## Terraform Modules

### Network Module

* Creates VNet and subnet for AKS
* Outputs subnet ID for AKS module

### ACR Module

* Creates Azure Container Registry
* Admin disabled for security
* Outputs login server

### AKS Module

* Creates AKS cluster with system-assigned identity
* Node pool attached to VNet subnet
* Outputs kube_config (sensitive)

---

## Setting up Terraform Backend

1. Ensure storage account exists (from previous steps)
2. Create container `tfstate`
3. Configure `terraform/backend.tf`:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateprod1766084184"
    container_name       = "tfstate"
    key                  = "aks-dev.tfstate"
  }
}
```

4. Initialize Terraform:

```bash
cd terraform/envs/dev
terraform init
```

---

## Environment Deployment

1. Apply Terraform plan:

```bash
terraform plan
terraform apply -auto-approve
```

2. Modules are applied in order:

   * Network
   * ACR
   * AKS

3. Verify resources in Azure portal

---

## GitHub Actions CI/CD

Workflow `.github/workflows/terraform.yml`:

* Runs on push to main
* Checks out code
* Logs into Azure using OIDC (`azure/login@v2`)
* Initializes Terraform
* Applies Terraform plan

**Benefits:**

* No secrets stored in repo
* Secure automation
* Enforces remote state usage

---

Application Deployment
Sample Nginx App

bash
# Deploy application
kubectl create deployment demo-app --image=nginx:latest

# Expose app via LoadBalancer
kubectl expose deployment demo-app --port=80 --type=LoadBalancer
Access Your Nginx App

Get the External IP:
bash
kubectl get service demo-app --watch
Visit http://<EXTERNAL-IP> in your browser.
Example (from this project):

Code
EXTERNAL-IP: 9.163.162.100
Open in your browser: http://9.163.162.100


```

---

## Production Considerations

* **Private AKS cluster** for security
* **RBAC + Azure AD integration**
* **Autoscaling node pools**
* **Ingress controller + HTTPS certificates**
* **Monitoring**: Prometheus, Azure Monitor
* **Terraform workspace separation** for dev, staging, prod

---

## Troubleshooting

* `SubscriptionNotFound` → check `az account list`, `az account set`
* Storage container not found → ensure exact account name is used
* Terraform backend errors → verify container exists and `az login` session active

---

## Interview Notes

Key Learnings
Terraform modules, remote state, resource import & troubleshooting
Azure provisioning and secure authentication
Kubernetes deployment & service management
CI/CD automation with GitHub Actions & OIDC
Real-world debugging and state management

---

## Future Improvements

 Add Helm charts for app deployment
 Implement CI/CD for container build and deployment to ACR/AKS
 Private AKS cluster & RBAC with Azure AD
 Monitoring with Azure Monitor or Prometheus
 Ingress controllers, TLS, and advanced networking
 Multi-environment (dev/staging/prod) setup
 Security scanning for containers

---

## Author

Adedamola Dauda
GitHub
Junior DevOps & Cloud Engineer Portfolio


**This project demonstrates end-to-end, enterprise-grade AKS provisioning and application deployment using the latest industry practices for security, automation, and reliability**.

