struct HGraph
    g::Graph
    vertices::Vector{Set{Int64}}
end

Base.deepcopy(hg::HGraph) = HGraph(
    deepcopy(hg.g),
    deepcopy(hg.vertices)
)

Base.:(==)(hg1::HGraph, hg2::HGraph) =
    hg1.g == hg2.g &&
    hg1.vertices == hg2.vertices

function emptyhgraph(n::Int)::HGraph
    return HGraph(emptygraph(n), [Set{Int64}() for _ in 1:n])
end

function isadjacent(hg::HGraph, u::Int, v::Int)::Bool
    return isadjacent(hg.g, u, v)
end

function degree(hg::HGraph, v::Int)::Int
    return degree(hg.g, v)
end

function hasedge(hg::HGraph, u::Int, v::Int, isdir::Bool)::Bool
    return hasedge(hg.g, u, v, isdir)
end

function nv(hg::HGraph)::Int
    return nv(hg.g)
end

function ne(hg::HGraph)::Int
    return ne(hg.g)
end

function addedge!(hg::HGraph, u::Int, v::Int, isdir::Bool)
    addedge!(hg.g, u, v, isdir)
end

function remedge!(hg::HGraph, u::Int, v::Int, isdir::Bool)
    remedge!(hg.g, u, v, isdir)
end