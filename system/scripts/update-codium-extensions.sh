#!/usr/bin/env bash

# list your extensions with: codium --list-extensions
EXTENSIONS=(
    "codezombiech.gitignore"
    "dbaeumer.vscode-eslint"
    "donjayamanne.githistory"
    "eamodio.gitlens"
    "editorconfig.editorconfig"
    "esbenp.prettier-vscode"
    "formulahendry.auto-close-tag"
    "formulahendry.code-runner"
    "franneck94.vscode-rust-extension-pack"
    "gruntfuggly.todo-tree"
    "jnoortheen.nix-ide"
    "markwylde.vscode-filesize"
    # "mblode.twig-language-2"
    "ms-vscode.references-view"
    "nico-castell.linux-desktop-file"
    "paragdiwan.gitpatch"
    "pkief.material-icon-theme"
    "rust-lang.rust-analyzer"
    "svelte.svelte-vscode"
    "timonwong.shellcheck"
    "zhuangtongfa.material-theme"
    "ziyasal.vscode-open-in-github"
)

echo "Installing codium extensions..."
echo "${EXTENSIONS[*]}" | xargs -P "$(nproc)" -n 1 codium --force --install-extension > /dev/null
