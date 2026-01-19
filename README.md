# Serverless CI/CD Pipeline with Terraform

## Overview
This project implements a production-grade CI/CD pipeline for a serverless API using AWS Lambda and API Gateway.  
All infrastructure is managed using Terraform across **dev**, **staging**, and **prod** environments, with a **blue/green deployment strategy** for production.

## Architecture
- AWS Lambda (Python 3.11)
- Amazon API Gateway (REST API)
- Terraform (Infrastructure as Code)
- GitHub Actions (CI/CD)
- AWS CloudWatch (logs & alarms)
- API Gateway API Key for security

## Environments
- **Dev**: Auto-deployed on feature branch pushes
- **Staging**: Manual approval required
- **Prod**: Blue/Green deployment using Lambda aliases

## Blue/Green Deployment (Production)
Production uses Lambda **versions and aliases**.
- A new version is published on each deploy
- The `green` alias points to the active version
- API Gateway invokes the alias (not `$LATEST`)
- Zero downtime during updates

## CI/CD Pipeline
GitHub Actions workflow:
1. Deploys **dev** automatically on feature branches
2. Requires manual approval for **staging**
3. Deploys **prod** from `main` branch

Workflow file:
