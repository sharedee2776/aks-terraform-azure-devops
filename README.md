# Production-Grade AKS Deployment with Terraform & GitHub Actions

This repository demonstrates a **production-ready Azure Kubernetes Service (AKS) deployment** using **Terraform modules**, **remote state management**, and **GitHub Actions CI/CD pipeline**. It is designed for portfolio use, demonstrating DevOps, cloud, and Kubernetes best practices.

---

## Table of Contents

* [Project Overview](#project-overview)
* [Architecture](#architecture)
* [Prerequisites](#prerequisites)
* [Repository Structure](#repository-structure)
* [Terraform Modules](#terraform-modules)
* [Setting up Terraform Backend](#setting-up-terraform-backend)
* [Environment Deployment](#environment-deployment)
* [GitHub Actions CI/CD](#github-actions-cicd)
* [Kubernetes Application Deployment](#kubernetes-application-deployment)
* [Production Considerations](#production-considerations)
* [Troubleshooting](#troubleshooting)
* [Interview Notes](#interview-notes)

---

## Project Overview

This project provisions:

* Azure Resource Group
* Azure Virtual Network (VNet) and Subnet for AKS
* Azure Container Registry (ACR) with admin disabled
* Azure Kubernetes Service (AKS) cluster with system-assigned managed identity
* GitHub Actions CI/CD for infrastructure provisioning
* Kubernetes application deployment example (nginx)

Key principles:

* **Modules** for reusable and scalable infrastructure
* **Remote Terraform state** for team collaboration
* **OIDC authentication** in GitHub Actions to avoid secrets
* **Azure AD / RBAC friendly** design

---

## Architecture

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

## Prerequisites

* Azure account with subscription
* Azure CLI installed and logged in (`az login`)
* Terraform >= 1.6.0
* GitHub account for Actions
* Bash/Linux shell

Optional:

* Azure Cloud Shell
* kubectl installed locally for testing

---

## Repository Structure

```
repo-root/
├── terraform/
│   ├── backend.tf
│   ├── providers.tf
│   ├── versions.tf
│   ├── modules/
│   │   ├── network/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── acr/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── aks/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── envs/
│       └── dev/
│           └── main.tf
├── k8s/
│   └── deployment.yaml
└── .github/workflows/
    └── terraform.yml
```

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

## Kubernetes Application Deployment

Example deployment (`k8s/deployment.yaml`):

* Deploys nginx with 2 replicas
* Connects to AKS cluster
* Can replace `image` with your ACR image

Deploy with kubectl:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl get pods
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

Key points to discuss:

* Why AKS needs its own subnet (network isolation, private clusters)
* Why ACR admin is disabled (use managed identity, no static credentials)
* Why Terraform state is remote (collaboration, locking, safety)
* Why modules exist (reuse, maintainability, enterprise pattern)
* Why GitHub Actions uses OIDC (secure auth, no secrets)
* Explain CI/CD workflow from push → Terraform → AKS → App deployment

---

## Author

Adedamola Dauda – DevOps & Cloud Engineer Portfolio

---

**This project is portfolio-grade and demonstrates a full end-to-end AKS deployment pipeline on Azure with Terraform and GitHub Actions.**
