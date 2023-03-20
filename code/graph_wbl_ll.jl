using LinkedLists

mutable struct LlGraphWbl
    n::Int
    vertices::Set{Int}
    adjmat::Matrix{Union{ListNode, Nothing}}
    testmat_dir::Matrix{Bool}
    testmat_undir::Matrix{Bool}
    inlist::Vector{LinkedList{Int}}
    outlist::Vector{LinkedList{Int}}
    undirlist::Vector{LinkedList{Int}}
    inctr::Vector{Int}
    undirctr::Vector{Int}
    outctr::Vector{Int}
end

Base.deepcopy(llg::LlGraphWbl) = begin
    llgcopy = emptyllwblgraph(nv(llg))
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

Base.:(==)(llg1::LlGraphWbl, llg2::LlGraphWbl) =
    llg1.n == llg2.n &&
    llg1.vertices == llg2.vertices &&
    map(e->!isnothing(e), llg1.adjmat) == map(e->!isnothing(e), llg2.adjmat) &&
    llg1.testmat_dir == llg2.testmat_dir &&
    llg1.testmat_undir == llg2.testmat_undir &&
    llg1.inlist == llg2.inlist &&
    llg1.outlist == llg2.outlist &&
    llg1.undirlist == llg2.undirlist &&
    llg1.inctr == llg2.inctr &&
    llg1.undirctr == llg2.undirctr &&
    llg1.outctr == llg2.outctr

function emptyllwblgraph(n::Int)::LlGraphWbl
    return LlGraphWbl(
        n,
        Set{Int}([i for i in 1:n]),
        fill(nothing, n, n),
        fill(false, n, n),
        fill(false, n, n),
        [LinkedList{Int}() for _ in 1:n],
        [LinkedList{Int}() for _ in 1:n],
        [LinkedList{Int}() for _ in 1:n],
        [0 for _ in 1:n],
        [0 for _ in 1:n],
        [0 for _ in 1:n],
    )
end

function isadjacent(llg::LlGraphWbl, u::Int, v::Int)::Bool
    return llg.testmat_dir[u, v] || llg.testmat_dir[v, u] || llg.testmat_undir[u, v]
end

function hasedge(llg::LlGraphWbl, u::Int, v::Int, isdir::Bool)::Bool
    return isdir ? llg.testmat_dir[u, v] : llg.testmat_undir[u, v]
end

function hasoutgoing(llg::LlGraphWbl, u::Int)::Bool
    return llg.outctr[u] > 0
end

function nv(llg::LlGraphWbl)::Int
    return length(llg.vertices)
end

function ne(llg::LlGraphWbl)::Int
    return convert(Int, (sum(map(l -> length(l), llg.undirlist)) / 2)) +
        sum(map(l -> length(l), llg.outlist))
end

function degree(llg::LlGraphWbl, u::Int)::Int
    return llg.inctr[u] + llg.undirctr[u] + llg.outctr[u]
end

function addedge!(llg::LlGraphWbl, u::Int, v::Int, isdir::Bool)
    llg.adjmat[u, v] = push!(isdir ? llg.outlist[u] : llg.undirlist[u], v)
    llg.adjmat[v, u] = push!(isdir ? llg.inlist[v] : llg.undirlist[v], u)
    if isdir
        llg.testmat_dir[u, v] = true
        llg.outctr[u] += 1
        llg.inctr[v] += 1
    else
        llg.testmat_undir[u, v] = true
        llg.testmat_undir[v, u] = true
        llg.undirctr[u] += 1
        llg.undirctr[v] += 1
    end
end

function remedge!(llg::LlGraphWbl, u::Int, v::Int, isdir::Bool)
    deleteat!(isdir ? llg.outlist[u] : llg.undirlist[u], llg.adjmat[u, v])
    deleteat!(isdir ? llg.inlist[v] : llg.undirlist[v], llg.adjmat[v, u])
    llg.adjmat[u, v] = nothing
    llg.adjmat[v, u] = nothing
    if isdir
        llg.testmat_dir[u, v] = false
        llg.outctr[u] -= 1
        llg.inctr[v] -= 1
    else
        llg.testmat_undir[u, v] = false
        llg.testmat_undir[v, u] = false
        llg.undirctr[u] -= 1
        llg.undirctr[v] -= 1
    end
end


struct WblLlGraph
    g::LlGraphWbl
    alpha::Vector{Int}
    beta::Vector{Int}
end

Base.deepcopy(wblg::WblLlGraph) = WblLlGraph(
    deepcopy(wblg.g),
    deepcopy(wblg.alpha),
    deepcopy(wblg.beta)
)

Base.:(==)(wblg1::WblLlGraph, wblg2::WblLlGraph) =
    wblg1.g == wblg2.g &&
    wblg1.alpha == wblg2.alpha &&
    wblg1.beta == wblg2.beta

function emptywblllgraph(n::Int)::WblLlGraph
    return WblLlGraph(
        emptyllwblgraph(n),
        zeros(Int, n),
        zeros(Int, n)
    )
end

function isadjacent(wblg::WblLlGraph, u::Int, v::Int)::Bool
    return isadjacent(wblg.g, u, v)
end

function degree(wblg::WblLlGraph, v::Int)::Int
    return degree(wblg.g, v)
end

function hasedge(wblg::WblLlGraph, u::Int, v::Int, isdir::Bool)::Bool
    return hasedge(wblg.g, u, v, isdir)
end

function nv(wblg::WblLlGraph)::Int
    return nv(wblg.g)
end

function ne(wblg::WblLlGraph)::Int
    return ne(wblg.g)
end

function addedge!(wblg::WblLlGraph, u::Int, v::Int, isdir::Bool)
    addedge!(wblg.g, u, v, isdir)
    updatealphabeta!(wblg, u, v, +1)
end

function remedge!(wblg::WblLlGraph, u::Int, v::Int, isdir::Bool)
    updatealphabeta!(wblg, u, v, -1)
    remedge!(wblg.g, u, v, isdir)
end

function updatealphabeta!(wblg::WblLlGraph, u::Int, v::Int, val::Int)
    # Swap u and v if v has less neighbors than u to do less iterations
    nu = wblg.g.inctr[u] + wblg.g.outctr[u] + wblg.g.undirctr[u]
    nv = wblg.g.inctr[v] + wblg.g.outctr[v] + wblg.g.undirctr[v]
    if nu < nv
        u, v = v, u
    end

    for x in wblg.g.undirlist[u]
        addval!(wblg, u, v, x, val)
    end
    for x in wblg.g.inlist[u]
        addval!(wblg, u, v, x, val)
    end
    for x in wblg.g.outlist[u]
        addval!(wblg, u, v, x, val)
    end
end

function addval!(g::WblLlGraph, u::Int, v::Int, x::Int, val::Int)
    isadjacent(g, x, v) || return
    hasedge(g, u, v, false) && hasedge(g, u, x, false) && (g.alpha[u] += val)
    hasedge(g, u, v, false) && hasedge(g, x, u, true)  && (g.beta[u]  += val)
    hasedge(g, v, u, true)  && hasedge(g, u, x, false) && (g.beta[u]  += val)

    hasedge(g, v, x, false) && hasedge(g, u, v, false) && (g.alpha[v] += val)
    hasedge(g, v, x, false) && hasedge(g, u, v, true)  && (g.beta[v]  += val)
    hasedge(g, x, v, true)  && hasedge(g, u, v, false) && (g.beta[v]  += val)

    hasedge(g, u, x, false) && hasedge(g, v, x, false) && (g.alpha[x] += val)
    hasedge(g, u, x, true)  && hasedge(g, v, x, false) && (g.beta[x]  += val)
    hasedge(g, v, x, true)  && hasedge(g, u, x, false) && (g.beta[x]  += val)
end