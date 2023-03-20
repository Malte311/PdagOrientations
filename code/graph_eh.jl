struct EhGraph
    g::Graph
    vertices::Vector{Set{Int64}}
    badn::Vector{Set{Tuple{Int, Int}}}
    badnof::Vector{Dict{Int, Set{Int}}}
    nchecked::BitVector
end

Base.deepcopy(ehg::EhGraph) = EhGraph(
    deepcopy(ehg.g),
    deepcopy(ehg.vertices),
    deepcopy(ehg.badn),
    deepcopy(ehg.badnof),
    deepcopy(ehg.nchecked)
)

Base.:(==)(ehg1::EhGraph, ehg2::EhGraph) =
    ehg1.g == ehg2.g &&
    ehg1.vertices == ehg2.vertices &&
    ehg1.badn == ehg2.badn &&
    ehg1.badnof == ehg2.badnof &&
    ehg1.nchecked == ehg2.nchecked

function emptyehgraph(n::Int)::EhGraph
    return EhGraph(
        emptygraph(n),
        [Set{Int64}() for _ in 1:n],
        [Set{Tuple{Int, Int}}() for _ in 1:n],
        [Dict{Int, Set{Int}}() for _ in 1:n],
        falses(n)
    )
end

function isadjacent(ehg::EhGraph, u::Int, v::Int)::Bool
    return isadjacent(ehg.g, u, v)
end

function degree(ehg::EhGraph, v::Int)::Int
    return degree(ehg.g, v)
end

function hasedge(ehg::EhGraph, u::Int, v::Int, isdir::Bool)::Bool
    return hasedge(ehg.g, u, v, isdir)
end

function nv(ehg::EhGraph)::Int
    return nv(ehg.g)
end

function ne(ehg::EhGraph)::Int
    return ne(ehg.g)
end

function addedge!(ehg::EhGraph, u::Int, v::Int, isdir::Bool)
    addedge!(ehg.g, u, v, isdir)
end

function remedge!(ehg::EhGraph, u::Int, v::Int, isdir::Bool)
    remedge!(ehg.g, u, v, isdir)
end