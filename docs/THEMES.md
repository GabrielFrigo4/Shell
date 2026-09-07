# 🖌️ Design do Prompt & Sistema Visual (`theme/`)

O subsistema de temas do **Universal Shell Environment** entrega um prompt informativo, compacto e de carregamento instantâneo, unificando a identidade visual entre Bash, Zsh e POSIX Sh.

---

## 🎨 Estrutura Visual do Prompt

O prompt é desenhado em linha única ou duas linhas dependendo do shell, otimizado para não roubar espaço horizontal útil da tela:

```text
user@hostname:~/projects/myapp (main ✗) $
```

### Componentes Visuais:
1. **Identificador de Usuário e Host:**
   - Usuário comum: Exibido em tom suave (azul ou ciano).
   - Usuário `root`: Destacado em vermelho para alertar sobre privilégios de superusuário.
2. **Diretório Atual (`PWD`):**
   - Diretórios abreviados com base no `$HOME` (`~`).
   - Cores de contraste para rápida localização do caminho.
3. **Status de Controle de Versão (Git / Got):**
   - **Nome da Branch:** Exibido entre parênteses quando o diretório for um repositório versionado.
   - **Símbolo de Estado Limpo (`✓`):** Verde quando não há arquivos modificados ou untracked.
   - **Símbolo de Estado Modificado (`✗` / `*`):** Amarelo/Vermelho quando há alterações pendentes.
4. **Símbolo de Prompt Terminal:**
   - `$` para usuários comuns.
   - `#` para sessões com privilégios de `root`.

---

## ⚡ Implementação por Shell

### 1. Zsh (`theme/zsh.sh`)
- Utiliza o módulo nativo `vcs_info` do Zsh.
- Renderização de cores através do sistema de expansão `%F{color}...%f`.
- Suporte a Zstyle nativo para autocompletion colorido e menu interativo.

### 2. Bash (`theme/bash.sh`)
- Utiliza sequências de escape ANSI embutidas entre `\[` e `\]` para garantir que o Bash calcule corretamente a largura da linha e evite quebras de texto ao navegar pelo histórico.
- Helper assíncrono ou atômico para leitura rápida de branch Git via `git symbolic-ref` / `git rev-parse`.

### 3. POSIX Sh (`theme/sh.sh`)
- Implementação estrita para `/bin/sh` (FreeBSD / Dash / BusyBox).
- Utiliza a variável `$PS1` padrão do POSIX com sequências de escape literais, sem extensões não-padronizadas.

---

## 📟 Fallback Resiliente em TTY Bruto

Ao inicializar uma máquina diretamente em um console TTY de emergência (sem servidor gráfico ou driver de fonte carregado) ou em uma conexão de console serial:
- **Detecção de TTY Puro:** Se `$TERM` for `linux`, `vt100` ou similar sem suporte a glifos Nerd Fonts, o tema desativa automaticamente ícones complexos.
- **Substituição de Caracteres:** Glifos Unicode são substituídos por equivalentes ASCII simples (`*`, `!`, `>`), garantindo que o prompt nunca exiba caracteres corrompidos (*mojibake* ou caixas vazias).
