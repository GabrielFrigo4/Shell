# 🎯 context/ — Orquestração por Contexto de Uso

Esta pasta gerencia as especializações dinâmicas do **Universal Shell Environment** de acordo com a carga de trabalho ativa da máquina (`SHELL_CONTEXT`).

---

## 📁 Estrutura de Contextos

- 💻 **`desktop/`**: Estação de trabalho gráfica (Linux/FreeBSD/macOS/Windows MSYS2) com editores de código (`nvim`, `code`, `zed`), atalhos de janelas Wayland/X11 e montagem de smartphones (`mount-device`).
- 🌐 **`server/`**: Máquinas de produção e servidores dedicados com aliases rápidos para administração de rede, serviços e logs.
- 📦 **`container/`**: Contêineres de microsserviços e jails (Incus, Docker, Bastille) com carregamento ultraleve e comandos mínimos.
- 🧩 **`wsl/`**: Ambientes WSL2 integrados com o Windows nativo (`clip`, `explorer.exe`, `powershell`).

---

## ⚙️ Contrato de Arquitetura em Duas Camadas

Dentro de cada contexto:

1. **`common.sh`**: Sourced primeiro. Exporta aliases e variáveis genéricas do contexto, independentes do sistema operacional.
2. **`{OS}.sh`** (ex: `Linux.sh`, `FreeBSD.sh`): Sourced em seguida. Adiciona comandos ou wrappers que utilizam binários exclusivos daquele kernel ou plataforma.

Consulte mais detalhes em **[docs/CONTEXTS.md](../docs/CONTEXTS.md)**.
