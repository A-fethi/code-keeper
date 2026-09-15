# 📘 Mastering Ansible: Fundamentals, Theory & Code-Keeper Implementation

---

## 1. What is Ansible and What is Its Job?

### What is Ansible?
**Ansible** is an open-source **Configuration Management (CM)**, **Infrastructure Orchestration**, and **Application Deployment** tool originally created by Michael DeHaan and acquired by Red Hat. 

### What is its Job?
In modern DevOps, Ansible's mission is to transition systems from their current state into a **desired state** automatically, repeatably, and reliably.

| Problem Without Ansible (Manual / Shell Scripts) | Solution With Ansible |
| :--- | :--- |
| **Snowflake Servers**: Every server configured slightly differently. | **Infrastructure as Code (IaC)**: System configuration is codified in Git. |
| **Shell Scripts Break on Reruns**: Running `mkdir foo` or `useradd` twice throws errors unless heavily scripted with `if/else`. | **Idempotency**: Runs can be repeated safely; Ansible only applies changes if drift has occurred. |
| **Heavy Agent Overhead**: Software like Puppet or Chef requires installing daemon agents, certificates, and opened ports on every VM. | **Agentless**: Operates purely over standard SSH using existing Python interpreters on the target. |

---

## 2. How Ansible Works Under the Hood

```
+-------------------------------------------------------------+
|                 CONTROL NODE (Local Host)                   |
|                                                             |
|  [ansible.cfg] <---> [inventory.ini] <---> [group_vars]     |
|         |                                                   |
|  [Playbooks / Roles] (YAML tasks, templates, handlers)      |
+-------------------------------------------------------------+
                               |
                SSH Connection (Port 22)
          Ansible pushes standalone Python scripts
                               |
                               v
+-------------------------------------------------------------+
|               MANAGED NODE (GitLab VM / Target)             |
|                                                             |
|  1. Script executes in temp directory (/tmp or ~/.ansible)   |
|  2. Module inspects system state & applies desired changes  |
|  3. Returns JSON result: { "changed": true, "rc": 0, ... }  |
|  4. Script and temporary files are deleted immediately      |
+-------------------------------------------------------------+
```

### The 4 Pillars of Ansible Architecture:

1. **Agentless & Push-Based**:
   * No background agent runs on the target node.
   * You don't wait for targets to poll a central server (pull model). You run a playbook on your **Control Node**, and Ansible pushes configuration over **SSH** (or WinRM for Windows).
2. **Declarative State**:
   * Instead of specifying *how* to do something (imperative bash commands), you declare *what* the system should look like (e.g., `state: present`, `state: started`).
3. **Idempotency**:
   * The single most important concept in Ansible. An operation is **idempotent** if applying it once produces the desired result, and applying it 100 more times leaves the system in the exact same state without producing side-effects or errors (`OK` vs `CHANGED`).
4. **Python-Native Payload Execution**:
   * Ansible converts YAML task definitions into small, standalone Python scripts. It SFTP/SCPs them to the remote machine, executes them via the target's `/usr/bin/python3`, captures JSON output (`changed: true/false`, `stdout`, `failed`), and cleans up after itself.

---

## 3. Core Theoretical Concepts & Terminology

* **Control Node**: The machine where Ansible is installed and executed (your workstation or CI runner).
* **Managed Node (Target / Host)**: The remote server or VM being configured.
* **Inventory**: A file (INI or YAML) or dynamic script listing the targets, groupings, and connection variables.
* **Task**: The smallest unit of work in Ansible (e.g., install package `curl`, copy a file).
* **Module**: The code executed to perform a task (e.g., [ansible.builtin.apt](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_module.html), [ansible.builtin.template](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/template_module.html)).
* **Play**: Maps a set of hosts from the inventory to a specific set of roles or tasks.
* **Playbook**: A YAML file containing one or more plays.
* **Role**: A standard, modular directory structure packaging tasks, handlers, variables, and templates for a specific purpose (e.g., `gitlab`, `runner`).
* **Handler**: A task triggered only when another task reports a **change** (using `notify`).
* **Jinja2 Templating**: A templating engine that allows dynamic variable substitution, logic, and loops inside configuration files.
* **Ansible Vault**: An AES-256 encryption feature allowing sensitive variables (passwords, tokens, AWS keys) to be stored securely in version control.

---

## 4. Deep Dive: Every Ansible Concept in This Project

### 1. Configuration: [ansible/ansible.cfg](file:///home/afethi/github/code-keeper/ansible/ansible.cfg)
```ini
[defaults]
inventory = inventory.ini
collections_path = ~/.ansible/collections:./collections
remote_user = vagrant
host_key_checking = False
retry_files_enabled = False
roles_path = roles
```
* **`host_key_checking = False`**: Disables the interactive SSH prompt `Are you sure you want to continue connecting (yes/no)?`. Essential for automated and CI/CD environments.
* **`roles_path = roles`**: Tells Ansible where to look when a play declares `roles: [gitlab, runner]`.
* **`collections_path`**: Defines search directories for Ansible Galaxy collections.

---

### 2. Inventory Management: [ansible/inventory.ini](file:///home/afethi/github/code-keeper/ansible/inventory.ini)
```ini
[gitlab_server]
gitlab-node ansible_host=192.168.56.20 ansible_user=vagrant ansible_ssh_private_key_file=../.vagrant/machines/gitlab/virtualbox/private_key

[gitlab_server:vars]
ansible_python_interpreter=/usr/bin/python3
```
* **`[gitlab_server]`**: Creates an inventory host group named `gitlab_server`.
* **`gitlab-node`**: An alias for the target machine.
* **Host Connection Variables**:
  * `ansible_host`: The actual IP address of the target VM.
  * `ansible_user`: SSH login user (`vagrant`).
  * `ansible_ssh_private_key_file`: Points directly to the private key automatically generated by Vagrant when `vagrant up gitlab` is run.
* **`[gitlab_server:vars]`**: Group-level variables applied to every host in `gitlab_server`. `ansible_python_interpreter=/usr/bin/python3` ensures Ansible doesn't attempt to use Python 2 or a missing symlink.

---

### 3. Collections & Dependencies: [ansible/requirements.yml](file:///home/afethi/github/code-keeper/ansible/requirements.yml)
```yaml
collections:
  - name: community.general
  - name: community.crypto
```
* In Ansible 2.9+, modules were split from core into **Collections**. 
* This project utilizes `community.crypto` (specifically `community.crypto.openssh_keypair` to generate SSH keys) and `community.general`.

---

### 4. Playbook Orchestration: [ansible/site.yml](file:///home/afethi/github/code-keeper/ansible/site.yml)
```yaml
---
- name: Deploy GitLab Server Infrastructure
  ansible.builtin.import_playbook: playbooks/deploy_gitlab.yml

- name: Configure GitLab CI/CD Docker Runner
  ansible.builtin.import_playbook: playbooks/deploy_runner.yml
```
* **`site.yml`** is the master entrypoint ("umbrella playbook"). It uses `ansible.builtin.import_playbook` to run sub-playbooks in a clean, modular order: first the server, then the runner.
* In [ansible/playbooks/deploy_gitlab.yml](file:///home/afethi/github/code-keeper/ansible/playbooks/deploy_gitlab.yml):
  * **`hosts: gitlab_server`**: Targets the group defined in `inventory.ini`.
  * **`become: true`**: Privilege escalation (executes tasks using `sudo`).
  * **`vars_files`**: Loads variables from [group_vars/all.yml](file:///home/afethi/github/code-keeper/ansible/group_vars/all.yml) and encrypted secrets from [group_vars/vault.yml](file:///home/afethi/github/code-keeper/ansible/group_vars/vault.yml).
  * **`roles: - gitlab`**: Executes the `gitlab` role.

---

### 5. Variables and Ansible Vault
* **Public configuration** lives in [ansible/group_vars/all.yml](file:///home/afethi/github/code-keeper/ansible/group_vars/all.yml):
  ```yaml
  gitlab_external_url: "http://192.168.56.20"
  host_ssh_public_key_path: "~/.ssh/id_ed25519.pub"
  aws_default_region: "us-east-1"
  ```
* **Secret credentials** live in [ansible/group_vars/vault.yml](file:///home/afethi/github/code-keeper/ansible/group_vars/vault.yml):
  Encrypted with AES-256 (`$ANSIBLE_VAULT;1.1;AES256`). It contains sensitive values such as `gitlab_root_password`, `gitlab_api_token`, `aws_access_key_id`, and `aws_secret_access_key`.
* **Execution with Vault**: Run with `--ask-vault-pass` or `--vault-password-file`.

---

### 6. Role: GitLab (`ansible/roles/gitlab`)

This role demonstrates several intermediate and advanced Ansible patterns:

#### A. Jinja2 Templating & Performance Tuning
In [ansible/roles/gitlab/templates/gitlab.rb.j2](file:///home/afethi/github/code-keeper/ansible/roles/gitlab/templates/gitlab.rb.j2):
GitLab is notoriously resource-heavy (typically requiring 8GB+ RAM). To run it stably inside a 4GB VirtualBox VM, the template modifies GitLab's omnibus parameters:
```ruby
puma['worker_processes'] = 0
puma['min_threads'] = 1
puma['max_threads'] = 2
sidekiq['concurrency'] = 1
postgresql['shared_buffers'] = "128MB"
prometheus['enable'] = false
```
* In [tasks/main.yml](file:///home/afethi/github/code-keeper/ansible/roles/gitlab/tasks/main.yml):
  ```yaml
  - name: Deploy GitLab configuration file (/etc/gitlab/gitlab.rb)
    ansible.builtin.template:
      src: gitlab.rb.j2
      dest: /etc/gitlab/gitlab.rb
      mode: '0600'
    notify: Reconfigure GitLab
  ```
  If and only if `/etc/gitlab/gitlab.rb` is modified, Ansible notifies the handler in [handlers/main.yml](file:///home/afethi/github/code-keeper/ansible/roles/gitlab/handlers/main.yml) to execute `gitlab-ctl reconfigure`.

#### B. Flushed Handlers
```yaml
- name: Apply configuration if changed
  ansible.builtin.meta: flush_handlers
```
* By default, Ansible runs handlers at the **very end** of a play.
* But subsequent tasks need GitLab to be already reconfigured and running!
* `meta: flush_handlers` forces all pending notified handlers to execute **immediately**, before proceeding.

#### C. Polling & Retries (`until`, `retries`, `delay`)
```yaml
- name: Wait for GitLab web service to respond
  ansible.builtin.uri:
    url: "{{ gitlab_external_url }}/users/sign_in"
    status_code: 200
  register: result
  until: result.status == 200
  retries: 30
  delay: 10
```
* GitLab takes 1–3 minutes to start its services (Puma, PostgreSQL, Workhorse).
* Instead of a blind, unreliable `sleep 120`, Ansible queries the HTTP status using `ansible.builtin.uri`. It polls up to 30 times with a 10-second delay between checks until the status is 200.

#### D. Making Shell & Command Idempotent
Commands like `bash script.sh` are normally not idempotent. Ansible provides attributes to handle this:
* **`creates: /path/to/file`**: If the specified file already exists on the target, Ansible skips the task entirely (`OK` instead of `CHANGED`).
  ```yaml
  - name: Run GitLab CE repository setup script
    ansible.builtin.command:
      cmd: bash /tmp/gitlab_ce_script.deb.sh
      creates: /etc/apt/sources.list.d/gitlab_gitlab-ce.list
  ```
* **`changed_when:`**: Explicitly control when a task reports `changed: true` or `changed: false`.

#### E. REST API Integration (`ansible.builtin.uri`)
Ansible is not limited to managing OS files; it can automate third-party REST APIs. The role:
* Creates the `code-keeper` group.
* Retrieves the group's internal ID (`register: group_info`).
* Iterates over a loop to create projects (`terraform`, `api-gateway`, `inventory`, `billing`).
* Manages CI/CD group variables for AWS credentials.

#### F. Task Delegation (`delegate_to: localhost`)
```yaml
- name: Check if SSH public key exists on host machine
  ansible.builtin.stat:
    path: "{{ host_ssh_public_key_path }}"
  register: ssh_key_stat
  delegate_to: localhost
  become: false
```
* Normally, tasks execute on the managed node (`gitlab-node`).
* `delegate_to: localhost` tells Ansible to execute this specific task on the **Control Node** (your host system).
* This allows Ansible to read your local SSH public key (`~/.ssh/id_ed25519.pub`), and then make a REST API call to upload it to the GitLab instance.

#### G. Git Subtree Deployment from Ansible
The playbook pushes local microservice source directories into their corresponding standalone GitLab repositories using Git subtree:
```yaml
- name: Push microservices code to GitLab repositories via Git Subtree
  ansible.builtin.shell: |
    REPO_ROOT=$(git rev-parse --show-toplevel)
    cd "$REPO_ROOT"
    git subtree split --prefix=apps/{{ item }} -b temp-{{ item }}
    git push http://root:{{ gitlab_api_token }}@192.168.56.20/code-keeper/{{ item }}.git temp-{{ item }}:main --force
  delegate_to: localhost
  become: false
  loop: [terraform, api-gateway, inventory, billing]
```

---

### 7. Role: Runner (`ansible/roles/runner`)
In [ansible/roles/runner/tasks/main.yml](file:///home/afethi/github/code-keeper/ansible/roles/runner/tasks/main.yml):
* Installs `docker.io` and `gitlab-runner`.
* Adds the `gitlab-runner` system user to the `docker` group (`ansible.builtin.user`).
* Checks whether the runner is already registered (`gitlab-runner list`).
* Requests an instance runner authentication token from the GitLab API.
* Executes `gitlab-runner register` non-interactively, configuring the runner with `--executor "docker"` and `--docker-privileged="true"`. This is what allows GitLab pipelines to build containers inside containers (Docker-in-Docker / DinD).

---

## 5. Summary Table: All Ansible Concepts Used in This Project

| Concept | File / Implementation | Purpose |
| :--- | :--- | :--- |
| **Playbook & Plays** | [site.yml](file:///home/afethi/github/code-keeper/ansible/site.yml), [deploy_gitlab.yml](file:///home/afethi/github/code-keeper/ansible/playbooks/deploy_gitlab.yml) | Top-level execution definitions mapping hosts to tasks. |
| **Inventory & Variables** | [inventory.ini](file:///home/afethi/github/code-keeper/ansible/inventory.ini), [all.yml](file:///home/afethi/github/code-keeper/ansible/group_vars/all.yml) | Host definitions, SSH credentials, external URLs. |
| **Ansible Vault** | [vault.yml](file:///home/afethi/github/code-keeper/ansible/group_vars/vault.yml) | Encrypted storage of sensitive secrets (passwords, AWS keys). |
| **Roles & Modularity** | `roles/gitlab`, `roles/runner` | Encapsulation of independent functional units. |
| **Handlers & Flush** | `handlers/main.yml`, `meta: flush_handlers` | Triggering `gitlab-ctl reconfigure` only on template changes. |
| **Jinja2 Templating** | [gitlab.rb.j2](file:///home/afethi/github/code-keeper/ansible/roles/gitlab/templates/gitlab.rb.j2) | Dynamic configuration file generation and RAM optimization. |
| **Polling & Healthchecks** | `uri`, `until`, `retries`, `delay` | Waiting for GitLab web UI to report HTTP 200. |
| **Task Delegation** | `delegate_to: localhost`, `become: false` | Running host-side tasks (SSH key check, Git subtree push). |
| **Dynamic REST API Calls**| `ansible.builtin.uri` | Automating GitLab groups, projects, tokens, and variables. |
| **Package & Service Mgmt**| `apt`, `service`, `user` | Declaratively installing packages, enabling systemd daemons. |

---

## 6. How to Run and Test This Configuration

From the root of the project:

```bash
# 1. Ensure the target VM is running
vagrant up gitlab

# 2. Switch into the ansible directory
cd ansible

# 3. Check syntax of all playbooks
ansible-playbook --syntax-check site.yml

# 4. Test connectivity to the managed node
ansible -i inventory.ini gitlab_server -m ping

# 5. Run the full deployment
ansible-playbook -i inventory.ini site.yml --ask-vault-pass
```