#!/usr/bin/env bash

###############################################################################
# User-local DevOps Environment Setup
#
# Installs without sudo/root:
#   - AWS CLI
#   - Terraform
#   - Vagrant CLI
#   - Ansible
#
# Everything is installed under:
#   ~/.local/
#
# Supported:
#   Ubuntu / Debian
###############################################################################

set -Eeuo pipefail

###############################################################################
# Configuration
###############################################################################

readonly SCRIPT_NAME="$(basename "$0")"
readonly HOME_DIR="${HOME:?HOME is not set}"

readonly LOCAL_DIR="$HOME_DIR/.local"
readonly BIN_DIR="$LOCAL_DIR/bin"
readonly AWS_DIR="$LOCAL_DIR/aws-cli"
readonly VENV_DIR="$LOCAL_DIR/venvs/ansible"

readonly LOG_FILE="/tmp/devops-setup-$(date +%Y%m%d-%H%M%S).log"

readonly TERRAFORM_VERSION="1.16.0"
readonly VAGRANT_VERSION="2.4.9"

###############################################################################
# Colors
###############################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

###############################################################################
# Logging
###############################################################################

log() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}[OK]${NC} $*" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"
}

###############################################################################
# Error handling
###############################################################################

on_error() {
    local exit_code=$?

    error "Command failed: ${BASH_COMMAND}"
    error "Line: ${BASH_LINENO[0]}"
    error "Exit code: ${exit_code}"
    error "Log file: ${LOG_FILE}"

    exit "$exit_code"
}

trap on_error ERR

###############################################################################
# Cleanup
###############################################################################

cleanup() {
    if [[ -n "${TMP_DIR:-}" ]] && [[ -d "$TMP_DIR" ]]; then
        rm -rf "$TMP_DIR"
    fi
}

trap cleanup EXIT

###############################################################################
# Basic checks
###############################################################################

check_environment() {

    log "Checking environment..."

    if [[ "$EUID" -eq 0 ]]; then
        warning "Running as root."
        warning "This script is designed for a normal user."
    fi

    if ! command -v curl >/dev/null 2>&1; then
        error "curl is required but was not found."
        error "Ask your system administrator to install curl."
        exit 1
    fi

    if ! command -v unzip >/dev/null 2>&1; then
        error "unzip is required but was not found."
        error "Ask your system administrator to install unzip."
        exit 1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        error "python3 is required but was not found."
        error "Ask your system administrator to install Python 3."
        exit 1
    fi

    success "Basic dependencies are available."
}

###############################################################################
# Directory setup
###############################################################################

create_directories() {

    log "Creating user-local directories..."

    mkdir -p "$LOCAL_DIR"
    mkdir -p "$BIN_DIR"
    mkdir -p "$LOCAL_DIR/venvs"

    success "Directories created:"
    echo "  $LOCAL_DIR"
    echo "  $BIN_DIR"
    echo "  $VENV_DIR"
}

###############################################################################
# PATH configuration
###############################################################################

configure_path() {

    log "Configuring PATH..."

    local shell_rc=""

    case "${SHELL:-}" in

        */bash)
            shell_rc="$HOME_DIR/.bashrc"
            ;;

        */zsh)
            shell_rc="$HOME_DIR/.zshrc"
            ;;

        *)
            warning "Could not determine shell."
            warning "Add the following manually to your shell configuration:"
            echo
            echo 'export PATH="$HOME/.local/bin:$HOME/.local/aws-cli/v2/current/bin:$PATH"'
            echo
            return
            ;;
    esac

    touch "$shell_rc"

    if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$shell_rc"; then
        cat >> "$shell_rc" <<'EOF'

# User-local DevOps tools
export PATH="$HOME/.local/bin:$PATH"
EOF
    fi

    if ! grep -Fq '.local/aws-cli/v2/current/bin' "$shell_rc"; then
        cat >> "$shell_rc" <<'EOF'
export PATH="$HOME/.local/aws-cli/v2/current/bin:$PATH"
EOF
    fi

    export PATH="$BIN_DIR:$AWS_DIR/v2/current/bin:$PATH"

    success "PATH configured in $shell_rc."
}

###############################################################################
# AWS CLI
###############################################################################

install_aws_cli() {

    log "Checking AWS CLI..."

    if command -v aws >/dev/null 2>&1; then

        success "AWS CLI already available."

        aws --version

        return
    fi

    log "Installing AWS CLI into $AWS_DIR..."

    TMP_DIR="$(mktemp -d)"

    local archive="$TMP_DIR/awscliv2.zip"

    curl -fL \
        --retry 3 \
        --retry-delay 2 \
        "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o "$archive"

    unzip -q "$archive" -d "$TMP_DIR"

    mkdir -p "$AWS_DIR"

    "$TMP_DIR/aws/install" \
        --install-dir "$AWS_DIR" \
        --bin-dir "$BIN_DIR" \
        --update

    export PATH="$BIN_DIR:$PATH"

    if ! command -v aws >/dev/null 2>&1; then
        error "AWS CLI installation failed."
        exit 1
    fi

    success "AWS CLI installed."

    aws --version
}

###############################################################################
# Terraform
###############################################################################

install_terraform() {

    log "Checking Terraform..."

    if command -v terraform >/dev/null 2>&1; then

        success "Terraform already available."

        terraform version

        return
    fi

    log "Installing Terraform ${TERRAFORM_VERSION}..."

    TMP_DIR="$(mktemp -d)"

    local archive="$TMP_DIR/terraform.zip"

    curl -fL \
        --retry 3 \
        --retry-delay 2 \
        "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
        -o "$archive"

    unzip -q "$archive" -d "$TMP_DIR"

    install -m 0755 \
        "$TMP_DIR/terraform" \
        "$BIN_DIR/terraform"

    export PATH="$BIN_DIR:$PATH"

    if ! command -v terraform >/dev/null 2>&1; then
        error "Terraform installation failed."
        exit 1
    fi

    success "Terraform installed."

    terraform version
}

###############################################################################
# Vagrant
###############################################################################

install_vagrant() {

    log "Checking Vagrant..."

    if command -v vagrant >/dev/null 2>&1; then

        success "Vagrant already available."

        vagrant --version

        return
    fi

    log "Installing Vagrant ${VAGRANT_VERSION}..."

    TMP_DIR="$(mktemp -d)"

    local archive="$TMP_DIR/vagrant.zip"

    curl -fL \
        --retry 3 \
        --retry-delay 2 \
        "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_linux_amd64.zip" \
        -o "$archive"

    unzip -q "$archive" -d "$TMP_DIR"

    install -m 0755 \
        "$TMP_DIR/vagrant" \
        "$BIN_DIR/vagrant"

    export PATH="$BIN_DIR:$PATH"

    if ! command -v vagrant >/dev/null 2>&1; then
        error "Vagrant installation failed."
        exit 1
    fi

    success "Vagrant CLI installed."

    vagrant --version

    echo
    warning "Vagrant requires a virtualization provider."
    warning "For example: VirtualBox, libvirt, VMware, etc."
    warning "Installing the provider normally requires administrator privileges."
}

###############################################################################
# Ansible
###############################################################################

install_ansible() {

    log "Checking Ansible..."

    if command -v ansible >/dev/null 2>&1; then

        success "Ansible already available."

        ansible --version

        return
    fi

    log "Creating Ansible Python virtual environment..."

    if [[ ! -d "$VENV_DIR" ]]; then

        python3 -m venv "$VENV_DIR"

    else

        success "Ansible virtual environment already exists."

    fi

    local pip="$VENV_DIR/bin/pip"
    local ansible_bin="$VENV_DIR/bin/ansible"

    log "Upgrading pip..."

    "$pip" install --upgrade pip

    log "Installing Ansible..."

    "$pip" install ansible

    ln -sf \
        "$ansible_bin" \
        "$BIN_DIR/ansible"

    ln -sf \
        "$VENV_DIR/bin/ansible-playbook" \
        "$BIN_DIR/ansible-playbook"

    ln -sf \
        "$VENV_DIR/bin/ansible-galaxy" \
        "$BIN_DIR/ansible-galaxy"

    export PATH="$BIN_DIR:$PATH"

    if ! command -v ansible >/dev/null 2>&1; then
        error "Ansible installation failed."
        exit 1
    fi

    success "Ansible installed."

    ansible --version
}

###############################################################################
# Verification
###############################################################################

verify_installations() {

    log "=========================================="
    log "Verifying installations"
    log "=========================================="

    local failed=0

    if command -v aws >/dev/null 2>&1; then
        success "AWS CLI:"
        aws --version
    else
        error "AWS CLI not found."
        failed=1
    fi

    echo

    if command -v terraform >/dev/null 2>&1; then
        success "Terraform:"
        terraform version
    else
        error "Terraform not found."
        failed=1
    fi

    echo

    if command -v vagrant >/dev/null 2>&1; then
        success "Vagrant:"
        vagrant --version
    else
        error "Vagrant not found."
        failed=1
    fi

    echo

    if command -v ansible >/dev/null 2>&1; then
        success "Ansible:"
        ansible --version | head -n 1
    else
        error "Ansible not found."
        failed=1
    fi

    if [[ "$failed" -ne 0 ]]; then
        error "Verification failed."
        exit 1
    fi

    success "All tools are available."
}

###############################################################################
# AWS credentials
###############################################################################

check_aws_credentials() {

    echo
    log "Checking AWS credentials..."

    if aws sts get-caller-identity >/dev/null 2>&1; then

        success "AWS credentials are configured."

        aws sts get-caller-identity

    else

        warning "AWS credentials are not configured."

        echo
        echo "Configure them with:"
        echo
        echo "    aws configure"
        echo
        echo "Then verify:"
        echo
        echo "    aws sts get-caller-identity"
        echo
    fi
}

###############################################################################
# Final information
###############################################################################

print_summary() {

    echo
    echo "============================================================"
    echo " DevOps environment setup completed"
    echo "============================================================"
    echo
    echo "Installed tools:"
    echo
    echo "  AWS CLI     : $(command -v aws)"
    echo "  Terraform   : $(command -v terraform)"
    echo "  Vagrant     : $(command -v vagrant)"
    echo "  Ansible     : $(command -v ansible)"
    echo
    echo "User-local installation directory:"
    echo
    echo "  $LOCAL_DIR"
    echo
    echo "If the commands are not available in a new terminal,"
    echo "run:"
    echo
    echo "  source ~/.bashrc"
    echo
    echo "or:"
    echo
    echo "  source ~/.zshrc"
    echo
    echo "============================================================"
}

###############################################################################
# Main
###############################################################################

main() {

    log "Starting user-local DevOps environment setup."

    check_environment

    create_directories

    configure_path

    install_aws_cli

    install_terraform

    install_vagrant

    install_ansible

    verify_installations

    check_aws_credentials

    print_summary

    success "Setup finished successfully."
}

main "$@"