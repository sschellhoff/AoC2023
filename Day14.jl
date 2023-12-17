include("./AoC.jl")
using .AoC: getDayInputLines

function north(board::Vector{Vector{Char}})
    for (y, line) in enumerate(board)
        for (x, value) in enumerate(line)
            if (value == 'O')
                north(board, x, y)
            end
        end
    end
end

function north(board::Vector{Vector{Char}}, x::Int, y::Int)
    targetY = y - 1
    while targetY >= 1 && board[targetY][x] == '.'
        targetY -= 1
    end
    if targetY+1 == y
        return
    end
    board[targetY + 1][x] = 'O'
    board[y][x] = '.'
end

function south(board::Vector{Vector{Char}})
    for (y, line) in Iterators.reverse(enumerate(board))
        for (x, value) in enumerate(line)
            if (value == 'O')
                south(board, x, y)
            end
        end
    end
end

function south(board::Vector{Vector{Char}}, x::Int, y::Int)
    targetY = y + 1
    boardHeight = length(board)
    while targetY <= boardHeight && board[targetY][x] == '.'
        targetY += 1
    end
    if targetY-1 == y
        return
    end
    board[targetY - 1][x] = 'O'
    board[y][x] = '.'
end

function west(board::Vector{Vector{Char}})
    for (y, line) in enumerate(board)
        for (x, value) in enumerate(line)
            if (value == 'O')
                west(board, x, y)
            end
        end
    end
end

function west(board::Vector{Vector{Char}}, x::Int, y::Int)
    targetX = x - 1
    while targetX >= 1 && board[y][targetX] == '.'
        targetX -= 1
    end
    if targetX+1 == x
        return
    end
    board[y][targetX + 1] = 'O'
    board[y][x] = '.'
end

function east(board::Vector{Vector{Char}})
    for (y, line) in enumerate(board)
        for (x, value) in Iterators.reverse(enumerate(line))
            if (value == 'O')
                east(board, x, y)
            end
        end
    end
end

function east(board::Vector{Vector{Char}}, x::Int, y::Int)
    targetX = x + 1
    boardWidth = length(board[1])
    while targetX <= boardWidth && board[y][targetX] == '.'
        targetX += 1
    end
    if targetX-1 == x
        return
    end
    board[y][targetX - 1] = 'O'
    board[y][x] = '.'
end

function cycle(board::Vector{Vector{Char}})
    north(board)
    west(board)
    south(board)
    east(board)
end

function printBoard(board::Vector{Vector{Char}})
    for line in board
        for value in line
            print(value)
        end
        println()
    end
end

function rankBoard(board::Vector{Vector{Char}})
    score = 0
    boardHeight = length(board)
    for (y, line) in enumerate(board)
        for value in line
            if value == 'O'
                score += 1 + boardHeight - y
            end
        end
    end
    score
end

function main()
    board = map(collect, getDayInputLines(14))
    boards = Dict()
    for i in 1:1000000000
        cycle(board)
        h = hash(board)
        if haskey(boards, h)
            circleEnd = i
            circleStart = boards[h]
            circleLength = circleEnd - circleStart
            println("cycle end ", i, " circle start ", circleStart)
            rest = (1000000000 - circleStart) % circleLength
            for j in 1:rest
                cycle(board)
            end
            break
        end
        boards[h] = i
    end
    #printBoard(board)
    println(rankBoard(board))
end

main()
