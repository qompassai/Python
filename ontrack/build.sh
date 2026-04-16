#!/usr/bin/env bash

# build.sh
# Copyright (C) 2026 Qompass AI, All rights reserved
# ----------------------------------------
env -u PIP_EXTRA_INDEX_URL \
    -u PIP_INDEX_URL \
    -u PIP_FIND_LINKS \
    ~/.local/bin/buildozer android debug 2>&1 | tee ~/buildozer_debug.log
