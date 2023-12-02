include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

function replaceNumbers(line)
    line = replace(line, "one" => "one1one")
    line = replace(line, "two" => "two2two")
    line = replace(line, "three" => "three3three")
    line = replace(line, "four" => "four4four")
    line = replace(line, "five" => "five5five")
    line = replace(line, "six" => "six6six")
    line = replace(line, "seven" => "seven7seven")
    line = replace(line, "eight" => "eight8eight")
    line = replace(line, "nine" => "nine9nine")
    return line
end

function numbersFromLine(line, withReplace = false)
    newLine = line
    if withReplace
        newLine = replaceNumbers(line)
    end
    numbers = filter(isdigit, newLine)
    if length(numbers) == 0
        return 0
    end
    parse(Int64, "$(first(numbers))$(last(numbers))")
end

function main()
    content = getDayInputLines(1)
    println("First: ", mapreduce(line -> numbersFromLine(line), +, content))
    println("Second: ", mapreduce(line -> numbersFromLine(line, true), +, content))
end

main()
