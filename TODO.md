# 🗺️ Roadmap & Backlog

> Planejamento estratégico, marcos entregues e visão de futuro para a evolução do **Universal Shell**.

---

## 📊 Status do Projeto

| Área                     |   Status   | Cobertura                                                           |
| :----------------------- | :--------: | :------------------------------------------------------------------ |
| **🖥️ Plataformas Base**  | 🟢 Estável | Linux, FreeBSD, Windows (MSYS2), macOS (base)                       |
| **🐚 Shells Nativos**    | 🟢 Estável | Bash, Zsh, POSIX sh (Linux & FreeBSD)                               |
| **🎯 Contextos**         | 🟢 Estável | Desktop, Server, Container, WSL                                     |
| **🎨 Temas & TTY**       | 🟢 Estável | Adaptação dinâmica PTY / Raw TTY em Zsh, Bash e Sh                  |
| **⚡ Modern CLI**        | 🟢 Estável | Cascata inteligente (`eza`, `bat`, `rg`, `fd` > nativos)            |
| **🌳 VCS & Prompts**     | 🟢 Estável | Git e Got (Game of Trees)                                           |
| **💎 Clean Code**        |  🟢 100%   | 18 Princípios UNIX & Taxonomia de 3 níveis de biblioteca            |
| **🧪 Automação & CI/CD** | 🟢 Estável | Git Hooks locais (`.githooks/pre-commit`) + GitHub Actions multi-OS |

---

## 🎯 Próximos Passos (Backlog Ativo)

### 🍎 Expansão de Plataformas & Shells

- [ ] **Fish Shell (Exploratório):** Avaliação de suporte opcional ao Fish (`fish_prompt`, funções e completions nativos).

### 🧩 Contextos Avançados

- [ ] **Container (`context/container/`):** Otimizações específicas para Docker, Podman e Jails (desativação de timers pesados e polling de disco).
- [ ] **Servidor (`context/server/`):** Utilitários rápidos para inspeção de portas abertas (`ports`), monitoramento de logs em tempo real (`logs`) e status de serviços (`services`).

### ⚡ Engenharia de Performance & Latência de Boot (< 32ms)

Diagnóstico detalhado e plano de ação estruturado com base no profiling em tempo real do benchmark (`bsh` / `Shell/scripts/benchmark.sh`):

#### 📊 Diagnóstico de Latência Atual (Baseline)

| Componente               | Latência Medida | Status (<32ms) |     Cor     | Diagnóstico & Causa Raiz                                      |
| :----------------------- | :-------------: | :------------: | :---------: | :------------------------------------------------------------ |
| **`sh` (interativo)**    |    **2.8ms**    |     `PASS`     |  🟢 Verde   | Inicialização nativa POSIX sem wrappers pesados.              |
| **`Vault Sourcing`**     |    **8.5ms**    |     `PASS`     |  🟢 Verde   | Carregamento otimizado via globbing nativo (`vault.sh`).      |
| **`Shell Core`**         |   **20.0ms**    |     `PASS`     |  🟢 Verde   | Variáveis de ambiente, helpers e biblioteca base.             |
| **`Shell Stack (bash)`** |   **58.3ms**    |     `WARN`     | 🟡 Amarelo  | Ecossistema completo no Bash (impactado por `common.sh`).     |
| **`Shell Stack (zsh)`**  |   **60.6ms**    |     `WARN`     | 🟡 Amarelo  | Ecossistema completo no Zsh (impactado por `common.sh`).      |
| **`bash` (interativo)**  |   **167.7ms**   |     `SLOW`     | 🔴 Vermelho | **Overhead do Oh-My-Bash (~109ms):** sourcing de >20 scripts. |
| **`zsh` (interativo)**   |   **294.2ms**   |     `SLOW`     | 🔴 Vermelho | **Overhead do Oh-My-Zsh (~234ms):** `compaudit` e `compinit`. |

#### 🔍 Causas Raízes Identificadas

1. **`Shell Stack` no Amarelo (~58ms a 60ms):**
    - **Gargalo:** O módulo `Shell/context/desktop/common.sh` consome sozinho **~27.7ms** no boot.
    - **Origem:** Executa mais de 40 chamadas `command -v` em disco (`nvim`, `vim`, `hx`, `micro`, `code`, `emacs`, etc.) para verificar a existência de ferramentas antes de definir aliases e funções.
    - **Solução Planejada:** Eliminar as checagens prévias no boot. Definir funções e aliases diretamente em memória (custo de 0.001ms) e validar o comando apenas em tempo de execução (lazy evaluation), derrubando o Shell Stack para **~18ms** (100% VERDE).

2. **Oh-My-Zsh no Vermelho (~294ms):**
    - **Gargalo:** Auditoria de permissões síncrona de diretórios (`compaudit`) e recarga de completações.
    - **Solução Planejada:** Ativar `ZSH_DISABLE_COMPFIX="true"` e compilação de dump com `zcompile ~/.zcompdump*`.

3. **Oh-My-Bash no Vermelho (~167ms):**
    - **Gargalo:** Loops síncronos de sourcing de dezenas de bibliotecas, completions e aliases genéricos.
    - **Solução Planejada:** Enxugar plugins e completions desnecessários e desacoplar módulos secundários.

#### 📋 Plano de Ação (Backlog de Otimizações)

- [ ] **Otimização de `context/desktop/common.sh` (Meta: Shell Stack < 32ms):**
    - [ ] Remover testes preventivos de `command -v` em editores e utilitários de desktop.
    - [ ] Implementar wrappers sob demanda (verificação em tempo de execução na invocação do comando).
- [ ] **Otimizações do Oh-My-Zsh no `Profile` / `install.sh`:**
    - [ ] Configurar `ZSH_DISABLE_COMPFIX="true"` no template `~/.zshrc`.
    - [ ] Adicionar compilação de cache `.zcompdump.zwc` via `zcompile`.
    - [ ] Avaliar `compinit -C` para reutilização segura de cache de autocompletion.
- [ ] **Otimizações do Oh-My-Bash no `Profile` / `install.sh`:**
    - [ ] Otimizar lista padrão de completions e plugins em `~/.bashrc`.
- [ ] **Modo Universal Shell Puro (Zero Overhead):**
    - [ ] Disponibilizar opção de rodar o Universal Shell sem carregar os frameworks Oh-My-*, garantindo boot interativo em **~18ms a 22ms** (100% VERDE).

---

> [!TIP]
> Para detalhes sobre convenções de código e diretrizes de contribuição, consulte [PRINCIPLES.md](PRINCIPLES.md).
