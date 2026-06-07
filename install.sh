#!/usr/bin/env bash
# ==============================================================================
# install.sh — Mise en place des symlinks pour le repo wsl_dotfile
# Repo    : ~/wsl_dotfile
# Auteur  : bruno-coulet
# Usage   : bash ~/wsl_dotfile/install.sh
# ==============================================================================

set -euo pipefail

DOTFILE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Repertoire dotfiles : $DOTFILE_DIR"

# ------------------------------------------------------------------------------
# Fonction utilitaire : cree un symlink avec sauvegarde si le fichier existe
# ------------------------------------------------------------------------------
link() {
    local src="$1"   # fichier dans le repo
    local dest="$2"  # emplacement cible dans $HOME

    # Cree le dossier parent si necessaire
    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        # Fichier reel existant : on sauvegarde
        echo "  Sauvegarde : $dest -> ${dest}.backup"
        mv "$dest" "${dest}.backup"
    elif [ -L "$dest" ]; then
        # Symlink existant : on le supprime pour le recreer proprement
        rm "$dest"
    fi

    ln -s "$src" "$dest"
    echo "  Lien cree  : $dest -> $src"
}

# ------------------------------------------------------------------------------
# Bash
# ------------------------------------------------------------------------------
echo ""
echo "==> Bash"
link "$DOTFILE_DIR/bash/.bashrc" "$HOME/.bashrc"

# ------------------------------------------------------------------------------
# Git
# ------------------------------------------------------------------------------
echo ""
echo "==> Git"
link "$DOTFILE_DIR/git/.gitconfig" "$HOME/.gitconfig"

# ------------------------------------------------------------------------------
# VS Code (paramètres WSL)
# ------------------------------------------------------------------------------
echo ""
echo "==> VS Code"
VSCODE_SETTINGS="$HOME/.config/Code/User/settings.json"
link "$DOTFILE_DIR/vscode/settings.json" "$VSCODE_SETTINGS"

# ------------------------------------------------------------------------------
# Templates de projet (utilises par init-project)
# Le dossier est simplement accessible via $DOTFILE_DIR/templates
# Pas de symlink necessaire : init-project pointe directement sur ce chemin
# ------------------------------------------------------------------------------
echo ""
echo "==> Templates"
echo "  Dossier templates : $DOTFILE_DIR/templates (reference directe, pas de symlink)"

# ------------------------------------------------------------------------------
# Rechargement du shell
# ------------------------------------------------------------------------------
echo ""
echo "Installation terminee."
echo "Recharger le terminal avec : source ~/.bashrc"
