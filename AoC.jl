module AoC

function getFileContent(filename)
    file = open("data/$filename")
    content = read(file, String)
    close(file)
    return content
end

function getDayInput(day, suffix="")
    filename = lpad(day, 2, '0')
    fileending = "txt"
    getFileContent("$filename$suffix.$fileending")
end

function getDayInputLines(day, suffix="")
    content = getDayInput(day, suffix)
    lines = split(content, '\n')
    lines
end

function getDayInputBlocks(day, suffix="")
    content = getDayInput(day, suffix)
    lines = split(content, "\n\n")
    lines
end

end
