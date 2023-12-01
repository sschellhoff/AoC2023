module AoC
export getDayInput, getDayInputLines, getDayInputBlocks

function getFileContent(filename)
    file = open("data/$filename")
    content = read(file, String)
    close(file)
    return content
end

function getDayInput(day)
    filename = lpad(day, 2, '0')
    fileending = "txt"
    getFileContent("$filename.$fileending")
end

function getDayInputLines(day)
    content = getDayInput(day)
    lines = split(content, '\n')
    lines
end

function getDayInputBlocks(day)
    content = getDayInput(day)
    lines = split(content, "\n\n")
    lines
end

end
