include("./AoC.jl")
using .AoC: getDayInputBlocks

# x: 1, m: 2, a: 3, s: 4
# A: accept, R: reject

@enum ExpressionType LessThan GreaterThan Atomic

function parseIndex(idxString)
    if idxString == "x"
        1
    elseif idxString == "m"
        2
    elseif idxString == "a"
        3
    elseif idxString == "s"
        4
    else
        throw("Unknown index '$(idxString)'")
    end
end

function parseCondition(condString)
    if '<' in condString
        splitted = split(condString, '<')
        lhs = parseIndex(splitted[1])
        rhs = parse(Int, splitted[2])
        (LessThan, lhs, rhs)
    elseif '>' in condString
        splitted = split(condString, '>')
        lhs = parseIndex(splitted[1])
        rhs = parse(Int, splitted[2])
        (GreaterThan, lhs, rhs)
    else
        throw("unknown condition operator")
    end
end

function parseExpression(exprString)
    if ':' in exprString
        splitted = split(exprString, ':')
        (exprType, lhs, rhs) = parseCondition(splitted[1])
        target = splitted[2]
        (exprType, lhs, rhs, target)
    else
        (Atomic, exprString)
    end
end

function parseLine(line)
    splitted = split(line, '{')
    expression = map(parseExpression, split(splitted[2][1:end-1], ','))
    source = splitted[1]
    (source, expression)
end

function parseAutomaton(block)
    expressionStrings = split(block, '\n')
    commands = map(parseLine, expressionStrings)
    automaton = Dict()
    for (source, expression) in commands
        automaton[source] = expression
    end
    automaton
end

function parseMachinePart(line)
    splitted = split(line[2:end-1], ',')
    x = parse(Int, splitted[1][3:end])
    m = parse(Int, splitted[2][3:end])
    a = parse(Int, splitted[3][3:end])
    s = parse(Int, splitted[4][3:end])
    (x, m, a, s)
end

function parseMachineParts(block)
    map(parseMachinePart, split(block, '\n'))
end

runCondition(lhs, op, rhs) = op(lhs, rhs)

function runConditions(part, conditions)
    for condition in conditions
        tag = condition[1]
        if tag == Atomic
            return condition[2]
        end
        if tag == LessThan && runCondition(part[condition[2]], <, condition[3])
            return condition[4]
        end
        if tag == GreaterThan && runCondition(part[condition[2]], >, condition[3])
            return condition[4]
        end
    end
    throw("Expression terminated")
end

function filterPart(part, automaton)
    currentExpression = "in"
    while true
        conditions = automaton[currentExpression]
        result = runConditions(part, conditions)
        if result == "A"
            return true
        elseif result == "R"
            return false
        else
            currentExpression = result
        end
    end
end

function filterParts(parts, automaton)
    filter(part -> filterPart(part, automaton), parts)
end

sumPart(part) = part[1] + part[2] + part[3] + part[4]

sumParts(parts) = mapreduce(sumPart, +, parts)

function applyCondition(ranges, condition)
    lhsIndex = condition[2]
    rhsValue = condition[3]

    if condition[1] == LessThan
        trueRanges = copy(ranges)
        falseRanges = copy(ranges)
        trueRanges[lhsIndex] = trueRanges[lhsIndex][1]:min(rhsValue - 1, trueRanges[lhsIndex][end])
        falseRanges[lhsIndex] = max(falseRanges[lhsIndex][1], rhsValue):falseRanges[lhsIndex][end]
        (trueRanges, falseRanges)
    elseif condition[1] == GreaterThan
        trueRanges = copy(ranges)
        falseRanges = copy(ranges)
        trueRanges[lhsIndex] = max(trueRanges[lhsIndex][1], rhsValue+1):trueRanges[lhsIndex][end]
        falseRanges[lhsIndex] = falseRanges[lhsIndex][1]:min(rhsValue, falseRanges[lhsIndex][end])
        (trueRanges, falseRanges)
    else
        throw("Unknown condition type")
    end
end

function sumRanges(ranges)
    (xs, ms, as, ss) = ranges
    nXs = 1 + xs[end] - xs[1]
    nMs = 1 + ms[end] - ms[1]
    nAs = 1 + as[end] - as[1]
    nSs = 1 + ss[end] - ss[1]
    nXs * nMs * nAs * nSs
end

function part2(automaton, state, ranges, acceptTarget, rejectTarget)
    conditions = automaton[state]
    numConfigurations = 0
    for condition in conditions
        tag = condition[1]
        if tag == Atomic
            if condition[2] == rejectTarget
                numConfigurations += 0
            elseif condition[2] == acceptTarget
                numConfigurations += sumRanges(ranges)
            else
                numConfigurations += part2(automaton, condition[2], ranges, acceptTarget, rejectTarget)
            end
        else
            (newRanges, ranges) = applyCondition(ranges, condition)

            target = condition[4]
            if target == acceptTarget
                numConfigurations += sumRanges(newRanges)
            elseif target == rejectTarget
                numConfigurations += 0
            else
                numConfigurations += part2(automaton, target, newRanges, acceptTarget, rejectTarget)
            end
        end
    end
    numConfigurations
end

# this is just for testing, get all valid ranges
function part2GetRanges(automaton, state, ranges, acceptTarget, rejectTarget)
    conditions = automaton[state]
    result = []
    for condition in conditions
        tag = condition[1]
        if tag == Atomic
            if condition[2] == rejectTarget
            elseif condition[2] == acceptTarget
                println(state, " ", condition, " ", conditions)
                push!(result, ranges)
            else
                for newRanges in part2GetRanges(automaton, condition[2], ranges, acceptTarget, rejectTarget)
                    push!(result, newRanges)
                end
            end
        else
            (newRanges, ranges) = applyCondition(ranges, condition)

            target = condition[4]
            if target == acceptTarget
                println(state, " ", condition, " ", conditions)
                push!(result, ranges)
            elseif target == rejectTarget
            else
                for newRanges in part2GetRanges(automaton, target, newRanges, acceptTarget, rejectTarget)
                    push!(result, newRanges)
                end
            end
        end
    end
    result
end

function main()
    blocks = getDayInputBlocks(19)
    automaton = parseAutomaton(blocks[1])
    parts = parseMachineParts(blocks[2])
    println(sumParts(filterParts(parts, automaton)))

    fullRanges = [1:4000, 1:4000, 1:4000, 1:4000]
    println(part2(automaton, "in", fullRanges, "A", "R"))
end

main()
