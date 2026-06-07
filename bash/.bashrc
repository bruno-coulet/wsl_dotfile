# ==============================================================================
# ~/.bashrc — Configuration Bash WSL2 Ubuntu
# Repo    : ~/wsl_dotfile
# Auteur  : bruno-coulet
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. SECURITE : ne rien executer dans un shell non-interactif
# ------------------------------------------------------------------------------
case $- in
    *i*) ;;
      *) return;;
esac

# ------------------------------------------------------------------------------
# 2. PATH : uv, et VS Code (chemin Windows via /mnt/c)
# ------------------------------------------------------------------------------
# uv (installe via : curl -Lsf https://astral.sh/uv/install.sh | sh)
export PATH="$HOME/.local/bin:$PATH"

# Charge les variables d'environnement de uv si le fichier existe
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# VS Code depuis Windows
VSCODE_WIN="/mnt/c/Users/coule/AppData/Local/Programs/Microsoft VS Code/bin"
[ -d "$VSCODE_WIN" ] && export PATH="$PATH:$VSCODE_WIN"

# ------------------------------------------------------------------------------
# 3. PROMPT : Starship
# ------------------------------------------------------------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# ------------------------------------------------------------------------------
# 4. GESTION AUTOMATIQUE DU VENV (uv)
# ------------------------------------------------------------------------------
alias venv='source .venv/bin/activate'

check_venv() {
    if [ -d ".venv" ] && [ -z "$VIRTUAL_ENV" ]; then
        source .venv/bin/activate
    fi
}

cd() {
    builtin cd "$@" && check_venv
}

# ------------------------------------------------------------------------------
# 5. ALIASES IA & VIBECODING
# ------------------------------------------------------------------------------
if command -v claude &>/dev/null; then
    alias claude='claude'
else
    alias claude='echo "Claude Code non installe. Lancer : npm install -g @anthropic-ai/claude-code"'
fi

alias ask-ai='gh copilot suggest'
alias explain-ai='gh copilot explain'

# ------------------------------------------------------------------------------
# 6. ALIASES GENERAUX & GIT
# ------------------------------------------------------------------------------
alias reload='source ~/.bashrc'
alias explorer='explorer.exe .'
alias projets='cd ~/Documents/projets'

alias gf='git fetch'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gph='git push'
alias gpl='git pull'

# ------------------------------------------------------------------------------
# 7. FONCTION INIT-PROJECT
# Cree un projet Python avec uv, venv, config VSCode, Ruff et instructions IA
# Usage : init-project <nom-du-projet>
# ------------------------------------------------------------------------------
init-project() {
    local BASE_DIR="$HOME/Documents/projets"
    local TEMPLATE_DIR="$HOME/wsl_dotfile/templates"

    if [ -z "$1" ]; then
        echo "Erreur : specifier un nom de projet."
        echo "Usage  : init-project <nom-du-projet>"
        return 1
    fi

    local TARGET_DIR="$BASE_DIR/$1"

    if [ -d "$TARGET_DIR" ]; then
        echo "Erreur : le projet '$1' existe deja dans $BASE_DIR"
        return 1
    fi

    if ! command -v uv &>/dev/null; then
        echo "Erreur : uv n'est pas installe ou absent du PATH."
        echo "Installation : curl -Lsf https://astral.sh/uv/install.sh | sh"
        return 1
    fi

    echo "Initialisation du projet '$1' avec uv..."
    uv init --app --python 3.12 "$TARGET_DIR"
    cd "$TARGET_DIR" || return 1

    mkdir -p data temp .github .vscode

    cat >> .gitignore << 'EOF'

# Securite
.env

# Caches Python
*.pyc
__pycache__/

# Donnees locales
data/
temp/

# Fichiers IA (instructions locales, non versionnees en entreprise)
CLAUDE.md
.github/copilot-instructions.md
EOF

    local copied=0
    if [ -f "$TEMPLATE_DIR/settings.json" ]; then
        cp "$TEMPLATE_DIR/settings.json" .vscode/settings.json && copied=$((copied + 1))
    fi
    if [ -f "$TEMPLATE_DIR/pyproject.toml" ]; then
        cp "$TEMPLATE_DIR/pyproject.toml" ./pyproject.toml && copied=$((copied + 1))
    fi
    if [ -f "$TEMPLATE_DIR/CLAUDE_WSL.md" ]; then
        cp "$TEMPLATE_DIR/CLAUDE_WSL.md" ./CLAUDE.md && copied=$((copied + 1))
    fi
    if [ -f "$TEMPLATE_DIR/copilot-instructions.md" ]; then
        cp "$TEMPLATE_DIR/copilot-instructions.md" .github/copilot-instructions.md && copied=$((copied + 1))
    fi

    echo "$copied fichier(s) de template copies."

    git add .
    git commit -m "feat: initialisation du projet avec uv"

    echo "Projet '$1' pret dans $TARGET_DIR"
    echo "Ouverture dans VS Code..."
    code .
}

# ------------------------------------------------------------------------------
# 8. CONDA (desactive si uv est utilise en priorite)
# Pour reactiver conda, decommenter le bloc ci-dessous
# ------------------------------------------------------------------------------
# __conda_setup="$('/home/coule/miniconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     [ -f "/home/coule/miniconda3/etc/profile.d/conda.sh" ] \
#         && . "/home/coule/miniconda3/etc/profile.d/conda.sh" \
#         || export PATH="/home/coule/miniconda3/bin:$PATH"
# fi
# unset __conda_setup
export PATH="$HOME/.npm-global/bin:$PATH"
