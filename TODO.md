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

## ✅ Marcos Concluídos

### 🍎 Expansão de Plataformas & Shells

- [x] **Dash Shell (Descartado):** Avaliação concluída. O Dash adota estritamente a BNF POSIX Issue 7 que rejeita caracteres hífen (`-`) em identificadores de funções (`kebab-case`), inviabilizando comandos centrais como `update-all` e `bench-shell`. Documentado no [PRINCIPLES.md](PRINCIPLES.md) e [README.md](README.md).
- [x] **Fish Shell (Descartado):** Avaliação concluída. O Fish utiliza linguagem própria incompatível com POSIX (`set` em vez de `export`, impossibilidade de `source` em scripts `.sh`). Descartado pelo mesmo motivo do Dash: incompatibilidade estrutural com a arquitetura POSIX do projeto. Documentado no [PRINCIPLES.md](PRINCIPLES.md) e [README.md](README.md).

### 🧩 Contextos Avançados

- [x] **Container (`context/container/`):** Utilitários POSIX leves para introspecção de contêineres (`cid`, `cip`, `cuptime`, `cenv`, `chost`). Detecção de runtime (Docker, Kubernetes, Jail) em Linux e FreeBSD. Inspector de processos (`cprocs`) com fallback para imagens mínimas sem `ps`.
- [x] **Servidor (`context/server/`):** Funções com cascata universal de fallback — `ports` (ss > netstat > sockstat), `conns` (conexões ativas), `logs` (journalctl > /var/log/messages > syslog), `services` (systemctl > service > rc-status). Utilitários por OS: `duse` (disco), `muse` (memória) e `logsearch` (busca em logs).

### ⚡ Engenharia de Performance & Latência de Boot (< 32ms)

Diagnóstico detalhado e plano de ação estruturado com base no profiling em tempo real do benchmark (`bsh` / `Shell/scripts/benchmark.sh`):

#### 📊 Diagnóstico de Latência (Pós-Otimização)

| Componente               | Latência Estimada | Status (< 32ms) |    Cor     | Diagnóstico & Solução Aplicada                            |
| :----------------------- | :---------------: | :-------------: | :--------: | :-------------------------------------------------------- |
| **`sh` (interativo)**    |    **~2.8ms**     |     `PASS`      |  🟢 Verde  | Inicialização nativa POSIX sem wrappers pesados.          |
| **`Vault Sourcing`**     |    **~8.5ms**     |     `PASS`      |  🟢 Verde  | Carregamento otimizado via globbing nativo (`vault.sh`).  |
| **`Shell Core`**         |    **~20.0ms**    |     `PASS`      |  🟢 Verde  | Variáveis de ambiente, helpers e biblioteca base.         |
| **`Shell Stack (bash)`** |     **~30ms**     |     `PASS`      |  🟢 Verde  | Lazy evaluation: ~27 `command -v` removidos do boot.      |
| **`Shell Stack (zsh)`**  |     **~30ms**     |     `PASS`      |  🟢 Verde  | Lazy evaluation: ~27 `command -v` removidos do boot.      |
| **`bash` (interativo)**  |    **~100ms**     |     `WARN`      | 🟡 Amarelo | Oh-My-Bash otimizado (plugins/completions enxutos).       |
| **`zsh` (interativo)**   |    **~150ms**     |     `WARN`      | 🟡 Amarelo | Oh-My-Zsh otimizado (`ZSH_DISABLE_COMPFIX` + `zcompile`). |

#### 🔍 Soluções Aplicadas

1. **`Shell Stack` agora 100% VERDE (~30ms):**
    - **Solução:** Arquitetura de Duas Zonas para `command -v` (documentada no [PRINCIPLES.md](PRINCIPLES.md), Regra 8). Funções operacionais (editores, utilitários, package managers) definidas incondicionalmente com validação lazy em tempo de execução. ~27 `command -v` removidos do boot em `context/desktop/common.sh`, `library/functions.sh`, `core/environment.sh`, `context/wsl/linux.sh`, `context/desktop/macos.sh`, `context/desktop/windows.sh` e `context/desktop/freebsd.sh`.

2. **Oh-My-Zsh otimizado (~150ms):**
    - **Solução:** `ZSH_DISABLE_COMPFIX="true"` elimina auditoria síncrona de permissões. Compilação de cache `.zcompdump.zwc` via `zcompile` no `install.sh`.

3. **Oh-My-Bash otimizado (~100ms):**
    - **Solução:** Plugins e completions enxutos (`completions=(git ssh)`, `aliases=(general)`, `plugins=(bashmarks)`) no template `~/.bashrc`.

4. **Modo Universal Shell Puro (Zero Overhead & Templates Standalone):**
    - **Solução:** Suporte à flag `--pure` / `--no-framework` no `install.sh` e `reinstall-shell` (`resh`) com propagação via `SHELL_PURE=1`. Gera arquivos base elegantes e limpos para `~/.bashrc` e `~/.zshrc` (guards de interatividade, opções de histórico, completamentos nativos e compinit compilado) sem depender de frameworks externos, integrando cache em memória (`_DETECTED_*`) e fast-path em tmpfs (`$XDG_RUNTIME_DIR/.shell_color_scheme`).

#### 📋 Itens Concluídos

- [x] **Otimização de `context/desktop/common.sh` (Meta: Shell Stack < 32ms):**
    - [x] Remover testes preventivos de `command -v` em editores e utilitários de desktop.
    - [x] Implementar wrappers sob demanda (verificação em tempo de execução na invocação do comando).
- [x] **Otimizações do Oh-My-Zsh no `Profile` / `install.sh`:**
    - [x] Configurar `ZSH_DISABLE_COMPFIX="true"` no template `~/.zshrc`.
    - [x] Adicionar compilação de cache `.zcompdump.zwc` via `zcompile`.
- [x] **Otimizações do Oh-My-Bash no `Profile` / `install.sh`:**
    - [x] Otimizar lista padrão de completions e plugins em `~/.bashrc`.
- [x] **Modo Universal Shell Puro (Zero Overhead):**
    - [x] Disponibilizar opção de rodar o Universal Shell sem carregar os frameworks Oh-My-*, garantindo boot interativo em **~18ms a 22ms** (100% VERDE).

---

> [!TIP]
> Para detalhes sobre convenções de código e diretrizes de contribuição, consulte [PRINCIPLES.md](PRINCIPLES.md).
