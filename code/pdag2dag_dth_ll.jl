@isdefined(LlGraph)  || include("graph_ll.jl")
@isdefined(LlhGraph) || include("graph_h_ll.jl")

function pdag2dag_dth_ll(g::LlGraph)::LlGraph
    n = nv(g)
    tmp = LlhGraph(deepcopy(g), [Set{Int64}() for _ in 1:n])
    res = deepcopy(g)

    setupllhgraph!(tmp)

    while n > 1
        s = findsink(tmp)
        if s == -1
            res.n = -1
            return res
        end

        # Orient all adjacent edges of s (towards s)
        for v in res.undirlist[s]
            remedge!(res, s, v, false)
            addedge!(res, v, s, true)
        end

        removesink!(tmp, s)

        n -= 1
    end

    return res
end

function setupllhgraph!(llhg::LlhGraph)
    for v = 1:nv(llhg)
        push!(llhg.vertices[degree(llhg, v)+1], v)
    end
end

function findsink(llhg::LlhGraph)::Int
    # First check vertices with degree 0, then degree 1, etc.
    for i = 1:nv(llhg)
        for v in llhg.vertices[i]
            issink(llhg, v) && return v
        end
    end

    return -1
end

function issink(llhg::LlhGraph, s::Int)::Bool
    hasoutgoing(llhg, s) && return false

    for u in llhg.g.undirlist[s]
        for v in llhg.g.undirlist[s]
            u != v || continue
            isadjacent(llhg, u, v) || return false
        end
        for v in llhg.g.inlist[s]
            isadjacent(llhg, u, v) || return false
        end
        for v in llhg.g.outlist[s]
            isadjacent(llhg, u, v) || return false
        end
    end

    return true
end

function removesink!(llhg::LlhGraph, s::Int)
    # Assumption: s is a sink (i.e., there are no outgoing edges)
    delete!(llhg.vertices[degree(llhg, s)+1], s)

    for v in llhg.g.inlist[s]
        deg = degree(llhg, v)
        delete!(llhg.vertices[deg+1], v)
        push!(llhg.vertices[deg], v)
        remedge!(llhg, v, s, true)
    end
    for v in llhg.g.undirlist[s]
        deg = degree(llhg, v)
        delete!(llhg.vertices[deg+1], v)
        push!(llhg.vertices[deg], v)
        remedge!(llhg, s, v, false)
    end

    delete!(llhg.g.vertices, s)
    llhg.g.n -= 1
end