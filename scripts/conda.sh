#!/usr/bin/env bash
# setup-conda-ai-config.sh
# AI/ML Conda Configuration Setup
# Copyright (C) 2025 - AI Workload Optimized
############################################
set -euo pipefail
cleanup() {
    echo -e "${RED}🧹 Cleaning up on failure...${NC}"
    rm -rf ~/.config/conda/condarc.d/incomplete_*
}
trap cleanup ERR

create_config_file() {
    local filename="$1"
    local content="$2"
    local temp_file="${filename}.incomplete"

    echo "$content" > "$temp_file"
    if [ $? -eq 0 ]; then
        mv "$temp_file" "$filename"
        echo -e "${GREEN}✅ Created $filename${NC}"
    else
        echo -e "${RED}❌ Failed to create $filename${NC}"
        return 1
    fi
}

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🐍 Setting up Conda configuration for AI/ML workloads...${NC}"

echo -e "${YELLOW}📁 Creating configuration directories...${NC}"
mkdir -p ~/.config/conda/condarc.d/

if [ -f ~/.condarc ]; then
    echo -e "${YELLOW}💾 Backing up existing ~/.condarc...${NC}"
    mv ~/.condarc ~/.condarc.backup.$(date +%Y%m%d-%H%M%S)
fi

echo -e "${YELLOW}🔧 Setting up channels configuration...${NC}"
cat > ~/.config/conda/condarc.d/channels.yml << 'EOF'
# AI/ML optimized channels
channels:
  - anaconda
  - bioconda
  - conda-forge
  - defaults
  - fastai
  - huggingface
  - intel
  - nvidia
  - nvidia/label/cuda-12.0.0
  - nvidia/label/cuda-12.8.0
  - nvidia/label/dev
  - plotly
  - pytorch
  - pyviz
  - rapidsai
  - rapidsai/label/cuda12

# Channel settings
channel_priority: strict
show_channel_urls: true
use_only_tar_bz2: false

# Platform support
subdirs:
  - linux-64
  - noarch
EOF

echo -e "${YELLOW}🏠 Setting up environment configuration...${NC}"
cat > ~/.config/conda/condarc.d/environments.yml << 'EOF'
# Environment settings
auto_activate_base: false
env_prompt: '({name}) '
changeps1: true

# Environment directories
envs_dirs:
  - ~/.conda/envs
  - ~/.local/share/conda/envs
  - ~/miniconda3/envs

# Environment creation settings
always_yes: false
always_copy: false
allow_softlinks: true
EOF

echo -e "${YELLOW}📦 Setting up AI/ML package configuration...${NC}"
cat > ~/.config/conda/condarc.d/packages.yml << 'EOF'
# Default packages for AI/ML environments
create_default_packages:
  - catboost
  - conda-build
  - cudatoolkit-dev
  - dask
  - datasets
  - fastai
  - git
  - huggingface_hub
  - ipython
  - jax
  - jaxlib
  - jupyter
  - lightgbm
  - matplotlib
  - mlflow
  - nccl
  - notebook
  - numpy
  - onnxruntime
  - optuna
  - pandas
  - pip
  - pytorch-lightning
  - ray
  - scikit-learn
  - setuptools
  - tensorboard
  - tensorflow
  - tensorrt
  - torch
  - torchaudio
  - torchvision
  - transformers
  - wandb
  - wheel
  - xgboost

# Package directories
pkgs_dirs:
  - ~/.conda/pkgs
  - ~/.local/share/conda/pkgs
  - ~/miniconda3/pkgs

# Package settings
use_pip: true
pip_interop_enabled: true
EOF

echo -e "${YELLOW}⚡ Setting up performance configuration...${NC}"
cat > ~/.config/conda/condarc.d/performance.yml << 'EOF'
# Performance settings
solver: libmamba
auto_update_conda: false
offline: false

# Download settings
concurrent_downloads: true
download_threads: 8
verify_threads: 2

# Memory and speed optimizations
aggressive_update_packages: []
disallowed_packages: []
pinned_packages: []
EOF

echo -e "${YELLOW}🔒 Setting up security configuration...${NC}"
cat > ~/.config/conda/condarc.d/security.yml << 'EOF'
# Security settings
ssl_verify: true
report_errors: false
safety_checks: warn

# Network settings
remote_connect_timeout_secs: 15.0
remote_read_timeout_secs: 120.0
remote_max_retries: 5

# Proxy settings (uncomment and modify if needed)
# proxy_servers:
#   http: http://user:pass@corp.com:8080
#   https: https://user:pass@corp.com:8080
EOF

echo -e "${YELLOW}🤖 Setting up AI/ML specific configuration...${NC}"
cat > ~/.config/conda/condarc.d/ai-ml.yml << 'EOF'
# AI/ML framework settings
frameworks:
  pytorch:
    cuda_version: "12.8"
    use_system_cuda: true
    cudnn_version: "9"
    cublas_version: "12"
    cufft_version: "11"
    curand_version: "10"
    cusolver_version: "11"
    cusparse_version: "12"
  tensorflow:
    version: ">=2.10"
    tensorrt_support: true
    cuda_system_lib: true
  jax:
    cuda_support: true
    nccl_support: true

# GPU and CUDA settings
cuda:
  system_installation: true
  version: "12.8"
  path: "/opt/cuda"
  arch_list: "6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0"

# NVIDIA libraries configuration
nvidia_libraries:
  cudnn:
    version: "9.5.1"
    path: "/opt/cuda/lib64"
  cublas:
    version: "12.8.1"
    path: "/opt/cuda/lib64"
  cufft:
    version: "11.3.0"
    path: "/opt/cuda/lib64"
  curand:
    version: "10.3.7"
    path: "/opt/cuda/lib64"
  cusolver:
    version: "11.7.1"
    path: "/opt/cuda/lib64"
  cusparse:
    version: "12.5.4"
    path: "/opt/cuda/lib64"
  npp:
    version: "12.3.2"
    path: "/opt/cuda/lib64"
  nvtx:
    version: "12.6"
    path: "/opt/cuda/lib64"
  tensorrt:
    version: "10.5.0"
    path: "/usr/lib/x86_64-linux-gnu"
  nccl:
    version: "2.23.4"
    path: "/opt/cuda/lib64"

# Environment variables for AI/ML
default_env_vars:
  CUDA_HOME: "/opt/cuda"
  CUDA_ROOT: "/opt/cuda"
  CUDA_PATH: "/opt/cuda"
  CUDA_VISIBLE_DEVICES: "0"
  CUDNN_PATH: "/opt/cuda"
  CUBLAS_PATH: "/opt/cuda"
  CUFFT_PATH: "/opt/cuda"
  CURAND_PATH: "/opt/cuda"
  CUSOLVER_PATH: "/opt/cuda"
  CUSPARSE_PATH: "/opt/cuda"
  NPP_PATH: "/opt/cuda"
  TENSORRT_PATH: "/usr/lib/x86_64-linux-gnu"
  NCCL_PATH: "/opt/cuda"
  PATH: "/opt/cuda/bin:$PATH"
  LD_LIBRARY_PATH: "/opt/cuda/lib64:/opt/cuda/extras/CUPTI/lib64:$LD_LIBRARY_PATH"
  OMP_NUM_THREADS: "1"
  MKL_NUM_THREADS: "1"
  OPENBLAS_NUM_THREADS: "1"
  NUMBA_CACHE_DIR: "~/.cache/numba"
  TORCH_HOME: "~/.cache/torch"
  HF_HOME: "~/.cache/huggingface"
  TRANSFORMERS_CACHE: "~/.cache/huggingface/transformers"
  TRT_LOGGER_VERBOSITY: "WARNING"
  TENSORRT_ROOT: "/usr/lib/x86_64-linux-gnu"
  # NCCL settings for multi-GPU
  NCCL_DEBUG: "INFO"
  NCCL_IB_DISABLE: "1"
  NCCL_P2P_DISABLE: "1"
EOF

echo -e "${YELLOW}💻 Setting up development configuration...${NC}"
cat > ~/.config/conda/condarc.d/development.yml << 'EOF'
# Development settings
rollback_enabled: true
track_features: []

# Jupyter and notebook settings
notebook_dir: "~/notebooks"
jupyter_config_dir: "~/.config/jupyter"
ipython_dir: "~/.config/ipython"

# Version control integration
git_executable: git
restore_free_channel: true
EOF

echo -e "${YELLOW}⚛️  Setting up quantum computing configuration...${NC}"
cat > ~/.config/conda/condarc.d/quantum.yml << 'EOF'
# Quantum computing channels
quantum_channels:
  - qiskit
  - rigetti
  - xanadu
  - microsoft-quantum

# Quantum computing packages
quantum_default_packages:
  - qiskit
  - qiskit-aer
  - qiskit-nature
  - cirq
  - pennylane
  - strawberry-fields
  - pyquil
  - qutip
  - forest-benchmarking

# Quantum simulation settings
quantum_simulators:
  - qasm_simulator
  - statevector_simulator
  - unitary_simulator
EOF

echo -e "${YELLOW}📝 Creating main .condarc file...${NC}"
cat > ~/.config/conda/.condarc << 'EOF'
# Main conda configuration file
# Individual settings are modularized in condarc.d/ directory

# This file serves as the primary configuration entry point
# All specific configurations are in ~/.config/conda/condarc.d/
EOF

chmod 600 ~/.config/conda/.condarc
chmod -R 644 ~/.config/conda/condarc.d/*.yml

echo -e "${GREEN}✅ Conda configuration for AI/ML workloads set up successfully!${NC}"
echo -e "${BLUE}📁 Configuration files created in ~/.config/conda/condarc.d/${NC}"
echo -e "${BLUE}🔧 Run 'conda config --show' to verify settings${NC}"
echo -e "${BLUE}📊 Run 'conda info' to see environment information${NC}"

# Validate configuration if conda is available
if command -v conda &> /dev/null; then
    echo -e "${YELLOW}🔍 Validating configuration...${NC}"
    if conda config --validate &> /dev/null; then
        echo -e "${GREEN}✅ Configuration validation passed${NC}"
    else
        echo -e "${RED}❌ Configuration validation failed - please check settings${NC}"
        echo -e "${YELLOW}💡 Run 'conda config --validate' for detailed error information${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Conda not found in PATH - configuration created but not validated${NC}"
fi

echo -e "${GREEN}🎉 Setup complete! Your conda environment is optimized for AI workloads.${NC}"
