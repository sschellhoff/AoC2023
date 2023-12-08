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
    (automaton, (findall(name -> last(name) == 'A', nodes), findall(name -> last(name) == 'Z', nodes)))
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

function step(automaton, directionsLine)
    pathLengths = []
    for source in automaton[2][1]
        push!(pathLengths, stepFrom(automaton[1], source, automaton[2][2], directionsLine))
    end
    pathLengths
end

function stepFrom(graph, source, sinks, directionLine)
    directions = buildDirections(directionLine)
    pathLengths = []
    currentNode = source
    numSteps = 0
    while length(pathLengths) != length(sinks)
        direction = nextDirection!(directions)
        directionIndex = if direction == 'L'
            1
        else
            2
        end
        currentNode = graph[currentNode][directionIndex]
        numSteps += 1
        if currentNode in sinks # found a sink
            if length(filter(pathLength -> pathLength[1] == currentNode, pathLengths)) > 0 # sink already found, TODO check if direction is at start -> index = 0 or length(directionsString)
                return pathLengths
            end
            push!(pathLengths, (currentNode, numSteps))
        end
        pathLengths
    end
end

function main()
    blocks = getDayInputBlocks(8)
    automaton = buildAutomaton(split(blocks[2], '\n'))
    #println(stepFrom(automaton[1], 1, automaton[2][2], blocks[1]))
    pathLengthsWithTarget = step(automaton, blocks[1])
    flattened = map(path -> path[1], pathLengthsWithTarget)
    pathLength = map(pathLength -> pathLength[2], flattened)
    println(lcm(pathLength))
end

main()
