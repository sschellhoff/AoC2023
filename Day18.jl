include("./AoC.jl")
using .AoC: getDayInputLines

windowed(collection, stepSize, windowSize) = ((@view collection[i:i+windowSize-1]) for i in 1:stepSize:length(collection)-windowSize+1)

@enum Direction up down left right

function parseLine(line)
    splitted = split(line)
    direction = if(splitted[1] == "U")
        up
    elseif (splitted[1] == "D")
        down
    elseif (splitted[1] == "L")
        left
    elseif (splitted[1] == "R")
        right
    else
        throw("unknown direction")
    end
    number = parse(Int, splitted[2])
    (direction, number)
end

function parseLine2(line)
    hex = split(line)[3][3:end-1]
    number = parse(Int, hex[1:end-1], base = 16)
    direction = if(last(hex) == '0')
        right
    elseif (last(hex) == '1')
        down
    elseif (last(hex) == '2')
        left
    elseif (last(hex) == '3')
        up
    else
        throw("unknown direction")
    end
    (direction, number)
end

function next(currentPositon::Tuple{Int, Int}, command::Tuple{Direction, Int})
    (direction, amount) = command
    (x, y) = currentPositon
    return if direction == up
        (x, y-amount)
    elseif direction == down
        (x, y+amount)
    elseif direction == left
        (x-amount, y)
    elseif direction == right
        (x+amount, y)
    end
end

function dig(commands::Vector{Tuple{Direction, Int}})
    currentPosition = (1, 1)
    positions = [currentPosition]
    for command in commands
        newPosition = next(currentPosition, command)
        push!(positions, newPosition)
        currentPosition = newPosition
    end
    positions
end

function completePath(path)
    # some points are doubles in the path, but this is no problem for the rest of my solution
    completePath = [first(path)]
    for w in windowed(path, 1, 2)
        (x1, y1) = w[1]
        (x2, y2) = w[2]
        if x1 == x2
            for y in min(y1, y2):max(y1, y2)
                push!(completePath, (x1, y))
            end
        elseif y1 == y2
            for x in min(x1, x2):max(x1, x2)
                push!(completePath, (x, y1))
            end
        else
            throw("x's or y's need to be the same")
        end
    end
    completePath
end

function shoelaceCombinePoints(p1_p2)
    (p1, p2) = p1_p2
    p1[1] * p2[2] - p2[1] * p1[2]
end

shoelace(polygon) = mapreduce(shoelaceCombinePoints, +, windowed(polygon, 1, 2)) / 2

function calculateArea(polygon)
    area = shoelace(polygon)
    border = Set(completePath(polygon))
    trunc(Int64, length(border) / 2 + area + 1)
end

function main()
    lines = getDayInputLines(18)
    commands = map(parseLine, lines)
    corners = dig(commands)
    println(calculateArea(corners))

    commands = map(parseLine2, lines)
    corners = dig(commands)
    println(calculateArea(corners))
end

main()
