struct WblGraph
    g::Graph
    alpha::Vector{Int}
    beta::Vector{Int}
end

Base.deepcopy(wblg::WblGraph) = WblGraph(
    deepcopy(wblg.g),
    deepcopy(wblg.alpha),
    deepcopy(wblg.beta)
)

Base.:(==)(wblg1::WblGraph, wblg2::WblGraph) =
    wblg1.g == wblg2.g &&
    wblg1.alpha == wblg2.alpha &&
    wblg1.beta == wblg2.beta

function emptywblgraph(n::Int)::WblGraph
    return WblGraph(
        emptygraph(n),
        zeros(Int, n),
        zeros(Int, n)
    )
end

function isadjacent(wblg::WblGraph, u::Int, v::Int)::Bool
    return isadjacent(wblg.g, u, v)
end

function degree(wblg::WblGraph, v::Int)::Int
    return degree(wblg.g, v)
end

function hasedge(wblg::WblGraph, u::Int, v::Int, isdir::Bool)::Bool
    return hasedge(wblg.g, u, v, isdir)
end

function nv(wblg::WblGraph)::Int
    return nv(wblg.g)
end

function ne(wblg::WblGraph)::Int
    return ne(wblg.g)
end

function addedge!(wblg::WblGraph, u::Int, v::Int, isdir::Bool)
    addedge!(wblg.g, u, v, isdir)
    updatealphabeta!(wblg, u, v, +1)
end

function remedge!(wblg::WblGraph, u::Int, v::Int, isdir::Bool)
    updatealphabeta!(wblg, u, v, -1)
    remedge!(wblg.g, u, v, isdir)
end

function updatealphabeta!(wblg::WblGraph, u::Int, v::Int, val::Int)
    # Swap u and v if v has less neighbors than u to do less iterations
    nu = length(wblg.g.in[u]) + length(wblg.g.out[u]) + length(wblg.g.undir[u])
    nv = length(wblg.g.in[v]) + length(wblg.g.out[v]) + length(wblg.g.undir[v])
    if nu < nv
        u, v = v, u
    end

    for x in union(wblg.g.undir[u], wblg.g.undir[v])
        (isadjacent(wblg, x, v) && isadjacent(wblg, x, u)) || continue
        (u in wblg.g.undir[v]) && (u in wblg.g.undir[x]) && (wblg.alpha[u] += val)
        (u in wblg.g.undir[v]) && (u in wblg.g.out[x])   && (wblg.beta[u]  += val)
        (u in wblg.g.out[v])   && (u in wblg.g.undir[x]) && (wblg.beta[u]  += val)

        (v in wblg.g.undir[x]) && (v in wblg.g.undir[u]) && (wblg.alpha[v] += val)
        (v in wblg.g.undir[x]) && (v in wblg.g.out[u])   && (wblg.beta[v]  += val)
        (v in wblg.g.out[x])   && (v in wblg.g.undir[u]) && (wblg.beta[v]  += val)

        (x in wblg.g.undir[u]) && (x in wblg.g.undir[v]) && (wblg.alpha[x] += val)
        (x in wblg.g.out[u])   && (x in wblg.g.undir[v]) && (wblg.beta[x]  += val)
        (x in wblg.g.out[v])   && (x in wblg.g.undir[u]) && (wblg.beta[x]  += val)
    end
end
