include("./AoC.jl")
using .AoC: getDayInput, getDayInputLines, getDayInputBlocks

function replaceNumbers(s)
    s = replace(s, "one" => "one1one")
    s = replace(s, "two" => "two2two")
    s = replace(s, "three" => "three3three")
    s = replace(s, "four" => "four4four")
    s = replace(s, "five" => "five5five")
    s = replace(s, "six" => "six6six")
    s = replace(s, "seven" => "seven7seven")
    s = replace(s, "eight" => "eight8eight")
    s = replace(s, "nine" => "nine9nine")
    return s
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
