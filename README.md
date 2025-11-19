# 📘 Neovim IDE Setup – Complete Installation Guide
A full cross-platform guide for installing Neovim and configuring it with the included `init.lua` for:

**Rust, Python, JavaScript/TypeScript, Go, C, C++, C#, Java, Lua, HTML, CSS**

This setup includes:  
LSP, Treesitter, debugging (DAP), linting, formatting, file explorer, fuzzy finder, Git tools, snippets, autocomplete, outline panel, and more.

---

# 🧰 1. Install Git

## Windows
```
winget install Git.Git
```

## Linux (Debian/Ubuntu)
```
sudo apt install git
```

## Linux (Arch)
```
sudo pacman -S git
```

## macOS
```
brew install git
```

---

# 🧱 2. Install Neovim

Use **Neovim v0.11.4**  
(Newer versions currently break `:Tutor`, especially on Windows.)

## Windows (recommended)
```
winget install Neovim.Neovim --version 0.11.4
```

## Windows (manual ZIP)
Download:  
https://github.com/neovim/neovim/releases/tag/v0.11.4

Extract to:
```
C:\Program Files\Neovim
```

Ensure `C:\Program Files\Neovim\bin` is available from your shell.

## Linux (Debian/Ubuntu)
```
sudo apt remove neovim
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt install neovim
```

## Linux (Arch)
```
sudo pacman -S neovim
```

## macOS
```
brew install neovim
```

---

# 📁 3. Install Your Neovim Config

Your config directory is:

### Windows
```
C:\Users\<USER>\AppData\Local\nvim\
```

### Linux/macOS
```
~/.config/nvim/
```

Create the folder if needed:

```
mkdir -p ~/.config/nvim
```

Place **your entire `init.lua`** inside that directory.

---

# 📦 4. Install Language Toolchains

## 🦀 Rust
```
curl https://sh.rustup.rs -sSf | sh
```

Windows:
```
winget install Rustlang.Rustup
```

Rust tools:
```
rustup component add rust-analyzer
rustup component add clippy
rustup component add rustfmt
```

---

## 🐍 Python

### Windows
```
winget install Python.Python.3.13
```

### Linux
```
sudo apt install python3 python3-pip
```

### macOS
```
brew install python
```

Formatters/linters:
```
pip install ruff black
```

---

## 🌐 JavaScript / TypeScript

Node.js:

### Windows
```
winget install OpenJS.NodeJS
```

### Linux/macOS
```
curl -fsSL https://fnm.vercel.app/install | bash
fnm install --lts
```

JS tools:
```
npm install -g eslint_d prettier
```

---

## 🐹 Go
```
winget install GoLang.Go
```

Linux/macOS:
```
brew install go
```

Linter:
```
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

---

## 🧰 C / C++

### Windows
Download LLVM:
https://github.com/llvm/llvm-project/releases

### Linux
```
sudo apt install clangd clang-format clang-tidy
```

### macOS
```
brew install llvm
```

---

## ☕ Java

Windows:
```
winget install EclipseAdoptium.Temurin.17.JDK
```

Linux/macOS:
```
sudo apt install default-jdk
```

---

## 🧩 C#

### Windows
```
winget install Microsoft.DotNet.SDK.8
```

### Linux/macOS
```
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
bash dotnet-install.sh --channel 8.0
```

---

# 🎯 5. Install Debuggers (DAP)

## Rust / C / C++ — codelldb

Windows:  
https://github.com/vadimcn/vscode-lldb/releases

macOS:
```
brew install codelldb
```

Python:
```
pip install debugpy
```

Go:
```
go install github.com/go-delve/delve/cmd/dlv@latest
```

---

# 🚀 6. Install Neovim Plugins

Open Neovim:

```
nvim
```

Run:

```
:Lazy sync
```

This installs:

- LSP servers  
- Treesitter  
- Formatters  
- Linters  
- DAP UI  
- Rust tools  
- Telescope  
- NvimTree  
- Git signs + fugitive  
- Autocomplete  
- Snippets  
- Everything else  

---

# 🎨 7. Keybindings Overview

## File Explorer
```
Ctrl + n → Toggle tree
```

## Search (Telescope)
```
Space ff → files
Space fg → grep
Space fb → buffers
```

## LSP
```
K        → Hover
gd       → Go to definition
gr       → References
Space rn → Rename
Space ca → Code action
```

## Formatting
```
:Format     → Format current file
Space f     → Format (keymap)
```

## Linting
```
Space ll → Lint
```

## Debugger
```
F5      → Continue
F10     → Step over
F11     → Step into
F12     → Step out
Space b → Breakpoint
```

## Outline Panel
```
Space o → Aerial toggle
```

---

# 📘 8. Neovim Tutorial

If using **Neovim 0.11.4**:

```
:Tutor
```

Docs version:
```
:help pi_tutor
```

---

# 🔧 9. Maintenance

```
:Lazy sync     → update plugins
:TSUpdate      → update Treesitter
:Mason         → view LSP tools
```

---

# 🎉 Done!

This README contains everything needed to rebuild your full Neovim IDE on any system (Windows, Linux, macOS).
