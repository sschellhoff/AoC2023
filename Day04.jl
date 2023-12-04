include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

function parseNumbers(numbers)
    map(number -> parse(Int64, number), split(numbers, " "))
end

function countOverlapping(winningNumbers, myNumbers)
    inBoth = intersect(winningNumbers, myNumbers)
    length(inBoth)
end

function score(numberOfMatches)
    if numberOfMatches == 0
        return 0
    end
    return 2 ^ (numberOfMatches - 1)
end

function getOverlapping(content)
    result = []
    for line in content
        numbersAsStrings = split(split(replace(line, "  " => " "), ": ")[2], " | ")
        winningNumbers = parseNumbers(numbersAsStrings[1])
        myNumbers = parseNumbers(numbersAsStrings[2])
        push!(result, countOverlapping(winningNumbers, myNumbers))
    end
    result
end

function countCards(overlapping)
    countedTickets = fill(1, length(overlapping))
    for index in length(overlapping):-1:1
        for delta in 1:overlapping[index]
            newIndex = delta + index
            if newIndex <= length(countedTickets)
                countedTickets[index] += countedTickets[newIndex]
            end
        end
    end
    countedTickets
end

function main()
    #content = getDayInputLines(4, "_test")
    content = getDayInputLines(4)
    println(mapreduce(num -> score(num), +, getOverlapping(content)))
    println(reduce(+, countCards(getOverlapping(content))))
end

main()
