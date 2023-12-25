include("./AoC.jl")
using .AoC: getDayInputLines
using DataStructures

windowed(collection, stepSize, windowSize) = ((@view collection[i:i+windowSize-1]) for i in 1:stepSize:length(collection)-windowSize+1)

function toGraphViz(graph)
    filename = "graph_25.dot"
    io = open(filename, "w")
    write(io, "strict digraph {\n")
    for (from, tos) in graph
        for to in tos
            write(io, "\t$(from) -> $(to)\n")
        end
    end
    write(io, "}\n")
    close(io)
    println("graph written to $(filename)")
    println("please run: 'dot -Tsvg graph_25.dot > graph_25.svg'")
end

function addEdge(graph, from, to)
    if !haskey(graph, from)
        graph[from] = []
    end
    if !haskey(graph, to)
        graph[to] = []
    end
    push!(graph[from], to)
    push!(graph[to], from)
end

function removeEdge(graph, edge)
    (v1, v2) = edge
    deleteat!(graph[v1], findall(v -> v == v2, graph[v1]))
    deleteat!(graph[v2], findall(v -> v == v1, graph[v2]))
end

function toGraph(lines)
    graph = Dict()

    for line in lines
        from_tos = split(line, ": ")
        from = from_tos[1]
        tos = split(from_tos[2], ' ')
        for to in tos
            addEdge(graph, from, to)
        end
    end
    graph
end

randomNode(graph) = rand(keys(graph))

function bfs(graph, from, to)
    visited = Dict()
    openlist = PriorityQueue()
    push!(openlist, (from, nothing, 0) => 0)
    from = Dict()
    while true
        (node, prev, cost) = dequeue!(openlist)
        if haskey(visited, node) && visited[node] <= cost
            continue
        end
        visited[node] = cost

        costNext = cost + 1
        from[node] = prev

        if node == to
            break
        end

        for nextnode in graph[node]
            push!(openlist, (nextnode, node, costNext) => costNext)
        end
    end
    node = to
    path = []
    while !isnothing(node)
        push!(path, node)
        node = from[node]
    end
    path
end

function bfsSize(graph, from)
    visited = Dict()
    openlist = PriorityQueue()
    push!(openlist, (from, nothing, 0) => 0)
    from = Dict()
    while true
        if isempty(openlist)
            return length(keys(visited))
        end
        (node, prev, cost) = dequeue!(openlist)
        if haskey(visited, node) && visited[node] <= cost
            continue
        end
        visited[node] = cost

        costNext = cost + 1
        from[node] = prev

        for nextnode in graph[node]
            push!(openlist, (nextnode, node, costNext) => costNext)
        end
    end
end

function getRandomPath(graph)
    from = randomNode(graph)
    to = randomNode(graph)
    bfs(graph, from, to)
end

function pathToEdges(path)
    map(edge -> sort(edge), windowed(path, 1, 2))
end

getRandomEdges(graph) = pathToEdges(getRandomPath(graph))

function getTop3EdgesInRandomPaths(graph)
    edgeCount = Dict()
    function addEdgeCount(edge)
        if !haskey(edgeCount, edge)
            edgeCount[edge] = 0
        end
        edgeCount[edge] += 1
    end

    for i in 1:2000
        for edge in getRandomEdges(graph)
            addEdgeCount(edge)
        end
    end
    getBest() = reduce((x, y) -> edgeCount[x] > edgeCount[y] ? x : y, keys(edgeCount))
    function popBest!()
        edge = getBest()
        delete!(edgeCount, edge)
        edge
    end

    edge1 = popBest!()
    edge2 = popBest!()
    edge3 = popBest!()
    (edge1, edge2, edge3)
end

function removeTop3UsedEdges(graph)
    top3UsedEdges = getTop3EdgesInRandomPaths(graph)
    for edge in top3UsedEdges
        removeEdge(graph, edge)
    end
    first(top3UsedEdges)
end

function main()
    lines = getDayInputLines(25)
    graph = toGraph(lines)
    (edgeGraph1, edgeGraph2) = removeTop3UsedEdges(graph)
    println(edgeGraph1, " ", edgeGraph2)
    size1 = bfsSize(graph, edgeGraph1)
    size2 = bfsSize(graph, edgeGraph2)
    println(size1, "*", size2, " = ", size1 * size2)
end

main()
