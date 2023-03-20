@isdefined(LlGraph) || include("graph_ll.jl")

function pdag2dag_dt_ll(g::LlGraph)::LlGraph
    n = nv(g)
    tmp = deepcopy(g)
    res = deepcopy(g)

    while n > 1
        s = findsink(tmp)
        if s == -1
            res.n = -1
            return res
        end

        # Orient all undirected adjacent edges of s (towards s)
        for v in res.undirlist[s]
            remedge!(res, v, s, false)
            addedge!(res, v, s, true)
        end

        removesink!(tmp, s)

        n -= 1
    end

    return res
end

function findsink(llg::LlGraph)::Int
    for w in llg.vertices
        issink(llg, w) && return w
    end

    return -1
end

function issink(llg::LlGraph, s::Int)::Bool
    hasoutgoing(llg, s) && return false

    for u in llg.undirlist[s]
        for v in llg.undirlist[s]
            u != v || continue
            isadjacent(llg, u, v) || return false
        end
        for v in llg.inlist[s]
            isadjacent(llg, u, v) || return false
        end
        for v in llg.outlist[s]
            isadjacent(llg, u, v) || return false
        end
    end

    return true
end

function removesink!(llg::LlGraph, s::Int)
    # Assumption: s is a sink (i.e., there are no outgoing edges)
    for v in llg.undirlist[s]
        remedge!(llg, v, s, false)
    end
    for v in llg.inlist[s]
        remedge!(llg, v, s, true)
    end

    delete!(llg.vertices, s)
    llg.n -= 1
end