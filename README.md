# 🛡️ Code-Keeper: Automated CI/CD & Infrastructure for Microservices

Code-Keeper is a complete DevOps automation project built on top of the **code-keeper** microservices architecture. It automates the provisioning, testing, scanning, containerizing, and zero-downtime deployment of microservices and cloud infrastructure using a self-hosted **GitLab CE** instance and **GitLab Runners** deployed via **Ansible**.

---

## 📑 Table of Contents
- [Architecture Overview](#-architecture-overview)
- [Project Structure & Repositories](#-project-structure--repositories)
- [Ansible Automation (GitLab & Runner)](#-ansible-automation-gitlab--runner)
- [CI/CD Pipelines Design](#-cicd-pipelines-design)
  - [1. Infrastructure Pipeline (Terraform)](#1-infrastructure-pipeline-terraform)
  - [2. Microservices CI/CD Pipelines](#2-microservices-cicd-pipelines)
- [Cybersecurity & Best Practices](#-cybersecurity--best-practices)
- [Prerequisites & Setup Guide](#-prerequisites--setup-guide)
- [Role-Play Audit Q&A Defense Guide](#-role-play-audit-qa-defense-guide)

---

## 🏗️ Architecture Overview

```mermaid
---
config:
  layout: elk
---
graph TD
    A[Developer Git Push] --> B[Self-Hosted GitLab CE Server<br/>192.168.56.20<br/>Provisioned via Ansible]
    B --> C[GitLab Runner<br/>Docker / Privileged Executor]
    C --> D[Infrastructure Pipeline<br/>apps/terraform]
    C --> E[Microservices Pipelines]
    
    D --> D1["1. Init<br/>terraform init"]
    D1 --> D2["2. Validate<br/>syntax check"]
    D2 --> D3["3. Plan<br/>generate tfplan"]
    D3 --> D4["4. Apply to Staging"]
    D4 --> D5["5. Approval<br/>Manual Gate"]
    D5 --> D6["6. Apply to Production"]
    
    E --> E1["App: api-gateway"]
    E --> E2["App: inventory"]
    E --> E3["App: billing"]
    
    E1 --> E1a["1. Build<br/>compileall"]
    E1a --> E1b["2. Test<br/>pytest"]
    E1b --> E1c["3. Scan<br/>Bandit SAST"]
    E1c --> E1d["4. Containerize<br/>Docker"]
    E1d --> E1e["5. Deploy to Staging"]
    E1e --> E1f["6. Approval<br/>Manual Gate"]
    E1f --> E1g["7. Deploy to Production"]
    
    E2 --> E2a["1. Build<br/>compileall"]
    E2a --> E2b["2. Test<br/>pytest"]
    E2b --> E2c["3. Scan<br/>Bandit SAST"]
    E2c --> E2d["4. Containerize<br/>Docker"]
    E2d --> E2e["5. Deploy to Staging"]
    E2e --> E2f["6. Approval<br/>Manual Gate"]
    E2f --> E2g["7. Deploy to Production"]
    
    E3 --> E3a["1. Build<br/>compileall"]
    E3a --> E3b["2. Test<br/>pytest"]
    E3b --> E3c["3. Scan<br/>Bandit SAST"]
    E3c --> E3d["4. Containerize<br/>Docker"]
    E3d --> E3e["5. Deploy to Staging"]
    E3e --> E3f["6. Approval<br/>Manual Gate"]
    E3f --> E3g["7. Deploy to Production"]
    
    D6 --> F[Target Cloud Platform]
    E1g --> F
    E2g --> F
    E3g --> F
    
    F --> F1["Staging Environment"]
    F --> F2["Production Environment"]
    
    classDef trigger stroke:#fb7185,fill:#fff1f2, color:#000000
    classDef server stroke:#818cf8,fill:#eef2ff, color:#000000
    classDef runner stroke:#2dd4bf,fill:#f0fdfa, color:#000000
    classDef infraPipe stroke:#a78bfa,fill:#f5f3ff, color:#000000
    classDef microPipe stroke:#fb923c,fill:#fff7ed, color:#000000
    classDef infraStage stroke:#a78bfa,fill:#f5f3ff, color:#000000
    classDef microStage stroke:#fb923c,fill:#fff7ed, color:#000000
    classDef target stroke:#4ade80,fill:#f0fdf4, color:#000000
    classDef env stroke:#facc15,fill:#fefce8, color:#000000
    
    class A trigger
    class B server
    class C runner
    class D infraPipe
    class E microPipe
    class D1,D2,D3,D4,D5,D6 infraStage
    class E1,E2,E3 microPipe
    class E1a,E1b,E1c,E1d,E1e,E1f,E1g microStage
    class E2a,E2b,E2c,E2d,E2e,E2f,E2g microStage
    class E3a,E3b,E3c,E3d,E3e,E3f,E3g microStage
    class F target
    class F1,F2 env
```
---

## 📦 Project Structure & Repositories

The project separates concerns into **4 independent Git repositories** hosted on the local GitLab instance under the `code-keeper` group:

1. **`code-keeper / terraform`**: Infrastructure as Code (AWS ECS, VPC, RDS, ALB, RabbitMQ).
2. **`code-keeper / api-gateway`**: Entrypoint reverse proxy and HTTP-to-queue routing microservice.
3. **`code-keeper / inventory`**: Movie inventory catalog service connected to PostgreSQL.
4. **`code-keeper / billing`**: Order processing service consuming RabbitMQ queue events.

---

## 🤖 Ansible Automation (GitLab & Runner)

Both GitLab CE and the GitLab Runner are automated using Ansible roles:

* **GitLab Role (`ansible/roles/gitlab`)**:
  * Installs prerequisite packages (`curl`, `ca-certificates`, `tzdata`, `perl`).
  * Downloads and executes the official GitLab repository script.
  * Installs `gitlab-ce`.
  * Deploys optimized `/etc/gitlab/gitlab.rb` (Puma single-process mode, reduced sidekiq concurrency, PostgreSQL shared memory tuned for 4GB VM).
  * Automatically executes `gitlab-ctl reconfigure` and polls until the web UI returns HTTP 200.
* **Runner Role (`ansible/roles/runner`)**:
  * Installs `docker.io` and `gitlab-runner`.
  * Configures the `gitlab-runner` system user in the `docker` group.
  * Sets runner concurrency to 4 and enables privileged execution for Docker-in-Docker.

---

## 🚀 CI/CD Pipelines Design

### 1. Infrastructure Pipeline (`terraform`)
* **`Init`**: Downloads HashiCorp AWS and Random provider plugins.
* **`Validate`**: Validates syntax, HCL structure, and certificate references.
* **`Plan`**: Generates execution plan artifact (`tfplan`).
* **`Apply to Staging`**: Automatically applies changes to the Staging environment.
* **`Approval`**: Manual approval gate (`when: manual`) requiring stakeholder sign-off.
* **`Apply to Production`**: Applies the reviewed plan to the Production environment.

### 2. Microservices CI/CD Pipelines (`api-gateway`, `inventory`, `billing`)
* **`Build`**: Validates bytecode compilation (`python -m compileall app/`).
* **`Test`**: Executes automated unit test suite using `python -m pytest -v` with in-memory database mocks.
* **`Scan`**: Analyzes Python source code for security vulnerabilities and dangerous patterns using **Bandit** SAST (`bandit -r app/ -ll -i`).
* **`Containerize`**: Builds container images using `docker build -t <app>:latest .` via Docker-in-Docker service.
* **`Deploy to Staging`**: Deploys the container to the Staging environment with automated health checks.
* **`Approval`**: Enforces a strict manual approval gate (`when: manual`) before touching production.
* **`Deploy to Production`**: Executes a zero-downtime rolling update to the live Production environment.

---

## 🔒 Cybersecurity & Best Practices

In accordance with project security guidelines:
1. **Protected Branches**: Pipelines and production deployments only trigger from the protected `main` branch.
2. **Separation of Secrets from Code**: Zero hardcoded credentials. AWS keys (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`) are stored as **Masked Variables** in GitLab CI/CD settings.
3. **Least Privilege & Access Control**: Public sign-ups are disabled (`Allow new user accounts = false`), preventing unauthorized registration.
4. **Automated Security Scanning**: Every code commit is scanned by Bandit before any container is built or deployed.

---

## 🛠️ Prerequisites & Setup Guide

### 1. Booting the GitLab VM
```bash
vagrant up gitlab
```

### 2. Configure google DNS
```bash
vagrant ssh gitlab
sudo resolvectl dns enp0s3 8.8.8.8 1.1.1.1
sudo resolvectl flush-caches
# Prioritize IPv4 over IPv6 in /etc/gai.conf
sudo sed -i 's/#precedence ::ffff:0:0\/96 100/precedence ::ffff:0:0\/96 100/' /etc/gai.conf
exit
```

### 3. Running Ansible Provisioning
```bash
cd ansible
export ANSIBLE_CONFIG=./ansible.cfg
ansible-playbook playbooks/deploy_gitlab.yml
ansible-playbook playbooks/deploy_runner.yml
```

### 4. Accessing GitLab

- **URL**: http://192.168.56.20
- **Username**: root
- **Password**: StrongPassword!


---
