# 🐚 Universal Shell — AI Agent Briefing

> Configurações, aliases e prompts centralizados para todos os ambientes de sistema, mantendo a experiência consistente seja no Desktop, Servidor, Contêiner ou WSL. Componente de runtime interativo do **Quarteto de Produtividade**.

---

## 🧭 Identidade e Papel

O **Shell** é o **motor interativo de terminal** do ecossistema. Fornece prompts ultra-rápidos (< 50ms), aliases universais, funções POSIX e cascatas de ferramentas. Suporta:

- **Shells:** Bash, Zsh e POSIX `sh` (FreeBSD `/bin/sh` como baseline)
- **Contextos:** `desktop`, `server`, `container`, `wsl`
- **Plataformas:** Linux, FreeBSD, macOS, Windows (MSYS2)

---

## ⚠️ Regras Críticas para Agentes de IA

1. **Baseline FreeBSD `/bin/sh`:** Scripts compartilhados DEVEM ser compatíveis com o `/bin/sh` do FreeBSD.
2. **Programação defensiva (`command -v`):** Nunca defina aliases sem verificar se o binário existe.
3. **Nomenclatura:** `kebab-case` público, `_snake_case` privado, `SNAKE_CASE` constantes.
4. **Proteção de terminal:** `[ -t 1 ]` antes de sequências ANSI em pipes.
5. **Zero comentários narrativos:** Blocos lógicos separados por linhas em branco.
6. **Prompts com `\[...\]`:** Códigos ANSI em `PS1` DEVEM estar entre delimitadores de largura zero.

---

## 📖 Referências Obrigatórias

- **[ENVIRONMENT.md](ENVIRONMENT.md)**: Arquitetura do Quarteto de Produtividade
- **[PRINCIPLES.md](PRINCIPLES.md)**: Princípios de Engenharia do Shell
- **[.agents/rules/principles.md](.agents/rules/principles.md)**: Regras específicas do Shell
- **[.agents/skills/](.agents/skills/)**: Runbooks operacionais (`universal-shell`, `proactive-guardian`, `deep-investigation`)
