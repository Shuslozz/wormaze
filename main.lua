-- WORMAZE - Jogo da Minhoca no Labirinto
-- Criado para LÖVE2D (Love2D)

-- Configurações globais
local TILE_SIZE = 32
local MAZE_WIDTH = 25
local MAZE_HEIGHT = 19
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600

-- Estados do jogo
local gameState = "menu" -- menu, settings, wormSelect, playing, gameOver

-- Variáveis do menu
local menuOptions = {"Jogar", "Configurações", "Seleção de Minhocas", "Loja"}
local selectedOption = 1
local titleAnimation = {
    letters = {"W", "O", "R", "M", "A", "Z", "E"},
    bounceHeight = {},
    bounceSpeed = {},
    time = 0
}

-- Configurações
local controls = "wasd" -- wasd ou arrows
local selectedWorm = 1
local currentTheme = 1

-- Sistema de temas
local themes = {
    {
        name = "Clássico",
        wall = {0.2, 0.3, 0.5},
        path = {0.95, 0.95, 0.98},
        bg = {0.08, 0.12, 0.2},
        exit = {0.9, 0.2, 0.3}
    },
    {
        name = "Floresta",
        wall = {0.1, 0.4, 0.1},
        path = {0.8, 0.9, 0.7},
        bg = {0.05, 0.15, 0.05},
        exit = {0.8, 0.6, 0.2}
    },
    {
        name = "Oceano",
        wall = {0.1, 0.3, 0.6},
        path = {0.7, 0.9, 0.95},
        bg = {0.05, 0.1, 0.2},
        exit = {0.9, 0.4, 0.1}
    },
    {
        name = "Deserto",
        wall = {0.6, 0.4, 0.2},
        path = {0.95, 0.9, 0.7},
        bg = {0.2, 0.15, 0.08},
        exit = {0.8, 0.1, 0.1}
    },
    {
        name = "Neon",
        wall = {0.8, 0.1, 0.8},
        path = {0.1, 0.1, 0.1},
        bg = {0.05, 0.05, 0.05},
        exit = {0.1, 0.9, 0.9}
    },
    {
        name = "Candy",
        wall = {0.9, 0.4, 0.7},
        path = {0.95, 0.9, 0.95},
        bg = {0.15, 0.05, 0.15},
        exit = {0.2, 0.8, 0.2}
    }
}

-- Cores base
local colors = {
    worm = {0.2, 0.8, 0.3},
    wormHead = {0.1, 0.6, 0.2},
    menuBg = {0.02, 0.05, 0.12},
    menuSelected = {0.3, 0.6, 0.9},
    menuText = {0.95, 0.95, 0.95},
    menuCard = {0.08, 0.12, 0.2},
    menuBorder = {0.2, 0.4, 0.7},
    closeX = {0.8, 0.3, 0.3}
}

-- Variáveis do jogo
local worm = {}
local maze = {}
local level = 1
local gameStarted = false

-- Variáveis para mobile
local isMobile = false
local touchControls = {
    up = {x = SCREEN_WIDTH/2 - 30, y = SCREEN_HEIGHT - 120, w = 60, h = 30},
    down = {x = SCREEN_WIDTH/2 - 30, y = SCREEN_HEIGHT - 60, w = 60, h = 30},
    left = {x = SCREEN_WIDTH/2 - 90, y = SCREEN_HEIGHT - 90, w = 30, h = 60},
    right = {x = SCREEN_WIDTH/2 + 30, y = SCREEN_HEIGHT - 90, w = 30, h = 60}
}

-- Inicialização do título animado
function initTitleAnimation()
    for i = 1, #titleAnimation.letters do
        titleAnimation.bounceHeight[i] = 0
        titleAnimation.bounceSpeed[i] = math.random(3, 6)
    end
end

-- Função para desenhar retângulos com cantos arredondados
function drawRoundedRect(x, y, w, h, r)
    love.graphics.rectangle("fill", x + r, y, w - 2*r, h)
    love.graphics.rectangle("fill", x, y + r, w, h - 2*r)
    love.graphics.circle("fill", x + r, y + r, r)
    love.graphics.circle("fill", x + w - r, y + r, r)
    love.graphics.circle("fill", x + r, y + h - r, r)
    love.graphics.circle("fill", x + w - r, y + h - r, r)
end

-- Função para desenhar X de fechar
function drawCloseX(x, y, size)
    love.graphics.setColor(colors.closeX)
    love.graphics.setLineWidth(3)
    love.graphics.line(x, y, x + size, y + size)
    love.graphics.line(x + size, y, x, y + size)
    love.graphics.setLineWidth(1)
end

-- Geração de labirinto usando algoritmo de backtracking
function generateMaze(width, height)
    local maze = {}
    
    -- Inicializar com todas as paredes
    for y = 1, height do
        maze[y] = {}
        for x = 1, width do
            maze[y][x] = 1 -- 1 = parede, 0 = caminho
        end
    end
    
    local stack = {}
    local current = {x = 2, y = 2}
    maze[current.y][current.x] = 0
    
    local directions = {{0, -2}, {2, 0}, {0, 2}, {-2, 0}}
    
    while true do
        local neighbors = {}
        
        -- Encontrar vizinhos não visitados
        for _, dir in ipairs(directions) do
            local nx, ny = current.x + dir[1], current.y + dir[2]
            if nx > 1 and nx < width and ny > 1 and ny < height and maze[ny][nx] == 1 then
                table.insert(neighbors, {x = nx, y = ny, wallX = current.x + dir[1]/2, wallY = current.y + dir[2]/2})
            end
        end
        
        if #neighbors > 0 then
            -- Escolher um vizinho aleatório
            local next = neighbors[math.random(#neighbors)]
            
            -- Remover a parede entre atual e próximo
            maze[next.wallY][next.wallX] = 0
            maze[next.y][next.x] = 0
            
            -- Adicionar atual à pilha
            table.insert(stack, current)
            current = {x = next.x, y = next.y}
        elseif #stack > 0 then
            -- Voltar na pilha
            current = table.remove(stack)
        else
            break
        end
    end
    
    -- Garantir que há uma saída
    maze[height-1][width-1] = 2 -- 2 = saída
    
    return maze
end

-- Inicializar minhoca
function initWorm()
    worm = {
        segments = {{x = 2, y = 2}, {x = 2, y = 2}, {x = 2, y = 2}},
        direction = {x = 0, y = 0},
        nextDirection = {x = 0, y = 0}
    }
end

-- Verificar se a posição é válida para a minhoca
function isValidPosition(x, y)
    if x < 1 or x > MAZE_WIDTH or y < 1 or y > MAZE_HEIGHT then
        return false
    end
    return maze[y][x] ~= 1
end

-- Mover minhoca
function moveWorm()
    if worm.nextDirection.x ~= 0 or worm.nextDirection.y ~= 0 then
        -- Verificar se pode mudar de direção
        local headX = worm.segments[1].x + worm.nextDirection.x
        local headY = worm.segments[1].y + worm.nextDirection.y
        
        if isValidPosition(headX, headY) then
            worm.direction = {x = worm.nextDirection.x, y = worm.nextDirection.y}
            worm.nextDirection = {x = 0, y = 0}
        end
    end
    
    if worm.direction.x == 0 and worm.direction.y == 0 then
        return
    end
    
    local newHead = {
        x = worm.segments[1].x + worm.direction.x,
        y = worm.segments[1].y + worm.direction.y
    }
    
    -- Verificar colisão com paredes
    if not isValidPosition(newHead.x, newHead.y) then
        return
    end
    
    -- Verificar colisão consigo mesma
    for i = 1, #worm.segments do
        if worm.segments[i].x == newHead.x and worm.segments[i].y == newHead.y then
            gameState = "gameOver"
            return
        end
    end
    
    -- Mover minhoca
    table.insert(worm.segments, 1, newHead)
    table.remove(worm.segments, #worm.segments)
    
    -- Verificar se chegou na saída
    if maze[newHead.y][newHead.x] == 2 then
        level = level + 1
        maze = generateMaze(MAZE_WIDTH, MAZE_HEIGHT)
        initWorm()
    end
end

-- Verificar toque nos controles mobile
function checkTouchControls(x, y)
    for direction, button in pairs(touchControls) do
        if x >= button.x and x <= button.x + button.w and 
           y >= button.y and y <= button.y + button.h then
            if direction == "up" then
                worm.nextDirection = {x = 0, y = -1}
            elseif direction == "down" then
                worm.nextDirection = {x = 0, y = 1}
            elseif direction == "left" then
                worm.nextDirection = {x = -1, y = 0}
            elseif direction == "right" then
                worm.nextDirection = {x = 1, y = 0}
            end
            return true
        end
    end
    return false
end

-- Verificar clique no X de fechar
function checkCloseButton(x, y, buttonX, buttonY, size)
    return x >= buttonX and x <= buttonX + size and y >= buttonY and y <= buttonY + size
end

function love.load()
    -- Auto-detectar resolução para mobile
    SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()
    
    -- Ajustar para diferentes resoluções
    if SCREEN_WIDTH < 800 then
        TILE_SIZE = math.max(16, math.floor(SCREEN_WIDTH / 30))
        MAZE_WIDTH = math.floor(SCREEN_WIDTH / TILE_SIZE) - 2
        MAZE_HEIGHT = math.floor((SCREEN_HEIGHT - 100) / TILE_SIZE) - 2
    end
    
    love.window.setTitle("WORMAZE")
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Detectar mobile (aproximado)
    isMobile = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
    
    -- Atualizar posições dos controles touch para a nova resolução
    if isMobile then
        touchControls = {
            up = {x = SCREEN_WIDTH/2 - 30, y = SCREEN_HEIGHT - 120, w = 60, h = 30},
            down = {x = SCREEN_WIDTH/2 - 30, y = SCREEN_HEIGHT - 60, w = 60, h = 30},
            left = {x = SCREEN_WIDTH/2 - 90, y = SCREEN_HEIGHT - 90, w = 30, h = 60},
            right = {x = SCREEN_WIDTH/2 + 30, y = SCREEN_HEIGHT - 90, w = 30, h = 60}
        }
    end
    
    initTitleAnimation()
    maze = generateMaze(MAZE_WIDTH, MAZE_HEIGHT)
    initWorm()
    
    -- Timer para movimento da minhoca
    moveTimer = 0
    moveInterval = 0.15
end

function love.update(dt)
    titleAnimation.time = titleAnimation.time + dt
    
    -- Atualizar animação do título
    for i = 1, #titleAnimation.letters do
        local delay = (i - 1) * 0.1
        titleAnimation.bounceHeight[i] = math.sin((titleAnimation.time + delay) * titleAnimation.bounceSpeed[i]) * 10
    end
    
    if gameState == "playing" then
        moveTimer = moveTimer + dt
        if moveTimer >= moveInterval then
            moveTimer = 0
            moveWorm()
        end
    end
end

function love.keypressed(key)
    if gameState == "menu" then
        if key == "up" or key == "w" then
            selectedOption = selectedOption - 1
            if selectedOption < 1 then selectedOption = #menuOptions end
        elseif key == "down" or key == "s" then
            selectedOption = selectedOption + 1
            if selectedOption > #menuOptions then selectedOption = 1 end
        elseif key == "return" or key == "space" then
            if selectedOption == 1 then -- Jogar
                gameState = "playing"
                level = 1
                maze = generateMaze(MAZE_WIDTH, MAZE_HEIGHT)
                initWorm()
            elseif selectedOption == 2 then -- Configurações
                gameState = "settings"
            elseif selectedOption == 3 then -- Seleção de Minhocas
                gameState = "wormSelect"
            elseif selectedOption == 4 then -- Loja
                -- Implementar depois
            end
        end
    elseif gameState == "settings" then
        if key == "escape" then
            gameState = "menu"
        elseif key == "1" then
            controls = "wasd"
        elseif key == "2" then
            controls = "arrows"
        elseif key == "3" or key == "4" or key == "5" or key == "6" or key == "7" or key == "8" then
            currentTheme = tonumber(key) - 2
            if currentTheme > #themes then currentTheme = #themes end
        end
    elseif gameState == "wormSelect" then
        if key == "escape" then
            gameState = "menu"
        elseif key == "1" then
            selectedWorm = 1
        end
    elseif gameState == "playing" then
        -- Controles baseados na configuração
        if controls == "wasd" then
            if key == "w" then
                worm.nextDirection = {x = 0, y = -1}
            elseif key == "s" then
                worm.nextDirection = {x = 0, y = 1}
            elseif key == "a" then
                worm.nextDirection = {x = -1, y = 0}
            elseif key == "d" then
                worm.nextDirection = {x = 1, y = 0}
            end
        else -- arrows
            if key == "up" then
                worm.nextDirection = {x = 0, y = -1}
            elseif key == "down" then
                worm.nextDirection = {x = 0, y = 1}
            elseif key == "left" then
                worm.nextDirection = {x = -1, y = 0}
            elseif key == "right" then
                worm.nextDirection = {x = 1, y = 0}
            end
        end
        
        if key == "escape" then
            gameState = "menu"
        end
    elseif gameState == "gameOver" then
        if key == "return" or key == "space" then
            gameState = "menu"
        end
    end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if gameState == "playing" then
        checkTouchControls(x, y)
    elseif gameState == "settings" then
        -- Verificar X de fechar
        if checkCloseButton(x, y, SCREEN_WIDTH - 40, 10, 30) then
            gameState = "menu"
        end
    elseif gameState == "wormSelect" then
        -- Verificar X de fechar
        if checkCloseButton(x, y, SCREEN_WIDTH - 40, 10, 30) then
            gameState = "menu"
        end
    end
end

function love.draw()
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "settings" then
        drawSettings()
    elseif gameState == "wormSelect" then
        drawWormSelect()
    elseif gameState == "playing" then
        drawGame()
    elseif gameState == "gameOver" then
        drawGameOver()
    end
end

function drawMenu()
    -- Fundo com gradiente
    for i = 0, SCREEN_HEIGHT do
        local intensity = 0.02 + (i / SCREEN_HEIGHT) * 0.08
        love.graphics.setColor(intensity, intensity * 1.2, intensity * 2)
        love.graphics.rectangle("fill", 0, i, SCREEN_WIDTH, 1)
    end
    
    -- Desenhar título animado com sombra
    love.graphics.setFont(love.graphics.newFont(52))
    
    local titleWidth = 0
    for i = 1, #titleAnimation.letters do
        local letter = titleAnimation.letters[i]
        local letterWidth = love.graphics.getFont():getWidth(letter)
        titleWidth = titleWidth + letterWidth + 15
    end
    
    local startX = (SCREEN_WIDTH - titleWidth) / 2
    local currentX = startX
    
    for i = 1, #titleAnimation.letters do
        local letter = titleAnimation.letters[i]
        local bounceY = 80 + titleAnimation.bounceHeight[i]
        
        -- Sombra
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.print(letter, currentX + 3, bounceY + 3)
        
        -- Cor gradiente para cada letra
        local hue = (i - 1) / #titleAnimation.letters
        love.graphics.setColor(
            0.5 + 0.5 * math.sin(hue * math.pi * 2 + titleAnimation.time),
            0.5 + 0.5 * math.sin(hue * math.pi * 2 + titleAnimation.time + 2),
            0.5 + 0.5 * math.sin(hue * math.pi * 2 + titleAnimation.time + 4)
        )
        
        love.graphics.print(letter, currentX, bounceY)
        currentX = currentX + love.graphics.getFont():getWidth(letter) + 15
    end
    
    -- Desenhar opções do menu com cards estilizados
    love.graphics.setFont(love.graphics.newFont(24))
    for i, option in ipairs(menuOptions) do
        local cardX = SCREEN_WIDTH/2 - 180
        local cardY = 220 + i * 65
        local cardW = 360
        local cardH = 50
        
        -- Card de fundo
        love.graphics.setColor(colors.menuCard)
        drawRoundedRect(cardX, cardY, cardW, cardH, 8)
        
        -- Borda do card
        if i == selectedOption then
            love.graphics.setColor(colors.menuBorder)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", cardX, cardY, cardW, cardH, 8, 8)
            love.graphics.setLineWidth(1)
            
            -- Glow effect
            love.graphics.setColor(colors.menuBorder[1], colors.menuBorder[2], colors.menuBorder[3], 0.3)
            drawRoundedRect(cardX - 2, cardY - 2, cardW + 4, cardH + 4, 10)
        else
            love.graphics.setColor(0.15, 0.15, 0.25)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", cardX, cardY, cardW, cardH, 8, 8)
        end
        
        -- Texto da opção
        love.graphics.setColor(colors.menuText)
        local textWidth = love.graphics.getFont():getWidth(option)
        love.graphics.print(option, cardX + cardW/2 - textWidth/2, cardY + 13)
        
        -- X de fechar para mobile
        if isMobile then
            drawCloseX(cardX + cardW - 25, cardY + 5, 15)
        end
    end
    
    -- Instruções
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.7, 0.7, 0.8)
    if isMobile then
        love.graphics.print("Toque para selecionar, use o X para voltar", 10, SCREEN_HEIGHT - 30)
    else
        love.graphics.print("Use W/S ou ↑/↓ para navegar, ENTER para selecionar", 10, SCREEN_HEIGHT - 30)
    end
end

function drawSettings()
    -- Fundo
    love.graphics.setColor(colors.menuBg)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- X de fechar
    if isMobile then
        drawCloseX(SCREEN_WIDTH - 40, 10, 30)
    end
    
    love.graphics.setColor(colors.menuText)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.print("CONFIGURAÇÕES", SCREEN_WIDTH/2 - 140, 40)
    
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Controles (Somente PC):", 80, 120)
    
    -- Seção de controles
    local controlY = 150
    for i, controlType in ipairs({"WASD", "Setas do teclado"}) do
        local cardX = 70
        local cardY = controlY + (i-1) * 45
        local cardW = 250
        local cardH = 35
        
        if (i == 1 and controls == "wasd") or (i == 2 and controls == "arrows") then
            love.graphics.setColor(colors.menuBorder)
            drawRoundedRect(cardX, cardY, cardW, cardH, 5)
        else
            love.graphics.setColor(colors.menuCard)
            drawRoundedRect(cardX, cardY, cardW, cardH, 5)
        end
        
        love.graphics.setColor(colors.menuText)
        love.graphics.print(i .. ". " .. controlType, cardX + 10, cardY + 8)
    end
    
    -- Seção de temas
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.print("Temas do Labirinto:", 80, 260)
    
    local themeStartY = 290
    local themesPerRow = 3
    for i, theme in ipairs(themes) do
        local col = (i - 1) % themesPerRow
        local row = math.floor((i - 1) / themesPerRow)
        local cardX = 80 + col * 220
        local cardY = themeStartY + row * 60
        local cardW = 200
        local cardH = 50
        
        -- Card do tema
        if i == currentTheme then
            love.graphics.setColor(colors.menuBorder)
            drawRoundedRect(cardX, cardY, cardW, cardH, 5)
        else
            love.graphics.setColor(colors.menuCard)
            drawRoundedRect(cardX, cardY, cardW, cardH, 5)
        end
        
        -- Preview das cores do tema
        love.graphics.setColor(theme.wall)
        love.graphics.rectangle("fill", cardX + 10, cardY + 10, 15, 15)
        love.graphics.setColor(theme.path)
        love.graphics.rectangle("fill", cardX + 30, cardY + 10, 15, 15)
        love.graphics.setColor(theme.exit)
        love.graphics.rectangle("fill", cardX + 50, cardY + 10, 15, 15)
        
        -- Nome do tema
        love.graphics.setColor(colors.menuText)
        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.print((i+2) .. ". " .. theme.name, cardX + 10, cardY + 30)
    end
    
    -- Instruções
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.7, 0.7, 0.7)
    if isMobile then
        love.graphics.print("Toque no X para voltar", 10, SCREEN_HEIGHT - 30)
    else
        love.graphics.print("Pressione 1-8 para escolher, ESC para voltar", 10, SCREEN_HEIGHT - 30)
    end
end

function drawWormSelect()
    love.graphics.setColor(colors.menuBg)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- X de fechar
    if isMobile then
        drawCloseX(SCREEN_WIDTH - 40, 10, 30)
    end
    
    love.graphics.setColor(colors.menuText)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.print("SELEÇÃO DE MINHOCAS", SCREEN_WIDTH/2 - 200, 50)
    
    love.graphics.setFont(love.graphics.newFont(20))
    
    -- Minhoca 1 (única disponível)
    local cardX = 80
    local cardY = 150
    local cardW = 640
    local cardH = 120
    
    if selectedWorm == 1 then
        love.graphics.setColor(colors.menuBorder)
        drawRoundedRect(cardX, cardY, cardW, cardH, 8)
    else
        love.graphics.setColor(colors.menuCard)
        drawRoundedRect(cardX, cardY, cardW, cardH, 8)
    end
    
    -- Preview da minhoca com cantos arredondados
    love.graphics.setColor(colors.wormHead)
    drawRoundedRect(cardX + 40, cardY + 40, 25, 25, 8) -- Cabeça
    
    love.graphics.setColor(colors.worm)
    drawRoundedRect(cardX + 70, cardY + 40, 25, 25, 8) -- Corpo 1
    drawRoundedRect(cardX + 100, cardY + 40, 25, 25, 8) -- Corpo 2
    
    love.graphics.setColor(colors.menuText)
    love.graphics.print("1. Minhoca Verde (Selecionada)", cardX + 150, cardY + 45)
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.7, 0.7, 0.7)
    if isMobile then
        love.graphics.print("Toque no X para voltar", 10, SCREEN_HEIGHT - 30)
    else
        love.graphics.print("Pressione 1 para selecionar, ESC para voltar", 10, SCREEN_HEIGHT - 30)
    end
end

function drawGame()
    local theme = themes[currentTheme]
    
    -- Fundo temático
    love.graphics.setColor(theme.bg)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Calcular offset para centralizar o labirinto
    local offsetX = (SCREEN_WIDTH - MAZE_WIDTH * TILE_SIZE) / 2
    local offsetY = (SCREEN_HEIGHT - MAZE_HEIGHT * TILE_SIZE) / 2 + 30
    
    -- Desenhar labirinto com efeitos visuais aprimorados
    for y = 1, MAZE_HEIGHT do
        for x = 1, MAZE_WIDTH do
            local screenX = offsetX + (x - 1) * TILE_SIZE
            local screenY = offsetY + (y - 1) * TILE_SIZE
            
            if maze[y][x] == 1 then -- Parede
                -- Sombra da parede
                love.graphics.setColor(0, 0, 0, 0.3)
                drawRoundedRect(screenX + 2, screenY + 2, TILE_SIZE - 2, TILE_SIZE - 2, 4)
                
                -- Parede principal
                love.graphics.setColor(theme.wall)
                drawRoundedRect(screenX, screenY, TILE_SIZE, TILE_SIZE, 4)
                
                -- Highlight na parede
                love.graphics.setColor(theme.wall[1] + 0.1, theme.wall[2] + 0.1, theme.wall[3] + 0.1)
                drawRoundedRect(screenX + 2, screenY + 2, TILE_SIZE - 8, TILE_SIZE - 8, 2)
                
            elseif maze[y][x] == 2 then -- Saída
                -- Glow da saída
                love.graphics.setColor(theme.exit[1], theme.exit[2], theme.exit[3], 0.5)
                drawRoundedRect(screenX - 4, screenY - 4, TILE_SIZE + 8, TILE_SIZE + 8, 8)
                
                -- Saída principal
                love.graphics.setColor(theme.exit)
                drawRoundedRect(screenX, screenY, TILE_SIZE, TILE_SIZE, 6)
                
                -- Efeito pulsante
                local pulse = math.sin(titleAnimation.time * 4) * 0.2 + 0.8
                love.graphics.setColor(theme.exit[1] * pulse, theme.exit[2] * pulse, theme.exit[3] * pulse)
                drawRoundedRect(screenX + 6, screenY + 6, TILE_SIZE - 12, TILE_SIZE - 12, 3)
                
            else -- Caminho
                love.graphics.setColor(theme.path)
                drawRoundedRect(screenX, screenY, TILE_SIZE, TILE_SIZE, 2)
            end
        end
    end
    
    -- Desenhar minhoca com cantos arredondados e efeitos
    for i, segment in ipairs(worm.segments) do
        local screenX = offsetX + (segment.x - 1) * TILE_SIZE
        local screenY = offsetY + (segment.y - 1) * TILE_SIZE
        
        if i == 1 then -- Cabeça
            -- Sombra da cabeça
            love.graphics.setColor(0, 0, 0, 0.4)
            drawRoundedRect(screenX + 3, screenY + 3, TILE_SIZE - 4, TILE_SIZE - 4, 10)
            
            -- Cabeça principal
            love.graphics.setColor(colors.wormHead)
            drawRoundedRect(screenX + 2, screenY + 2, TILE_SIZE - 4, TILE_SIZE - 4, 10)
            
            -- Highlight na cabeça
            love.graphics.setColor(colors.wormHead[1] + 0.2, colors.wormHead[2] + 0.2, colors.wormHead[3] + 0.2)
            drawRoundedRect(screenX + 6, screenY + 6, TILE_SIZE - 12, TILE_SIZE - 12, 6)
            
            -- Olhos
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.circle("fill", screenX + 10, screenY + 10, 3)
            love.graphics.circle("fill", screenX + 22, screenY + 10, 3)
            love.graphics.setColor(0.1, 0.1, 0.1)
            love.graphics.circle("fill", screenX + 10, screenY + 10, 1.5)
            love.graphics.circle("fill", screenX + 22, screenY + 10, 1.5)
            
        else -- Corpo
            -- Sombra do corpo
            love.graphics.setColor(0, 0, 0, 0.3)
            drawRoundedRect(screenX + 3, screenY + 3, TILE_SIZE - 4, TILE_SIZE - 4, 8)
            
            -- Corpo principal
            love.graphics.setColor(colors.worm)
            drawRoundedRect(screenX + 2, screenY + 2, TILE_SIZE - 4, TILE_SIZE - 4, 8)
            
            -- Highlight no corpo
            love.graphics.setColor(colors.worm[1] + 0.15, colors.worm[2] + 0.15, colors.worm[3] + 0.15)
            drawRoundedRect(screenX + 6, screenY + 6, TILE_SIZE - 12, TILE_SIZE - 12, 4)
        end
    end
    
    -- Interface aprimorada
    love.graphics.setColor(0, 0, 0, 0.7)
    drawRoundedRect(5, 5, 200, 60, 8)
    
    love.graphics.setColor(colors.menuText)
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("Nível: " .. level, 15, 15)
    love.graphics.print("Tema: " .. themes[currentTheme].name, 15, 35)
    
    love.graphics.setColor(0, 0, 0, 0.7)
    drawRoundedRect(SCREEN_WIDTH - 110, 5, 100, 30, 8)
    love.graphics.setColor(colors.menuText)
    love.graphics.print("ESC - Menu", SCREEN_WIDTH - 100, 15)
    
    -- Controles mobile
    if isMobile then
        drawMobileControls()
    else
        -- Instruções de controle para PC
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.setColor(0, 0, 0, 0.6)
        drawRoundedRect(5, SCREEN_HEIGHT - 35, 200, 25, 5)
        love.graphics.setColor(colors.menuText)
        if controls == "wasd" then
            love.graphics.print("Controles: WASD", 10, SCREEN_HEIGHT - 30)
        else
            love.graphics.print("Controles: Setas", 10, SCREEN_HEIGHT - 30)
        end
    end
end

function drawMobileControls()
    -- Desenhar controles touch para mobile
    love.graphics.setColor(0, 0, 0, 0.5)
    
    -- Botão UP
    drawRoundedRect(touchControls.up.x, touchControls.up.y, touchControls.up.w, touchControls.up.h, 5)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("↑", touchControls.up.x + 25, touchControls.up.y + 5)
    
    -- Botão DOWN
    love.graphics.setColor(0, 0, 0, 0.5)
    drawRoundedRect(touchControls.down.x, touchControls.down.y, touchControls.down.w, touchControls.down.h, 5)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("↓", touchControls.down.x + 25, touchControls.down.y + 5)
    
    -- Botão LEFT
    love.graphics.setColor(0, 0, 0, 0.5)
    drawRoundedRect(touchControls.left.x, touchControls.left.y, touchControls.left.w, touchControls.left.h, 5)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("←", touchControls.left.x + 10, touchControls.left.y + 25)
    
    -- Botão RIGHT
    love.graphics.setColor(0, 0, 0, 0.5)
    drawRoundedRect(touchControls.right.x, touchControls.right.y, touchControls.right.w, touchControls.right.h, 5)
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.print("→", touchControls.right.x + 10, touchControls.right.y + 25)
end

function drawGameOver()
    local theme = themes[currentTheme]
    
    -- Fundo com overlay
    love.graphics.setColor(theme.bg)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Card principal do game over
    love.graphics.setColor(colors.menuCard)
    drawRoundedRect(SCREEN_WIDTH/2 - 250, SCREEN_HEIGHT/2 - 150, 500, 300, 15)
    
    -- Borda do card
    love.graphics.setColor(colors.closeX)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", SCREEN_WIDTH/2 - 250, SCREEN_HEIGHT/2 - 150, 500, 300, 15, 15)
    love.graphics.setLineWidth(1)
    
    love.graphics.setColor(colors.menuText)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.print("GAME OVER", SCREEN_WIDTH/2 - 150, SCREEN_HEIGHT/2 - 100)
    
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.print("Nível alcançado: " .. level, SCREEN_WIDTH/2 - 90, SCREEN_HEIGHT/2 - 30)
    
    -- Botão para continuar
    love.graphics.setColor(colors.menuBorder)
    drawRoundedRect(SCREEN_WIDTH/2 - 120, SCREEN_HEIGHT/2 + 20, 240, 50, 8)
    
    love.graphics.setColor(colors.menuText)
    love.graphics.setFont(love.graphics.newFont(18))
    if isMobile then
        love.graphics.print("Toque para voltar ao menu", SCREEN_WIDTH/2 - 110, SCREEN_HEIGHT/2 + 35)
    else
        love.graphics.print("ENTER para voltar ao menu", SCREEN_WIDTH/2 - 100, SCREEN_HEIGHT/2 + 35)
    end
end
