include("./AoC.jl")
using .AoC: getDayInputLines

@enum PartType Source Sink FlipFlop Conjunction

function parseTaggedName(prefix)
    c = first(prefix)
    if c == '&'
        (Conjunction, prefix[2:end])
    elseif c == '%'
        (FlipFlop, prefix[2:end])
    else
        (Source, prefix)
    end
end

function parseDestinations(postfix)
    split(postfix, ", ")
end

function parsePart(line)
    splitted = split(line, " -> ")
    (tag, name) = parseTaggedName(splitted[1])
    destinations = parseDestinations(splitted[2])
    (tag, name, destinations)
end

function initPart(partDescription)
    (tag, name, destinations) = partDescription
    if tag == Source
        [tag, destinations]
    elseif tag == FlipFlop
        [tag, false, destinations]
    elseif tag == Conjunction
        [tag, [], destinations]
    else
        throw("unsupported part type '$(tag)'")
    end
end

function registerPartsInput(part, input)
    if partTag(part) == Conjunction
        push!(part[2], [input, false])
    end
end

partTag(part) = part[1]

function buildCircuit(parts)
    circuit = Dict()
    for part in parts
        circuit[part[2]] = initPart(part)
    end
    for (tag, name, destinations) in parts
        for destination in destinations
            if haskey(circuit, destination)
                registerPartsInput(circuit[destination], name)
            else
                circuit[destination] = [Sink]
            end
        end
    end
    circuit
end

pulseValue(pulse) = pulse[2]
pulseSource(pulse) = pulse[1]
pulseTarget(pulse) = pulse[3]

function applyPulseToFlipFlop(name, value, part)
    if value # high pulse
        []
    elseif part[2] # low pulse and high state
        part[2] = false
        map(d -> (name, false, d), part[3])
    else # low pulse and low state
        part[2] = true
        map(d -> (name, true, d), part[3])
    end
end

function updateConjunctionInput(value, inputName, part)
    inputs = part[2]
    for input in inputs
        if input[1] == inputName
            input[2] = value
            return nothing
        end
    end
    throw("invalid input")
end

allConjuntionInputsAre(value, part) = all(map(i-> i[2] == value, part[2]))

function applyPulseToConjunction(name, value, source, part)
    updateConjunctionInput(value, source, part)

    # if all inputs were high :v
    if allConjuntionInputsAre(true, part)
        # low
        map(d -> (name, false, d), (part[3]))
    else
        # high
        map(d -> (name, true, d), (part[3]))
    end
end

function applyPulse(pulse, circuit)
    (source, value, destination) = pulse
    destinationPart = circuit[destination]
    tag = partTag(destinationPart)

    if tag == Source
        map(d -> (destination, value, d), destinationPart[2])
    elseif tag == FlipFlop
        applyPulseToFlipFlop(destination, value, destinationPart)
    elseif tag == Conjunction
        applyPulseToConjunction(destination, value, source, destinationPart)
    elseif tag == Sink
        []
    else
        throw("Unknown part type")
    end
end

function isCircuitInStartConfiguration(circuit)
    parts = values(circuit)
    for part in parts
        if part[1] == Conjunction && !allConjuntionInputsAre(false, part)
            return false
        end
    end
    true
end

function runCycle(circuit)
    pulses = [("button", false, "broadcaster")]
    lowCount = 0
    highCount = 0

    while length(pulses) > 0
        pulse = popfirst!(pulses)

        if pulseValue(pulse)
            highCount += 1
        else
            lowCount += 1
        end
        
        append!(pulses, applyPulse(pulse, circuit))
    end
    (lowCount, highCount)
end

function runUntilStartConfiguration(circuit, maxButtonPushes)
    lowCount = 0
    highCount = 0
    numberOfButtonPushes = 0
    counts = []
    while true
        numberOfButtonPushes += 1

        (cycleLowCount, cycleHighCount) = runCycle(circuit)
        lowCount += cycleLowCount
        highCount += cycleHighCount
        push!(counts, (lowCount, highCount))

        if isCircuitInStartConfiguration(circuit)
            return counts
        elseif numberOfButtonPushes >= maxButtonPushes
            println("button pressed $(maxButtonPushes) times")
            return counts
        end
    end
end

function prettyPrint(circuit)
    for (k, v) in circuit
        println(k, " => ", v)
    end
end

function printFlipFlops(circuit)
    for (k, v) in circuit
        tag = partTag(v)
        if tag == FlipFlop
            print(k, ": ")
            for d in v[2]
                print(d, " ")
            end
            print(";\t")
        end
    end
    println()
end

function sumPulses(pulseCounts, neededCycles, extraPushesNeeded)
    (lowCycle, highCycle) = last(pulseCounts)
    (lowExtra, highExtra) = if extraPushesNeeded > 0
        pulseCounts[extraPushesNeeded]
    else
        (0, 0)
    end
    (neededCycles * lowCycle + lowExtra, neededCycles * highCycle + highExtra)
end

function getSourcesFor(destination, circuit)
    sources = Set()
    for (partName, part) in circuit
        tag = partTag(part)
        if tag == Source
            # 2
            if destination in part[2]
                push!(sources, partName)
            end
        elseif tag == Sink
            # []
        elseif tag == Conjunction
            # 3
            if destination in part[3]
                push!(sources, partName)
            end
        elseif tag == FlipFlop
            # 3
            if destination in part[3]
                push!(sources, partName)
            end
        else
            throw("unknown part type")
        end
    end
    sources
end

function getSubGraphForDestination(circuit, destination)
    goToRx = Set()
    push!(goToRx, destination)
    alreadyChecked = []
    while length(goToRx) > 0
        dest = pop!(goToRx)
        push!(alreadyChecked, dest)
        sources = getSourcesFor(dest, circuit)
        for source in sources
            if source ∉ alreadyChecked
                push!(goToRx, source)
            end
        end
    end
    allNames = Set(keys(circuit))
    canRemove = collect(setdiff(allNames, Set(alreadyChecked)))
    prunedCircuit = deepcopy(circuit)
    for name in canRemove
        delete!(prunedCircuit, name)
        deleteat!(prunedCircuit["broadcaster"][2], findall(x -> x == name, prunedCircuit["broadcaster"][2]))
    end
    prunedCircuit["qb"] = [Conjunction, [[destination, false]], ["rx"]]
    prunedCircuit["rx"] = [Sink]
    prunedCircuit
end

function findCircleInSubCircuit(circuit, destination)
    circuit = getSubGraphForDestination(circuit, destination)
    l = 0

    while true
        l += 1
        #println(l)
        pulses = [("button", false, "broadcaster")]
        while length(pulses) > 0
            pulse = popfirst!(pulses)
            (s, v, d) = pulse
            if !v && d == "rx"
                return l
            end
            
            append!(pulses, applyPulse(pulse, circuit))
        end

        if isCircuitInStartConfiguration(circuit)
            return l
        end
    end
end

function toGraphViz(circuit)
    filename = "graph.dot"
    io = open(filename, "w")
    write(io, "strict digraph {\n")
    for (name, part) in circuit
        tag = partTag(part)
        if tag == Source
            write(io, "$(name) [color=\"green\"]\n")
            for dest in part[2]
                write(io, "\t$(name) -> $(dest)\n")
            end
        elseif tag == Sink
            write(io, "$(name) [color=\"red\"]\n")
            # no egde
        elseif tag == FlipFlop
            write(io, "$(name) [color=\"yellow\"]\n")
            for dest in part[3]
                write(io, "\t$(name) -> $(dest)\n")
            end
        elseif tag == Conjunction
            write(io, "$(name) [color=\"blue\"]\n")
            for dest in part[3]
                write(io, "\t$(name) -> $(dest)\n")
            end
        else
            throw("unknown part type")
        end
    end
    write(io, "}\n")
    close(io)
    println("graph written to $(filename)")
end

function main()
    lines = getDayInputLines(20)
    circuit = buildCircuit(map(parsePart, lines))
    circuitCopy = deepcopy(circuit)
    #prettyPrint(circuit)

    numberOfPushes = 1000
    pulseCounts = runUntilStartConfiguration(circuit, numberOfPushes)
    cycleLength = length(pulseCounts)
    neededCycles = trunc(Int, numberOfPushes / cycleLength)
    neededExtraRuns = numberOfPushes % cycleLength
    
    #neededPushes = neededCycles + neededExtraRuns
    #println("cycle length: ", cycleLength)
    #println("needed cycled: ", neededCycles)
    #println("needed extra runs: ", neededExtraRuns)
    #println("needed pushes: ", neededPushes)
    
    (low, high) = sumPulses(pulseCounts, neededCycles, neededExtraRuns)
    println("result: ", low * high)
    
    println()
    c1 = findCircleInSubCircuit(circuitCopy, "rz")
    println()
    c2 = findCircleInSubCircuit(circuitCopy, "mr")
    println()
    c3 = findCircleInSubCircuit(circuitCopy, "kv")
    println()
    c4 = findCircleInSubCircuit(circuitCopy, "jg")
    println()
    println(lcm(c1, c2, c3, c4))
    #toGraphViz(circuit)
end

main()
