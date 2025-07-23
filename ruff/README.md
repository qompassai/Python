<!-- /qompassai/python/ruff/README.md -->

<!-- Qompass AI Ruff README -->

<!-- Copyright (C) 2025 Qompass AI, All rights reserved -->

<!-- ---------------------------------------- -->

Usage: ruff \[OPTIONS] <COMMAND>

Commands:
check    Run Ruff on the given files or directories
rule     Explain a rule (or all rules)
config   List or describe the available configuration options
linter   List all supported upstream linters
clean    Clear any caches in the current directory and any subdirectories
format   Run the Ruff formatter on the given files or directories
server   Run the language server
analyze  Run analysis over Python source code
version  Display Ruff's version
help     Print this message or the help of the given subcommand(s)

Options:
-h, --help     Print help
-V, --version  Print version

Log levels:
-v, --verbose  Enable verbose logging
-q, --quiet    Print diagnostics, but nothing else
-s, --silent   Disable all logging (but still exit with status code "1" upon
detecting diagnostics)

Global options:
\--config \<CONFIG\_OPTION>
Either a path to a TOML configuration file (`pyproject.toml` or
`ruff.toml`), or a TOML `<KEY> = <VALUE>` pair (such as you might
find in a `ruff.toml` configuration file) overriding a specific
configuration option. Overrides of individual settings using this
option always take precedence over all configuration files, including
configuration files that were also specified using `--config`
\--isolated
Ignore all configuration files
