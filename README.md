# Shell

Configurações, aliases e prompts para todos os ambientes do sistema.

## Instalação

**Linux / FreeBSD / macOS:**

```sh
sudo git clone "https://github.com/GabrielFrigo4/Shell" "/usr/local/share/shell"
sh "/usr/local/share/shell/install.sh"
```

**MSYS2 (Windows):**

```sh
git clone "https://github.com/GabrielFrigo4/Shell" "${HOME}/.shell"
sh "${HOME}/.shell/install.sh"
```

Reinicie o shell ou recarregue o RC manualmente:

```sh
. ~/.shrc
. ~/.bashrc
. ~/.zshrc
```

> O script detecta automaticamente o OS e o shell, e injeta as linhas de `source` no arquivo RC correto — tanto para o usuário atual como para o root.

## Estrutura

- **`os/`**: Prompts e aliases separados por Sistema Operacional (mantendo a experiência visual exata 1:1, como Pinguim, Demônio ou Windows).
- **`core/`**: Funções universais.
- **`context/`**: Inicializadores de ambiente (Desktop com ferramentas ricas vs Server enxuto).
