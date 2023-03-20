using LinkedLists

# Graph representation using LinkedList for fast neighbor traversal.
#  - vertices: Set of all vertices in the graph (a set for easy removal)
#  - n: Number of vertices (set to -1 to indicate non-extendable graphs)
#  - adjmat: Adjacency matrix of the graph, storing pointers to LinkedList
#    elements, i.e., adjmat[i, j] contains a pointer to to element j in the
#    corresponding LinkedList inlist[i], outlist[i], or undirlist[i].
#  - testmat: Additional matrix for fast adjacency tests
#    (using adjmat alone is much slower).
#  - inlist: Adjacency lists for each vertex, containing all neighbors
#    that are connected to the vertex via an incoming edge.
#  - outlist: Adjacency lists for each vertex, containing all neighbors
#    that are connected to the vertex via an outgoing edge.
#  - undirlist: Adjacency lists for each vertex, containing all neighbors
#    that are connected to the vertex via an undirected edge.
#  - inctr: Counter for the number of ingoing edges for each vertex.
#    (LinkedList has only an O(n) length function.)
#  - undirctr: Counter for the number of undirected edges for each vertex.
#    (LinkedList has only an O(n) length function.)
#  - outctr: Counter for the number of outgoing edges for each vertex.
#    (LinkedList has only an O(n) length function.)
mutable struct LlGraph
    n::Int
    vertices::Set{Int}
    adjmat::Matrix{Union{ListNode, Nothing}}
    testmat::Matrix{Bool}
    inlist::Vector{LinkedList{Int}}
    outlist::Vector{LinkedList{Int}}
    undirlist::Vector{LinkedList{Int}}
    inctr::Vector{Int}
    undirctr::Vector{Int}
    outctr::Vector{Int}
end

Base.deepcopy(llg::LlGraph) = begin
    llgcopy = emptyllgraph(nv(llg))
    for u = 1:nv(llg)
        for v in llg.undirlist[u]
            if !hasedge(llgcopy, u, v, false)
                addedge!(llgcopy, u, v, false)
            end
        end
        for v in llg.outlist[u]
            addedge!(llgcopy, u, v, true)
        end
    end
    return llgcopy
end

Base.:(==)(ll1::LinkedList, ll2::LinkedList) =
    [i for i in ll1] == [i for i in ll2]

Base.:(==)(llg1::LlGraph, llg2::LlGraph) =
    llg1.n == llg2.n &&
    llg1.vertices == llg2.vertices &&
    map(e->!isnothing(e), llg1.adjmat) == map(e->!isnothing(e), llg2.adjmat) &&
    llg1.testmat == llg2.testmat &&
    llg1.inlist == llg2.inlist &&
    llg1.outlist == llg2.outlist &&
    llg1.undirlist == llg2.undirlist &&
    llg1.inctr == llg2.inctr &&
    llg1.undirctr == llg2.undirctr &&
    llg1.outctr == llg2.outctr

function emptyllgraph(n::Int)::LlGraph
    return LlGraph(
        n,
        Set{Int}([i for i in 1:n]),
        fill(nothing, n, n),
        fill(false, n, n),
        [LinkedList{Int}() for _ in 1:n],
        [LinkedList{Int}() for _ in 1:n],
        [LinkedList{Int}() for _ in 1:n],
        [0 for _ in 1:n],
        [0 for _ in 1:n],
        [0 for _ in 1:n],
    )
end

function isadjacent(llg::LlGraph, u::Int, v::Int)::Bool
    return llg.testmat[u, v]
end

function hasedge(llg::LlGraph, u::Int, v::Int, isdir::Bool)::Bool
    !llg.testmat[u,v] && return false
    pointer = llg.adjmat[u, v]
    adjlist = isdir ? llg.outlist[u] : llg.undirlist[u]
    return !isnothing(pointer) && adjlist[pointer] == v
end

function hasoutgoing(llg::LlGraph, u::Int)::Bool
    return llg.outctr[u] > 0
end

function nv(llg::LlGraph)::Int
    return length(llg.vertices)
end

function ne(llg::LlGraph)::Int
    return convert(Int, (sum(map(l -> length(l), llg.undirlist)) / 2)) +
        sum(map(l -> length(l), llg.outlist))
end

function degree(llg::LlGraph, u::Int)::Int
    return llg.inctr[u] + llg.undirctr[u] + llg.outctr[u]
end

function addedge!(llg::LlGraph, u::Int, v::Int, isdir::Bool)
    llg.adjmat[u, v] = push!(isdir ? llg.outlist[u] : llg.undirlist[u], v)
    llg.adjmat[v, u] = push!(isdir ? llg.inlist[v] : llg.undirlist[v], u)
    llg.testmat[u, v] = true
    llg.testmat[v, u] = true
    if isdir
        llg.outctr[u] += 1
        llg.inctr[v] += 1
    else
        llg.undirctr[u] += 1
        llg.undirctr[v] += 1
    end
end

function remedge!(llg::LlGraph, u::Int, v::Int, isdir::Bool)
    deleteat!(isdir ? llg.outlist[u] : llg.undirlist[u], llg.adjmat[u, v])
    deleteat!(isdir ? llg.inlist[v] : llg.undirlist[v], llg.adjmat[v, u])
    llg.adjmat[u, v] = nothing
    llg.adjmat[v, u] = nothing
    llg.testmat[u, v] = false
    llg.testmat[v, u] = false
    if isdir
        llg.outctr[u] -= 1
        llg.inctr[v] -= 1
    else
        llg.undirctr[u] -= 1
        llg.undirctr[v] -= 1
    end
end