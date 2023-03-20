"""
    pdag2dag_dt(g::Graph)::Graph

Compute a consistent DAG extension of a partially directed acyclic graph
using the algorithm by Dor and Tarsi.
"""
function pdag2dag_dt(g::Graph)::Graph
    tmp = deepcopy(g)
    res = deepcopy(g)
    n = nv(tmp)

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

function findsink(g::Graph)::Int
    for w in g.vertices
        issink(g, w) && return w
    end

    return -1
end

function issink(g::Graph, s::Int)::Bool
    isempty(g.out[s]) || return false

    for u in g.undir[s]
        for v in union(g.in[s], g.undir[s])
            u != v || continue
            isadjacent(g, u, v) || return false
        end
    end

    return true
end

function removesink!(g::Graph, s::Int)
    # Assumption: s is a sink (i.e., there are no outgoing edges)
    for v in g.in[s]
        remedge!(g, v, s, true)
    end
    for v in g.undir[s]
        remedge!(g, s, v, false)
    end
    delete!(g.vertices, s)
    g.n -= 1
end