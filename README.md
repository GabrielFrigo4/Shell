# 🐚 Universal Shell Environment

> Configurações, aliases e prompts centralizados para todos os seus ambientes de sistema, mantendo a experiência consistente seja no Desktop, Servidor, Contêiner ou WSL. Componente de runtime interativo do **Quarteto de Produtividade**.

---

### 🏛️ O Quarteto de Produtividade

[![Setup](https://img.shields.io/badge/📦_Setup-Sistema_%26_Cookbook-blue)](https://github.com/GabrielFrigo4/setup)
[![Shell](https://img.shields.io/badge/🐚_Shell-Terminal_Runtime-purple)](https://github.com/GabrielFrigo4/shell)
[![Vault](https://img.shields.io/badge/🔐_Vault-Cofre_Privado-red)](https://github.com/GabrielFrigo4/vault)
[![Profile](https://img.shields.io/badge/🎨_Profile-Dotfiles_%26_IA-green)](https://github.com/GabrielFrigo4/profile)

> 📖 **Arquitetura Unificada do Ecossistema:** Conheça a matriz completa de responsabilidades, ciclo de boot e segregação de privilégios em [ENVIRONMENT.md](ENVIRONMENT.md).
> 📜 **Princípios de Engenharia:** Conheça os 18 princípios UNIX e boas práticas Clean Code em [PRINCIPLES.md](PRINCIPLES.md).

---

### 🖥️ Sistemas, Contextos & Shells

![Linux](https://img.shields.io/badge/🐧_Linux-Supported-blue)
![FreeBSD](https://img.shields.io/badge/😈_FreeBSD-Supported-red)
![macOS](https://img.shields.io/badge/🍎_macOS-Supported-blue)
![Windows](https://img.shields.io/badge/🪟_Windows_%28MSYS2%29-Supported-purple)
![Bash](https://img.shields.io/badge/📜_bash-100%25-green)
![Zsh](https://img.shields.io/badge/⚡_zsh-100%25-blue)
![Sh](https://img.shields.io/badge/⚙️_sh-100%25-red)
[![CI](https://github.com/GabrielFrigo4/shell/actions/workflows/ci.yml/badge.svg)](https://github.com/GabrielFrigo4/shell/actions/workflows/ci.yml)

```mermaid
flowchart LR
    subgraph OS ["🖥️ Plataformas"]
        LNX["🐧 Linux"]
        BSD["😈 FreeBSD"]
        WIN["🪟 Windows (MSYS2)"]
        MAC["🍎 macOS"]
    end

    subgraph CTX ["🎯 Contextos"]
        DSK["💻 Desktop"]
        SRV["🌐 Server"]
        CNT["📦 Container"]
        WSL["🧩 WSL"]
    end

    LNX --> DSK & SRV & CNT & WSL
    BSD --> DSK & SRV & CNT
    WIN --> DSK
    MAC --> DSK
```

---

## 🚀 Instalação Rápida

O instalador aceita a flag `--context` (`desktop`, `server`, `container`, `wsl`). Se omitido, assume `desktop`.

### 🐧 Linux / 😈 FreeBSD / 🍎 macOS

```sh
sudo git clone "https://github.com/GabrielFrigo4/shell" "/usr/local/share/shell"
bash "/usr/local/share/shell/install.sh" --context desktop
```

### 🪟 Windows (MSYS2)

```sh
git clone "https://github.com/GabrielFrigo4/shell" "${HOME}/.shell"
bash "${HOME}/.shell/install.sh" --context desktop
```

---

## ⚡ Comandos Mais Usados

| Comando / Alias | Ação | Destino |
| :--- | :--- | :--- |
| `update-all` / `upall` / `u` | **Orquestrador Global:** Atualiza SO + AUR + Flatpak + Snap. | Universal |
| `update-shell` / `upsh` | Atualiza o repositório do shell (`git pull`) e recarrega a sessão. | Universal |
| `update-vault` / `upvt` | Sincroniza segredos (`~/.vault`) e recarrega chaves SSH. | Universal |
| `update-wifi` / `upwf` | Sincroniza credenciais Wi-Fi configuradas com o SO. | Linux, BSD, Windows |
| `editor [alvo]` / `e` | Abre o editor padrão configurado na cascata de prioridade. | `$VISUAL` / `$EDITOR` |
| `mount-device` / `mntdev` | Monta celular em `~/Device` via GVfs/KIO-FUSE/GSConnect/ADB. | Desktop |
| `l`, `ll`, `la`, `lt` | Listagem moderna com ícones e status git (`eza`/`exa`/`ls`). | Universal |
| `g <termo>` | Busca inteligente de texto em arquivos (`rg` > `grep`). | Universal |
| `c <arquivo>` | Visualizador formatado com syntax highlighting (`bat` > `cat`). | Universal |

> 📖 **Consulte o catálogo completo de atalhos e variáveis em [docs/ALIASES.md](docs/ALIASES.md).**

---

## 📚 Documentação Técnica Completa

Para aprofundar na arquitetura, comportamentos por contexto e motores de detecção:

- 🏛️ **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)**: Ciclo de vida da sessão interativa, cascata de sourcing e orçamento de latência (&lt;50ms).
- 🎯 **[docs/CONTEXTS.md](docs/CONTEXTS.md)**: Especificação dos perfis `desktop`, `server`, `container` e `wsl`.
- 🧠 **[docs/DETECTION.md](docs/DETECTION.md)**: Reconhecimento de SOs, famílias de distros Linux, dark mode (D-Bus/XDG Portal) e integração GTK/Qt/Electron.
- 🖌️ **[docs/THEMES.md](docs/THEMES.md)**: Contratos visuais dos prompts (Bash, Zsh, Sh), paleta ANSI e fallback para TTYs puros.
- 🗺️ **[docs/ALIASES.md](docs/ALIASES.md)**: Dicionário exaustivo de comandos públicos, atalhos e variáveis de ambiente.

---

## 📁 Estrutura do Repositório

```mermaid
flowchart TD
    RC["🐚 Arquivo RC (~/.bashrc / ~/.zshrc / ~/.shrc)"] --> LIB["📚 1. library/*.sh"]
    LIB --> CORE["⚙️ 2. core/*.sh"]
    CORE --> TGT["🎨 3. target/{OS}/{SHELL}/prompt.sh"]

    subgraph PROMPT_FLOW ["⚡ Orquestração por Sessão"]
        TGT --> THM["🖌️ theme/{SHELL}.sh"]
        TGT --> ENV["⚙️ target/{OS}/environment.sh"]
        TGT --> CTX_COM["🧩 context/{CONTEXT}/common.sh"]
        TGT --> CTX_OS["🎯 context/{CONTEXT}/{OS}.sh"]
    end
```

- 📚 **[library/](library/README.md)**: Biblioteca padrão com utilitários POSIX (`functions.sh`) e módulos analíticos (`detect.sh`).
- ⚙️ **[core/](core/README.md)**: Fundações do ambiente (`environment.sh`) e integração com segredos (`vault.sh`).
- 🎯 **[context/](context/README.md)**: Orquestrador de perfis operacionais (`desktop`, `server`, `container`, `wsl`).
- 🖌️ **[theme/](theme/README.md)**: Motores de renderização de prompts (Bash, Zsh, Sh).
- 🎨 **`target/`**: Configurações específicas por sistema operacional (`Linux`, `FreeBSD`, `MacOS`, `Windows`).
