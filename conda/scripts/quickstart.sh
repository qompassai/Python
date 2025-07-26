# quickstart.sh
# Qompass AI Conda Quickstart
# Copyright (C) 2025 Qompass AI, All rights reserved
#####################################################
curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash ~/miniconda.sh -b -u -p ~/.local/miniconda3
rm ~/miniconda.sh
ln -s ~/.local/miniconda3/bin/conda ~/.local/bin/conda
