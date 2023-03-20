@isdefined(LlGraph) || include("graph_ll.jl")

struct LlhGraph
    g::LlGraph
    vertices::Vector{Set{Int64}}
end

Base.deepcopy(llhg::LlhGraph) = LlhGraph(
    deepcopy(llhg.g),
    deepcopy(llhg.vertices)
)

Base.:(==)(hg1::LlhGraph, hg2::LlhGraph) =
    hg1.g == hg2.g &&
    hg1.vertices == hg2.vertices

function emptyllhgraph(n::Int)::LlhGraph
    return LlhGraph(
        emptygraph(n),
        [Set{Int64}() for _ in 1:n]
    )
end

function isadjacent(llhg::LlhGraph, u::Int, v::Int)::Bool
    return isadjacent(llhg.g, u, v)
end

function degree(llhg::LlhGraph, v::Int)::Int
    return degree(llhg.g, v)
end

function hasoutgoing(llhg::LlhGraph, u::Int)::Bool
    return hasoutgoing(llhg.g, u)
end

function hasedge(llhg::LlhGraph, u::Int, v::Int, isdir::Bool)::Bool
    return hasedge(llhg.g, u, v, isdir)
end

function nv(llhg::LlhGraph)::Int
    return nv(llhg.g)
end

function ne(llhg::LlhGraph)::Int
    return ne(llhg.g)
end

function addedge!(llhg::LlhGraph, u::Int, v::Int, isdir::Bool)
    addedge!(llhg.g, u, v, isdir)
end

function remedge!(llhg::LlhGraph, u::Int, v::Int, isdir::Bool)
    remedge!(llhg.g, u, v, isdir)
end