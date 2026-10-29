# Select each project’s .node-version; use system Node outside projects.
/usr/bin/fnm env --use-on-cd --version-file-strategy recursive --shell fish | source
