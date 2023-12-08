include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

function buildAutomaton(lines)
    nodes = map(line -> split(line, ' ')[1], lines)
    automaton = []
    findNode(node) = findall(name -> name == node, nodes)[1]
    for line in lines
        left = findNode(match(r"(?<=\()(...)", line).match)
        right = findNode(match(r"(?<=, )(...)", line).match)
        push!(automaton, (left, right))
    end
    (automaton, (findNode("AAA"), findNode("ZZZ")))
end

mutable struct Directions
    index::Int64
    directionsString::String
end

function buildDirections(line)
    Directions(0, line)
end

function nextDirection!(directions::Directions)
    directions.index = (directions.index % length(directions.directionsString)) + 1
    directions.directionsString[directions.index]
end

function step(automaton, directions::Directions)
    numSteps = 0
    (graph, (startNode, endNode)) = automaton
    currentNode = startNode

    while currentNode != endNode
        direction = nextDirection!(directions)
        directionIndex = if direction == 'L'
            1
        else
            2
        end
        currentNode = graph[currentNode][directionIndex]
        numSteps += 1
    end
    numSteps
end

function main()
    blocks = getDayInputBlocks(8)
    directions = buildDirections(blocks[1])
    automaton = buildAutomaton(split(blocks[2], '\n'))
    println(step(automaton, directions))
end

main()
