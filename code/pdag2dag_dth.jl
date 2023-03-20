"""
    pdag2dag_dth(g::Graph)::Graph

Compute a consistent DAG extension of a partially directed acyclic graph
using the algorithm by Dor and Tarsi with a heuristic when iterating over
the vertices.
"""
function pdag2dag_dth(g::Graph)::Graph
    n = nv(g)
    tmp = HGraph(deepcopy(g), [Set{Int64}() for _ in 1:n])
    res = deepcopy(g)

    setuphgraph!(tmp)

    while n > 1
        s = findsink(tmp)
        if s == -1
            res.n = -1
            return res
        end

        # Orient all adjacent edges of s (towards s)
        for v in res.undir[s]
            remedge!(res, s, v, false)
            addedge!(res, v, s, true)
        end

        removesink!(tmp, s)

        n -= 1
    end

    return res
end

function setuphgraph!(hg::HGraph)
    for v = 1:nv(hg)
        push!(hg.vertices[degree(hg, v)+1], v)
    end
end

function findsink(hg::HGraph)::Int
    # First check vertices with degree 0, then degree 1, etc.
    for i = 1:nv(hg)
        for v in hg.vertices[i]
            issink(hg, v) && return v
        end
    end

    return -1
end

function issink(hg::HGraph, s::Int)::Bool
    isempty(hg.g.out[s]) || return false

    for u in hg.g.undir[s]
        for v in union(hg.g.in[s], hg.g.undir[s])
            u != v && !isadjacent(hg, u, v) && return false
        end
    end

    return true
end

function removesink!(hg::HGraph, s::Int)
    # Assumption: s is a sink (i.e., there are no outgoing edges)
    delete!(hg.vertices[degree(hg, s)+1], s)

    for v in hg.g.in[s]
        deg = degree(hg, v)
        delete!(hg.vertices[deg+1], v)
        push!(hg.vertices[deg], v)
        remedge!(hg.g, v, s, true)
    end
    for v in hg.g.undir[s]
        deg = degree(hg, v)
        delete!(hg.vertices[deg+1], v)
        push!(hg.vertices[deg], v)
        remedge!(hg.g, s, v, false)
    end

    delete!(hg.g.vertices, s)
    hg.g.n -= 1
end