@isdefined(LlGraph) || include("graph_ll.jl")

struct EllhGraph
    g::LlGraph
    lastn_1::Vector{ListNode}
    lastn_2::Vector{ListNode}
    removed::Vector{Bool}
    lastl::Vector{Bool}
    vertices::Vector{Set{Int}}
end

Base.deepcopy(ellg::EllhGraph) = EllhGraph(
    deepcopy(ellg.g),
    deepcopy(ellg.lastn_1),
    deepcopy(ellg.lastn_2),
    deepcopy(ellg.removed),
    deepcopy(ellg.lastl),
    deepcopy(ellg.vertices),
)

Base.:(==)(ellg1::EllhGraph, ellg2::EllhGraph) =
    ellg1.g == ellg2.g &&
    ellg1.lastn_1 == ellg2.lastn_1 &&
    ellg1.lastn_2 == ellg2.lastn_2 &&
    ellg1.removed == ellg2.removed &&
    ellg1.lastl == ellg2.lastl &&
    ellg1.vertices == ellg2.vertices

function emptyellhgraph(n::Int)::EllhGraph
    return EllhGraph(
        emptyllgraph(n),
        Vector{ListNode}(undef, n),
        Vector{ListNode}(undef, n),
        falses(n),
        falses(n),
        [Set{Int}() for _ in 1:n],
    )
end

function isadjacent(ellg::EllhGraph, u::Int, v::Int)::Bool
    return isadjacent(ellg.g, u, v)
end

function degree(ellg::EllhGraph, u::Int)::Int
    return degree(ellg.g, u)
end

function hasoutgoing(ellg::EllhGraph, u::Int)::Bool
    return hasoutgoing(ellg.g, u)
end

function hasedge(ellg::EllhGraph, u::Int, v::Int, isdir::Bool)::Bool
    return hasedge(ellg.g, u, v, isdir)
end

function nv(ellg::EllhGraph)::Int
    return nv(ellg.g)
end

function ne(ellg::EllhGraph)::Int
    return ne(ellg.g)
end

function addedge!(ellg::EllhGraph, u::Int, v::Int, isdir::Bool)
    addedge!(ellg.g, u, v, isdir)
end

function remedge!(ellg::EllhGraph, u::Int, v::Int, isdir::Bool)
    remedge!(ellg.g, u, v, isdir)
end