# 🐛 WORMAZE

Um jogo da minhoca no labirinto feito em LÖVE2D (Lua).

![Build Status](https://github.com/Shuslozz/wormaze/workflows/Build%20WORMAZE%20APK/badge.svg)

## 🎮 Como Jogar

- **PC**: Use WASD ou setas do teclado para mover a minhoca
- **Mobile**: Use os controles touch na tela
- **Objetivo**: Navegue pelos labirintos infinitos e encontre a saída vermelha!

## ✨ Features

- 🎨 **6 Temas Visuais**: Clássico, Floresta, Oceano, Deserto, Neon e Candy
- 📱 **Mobile-Friendly**: Controles touch e interface adaptável
- 🏗️ **Labirintos Infinitos**: Geração procedural de labirintos únicos
- 🎵 **Animações Suaves**: Título animado e efeitos visuais
- ⚙️ **Configurável**: Escolha entre WASD ou setas do teclado

## 🚀 Download

### Android APK
Baixe a versão mais recente na seção [Releases](https://github.com/SEU_USUARIO/wormaze/releases) ou nos [Actions](https://github.com/SEU_USUARIO/wormaze/actions).

### PC (LÖVE2D)
1. Instale o [LÖVE2D](https://love2d.org/)
2. Baixe o código fonte
3. Execute: `love .`

## 🛠️ Desenvolvimento

### Estrutura do Projeto
```
wormaze/
├── main.lua              # Código principal do jogo
├── conf.lua              # Configurações do LÖVE2D
├── README.md             # Este arquivo
└── .github/workflows/    # CI/CD automático
    └── build-apk.yml
```

### Build Automático
O projeto usa GitHub Actions para compilar automaticamente o APK a cada commit.

### Como Contribuir
1. Fork o projeto
2. Crie uma branch: `git checkout -b minha-feature`
3. Commit suas mudanças: `git commit -m 'Adiciona nova feature'`
4. Push: `git push origin minha-feature`
5. Abra um Pull Request

## 📱 Compatibilidade

- **Android**: 4.1+ (API 16+)
- **PC**: Windows, Linux, macOS
- **Engine**: LÖVE2D 11.4+

## 🎨 Capturas de Tela

_Em breve..._

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 🙏 Créditos

- Feito com [LÖVE2D](https://love2d.org/)
- Inspirado nos clássicos jogos de minhoca
- Build automático via GitHub Actions
