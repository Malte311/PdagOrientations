@isdefined(LlGraph)   || include("graph_ll.jl")
@isdefined(EllhGraph) || include("graph_eh_ll.jl")

function pdag2dag_dtch_ll(g::LlGraph)::LlGraph
    n = nv(g)
    tmp = EllhGraph(
        deepcopy(g),
        Vector{ListNode}(undef, n),
        Vector{ListNode}(undef, n),
        falses(n),
        falses(n),
        [Set{Int}() for _ in 1:n],
    )
    res = deepcopy(g)

    setupellhgraph!(tmp)

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

function setupellhgraph!(ellg::EllhGraph)
    for v = 1:nv(ellg)
        push!(ellg.vertices[degree(ellg, v)+1], v)
    end
end

function findsink(ellg::EllhGraph)::Int
    # First check vertices with degree 0, then degree 1, etc.
    for i = 1:nv(ellg)
        for v in ellg.vertices[i]
            issink(ellg, v) && return v
        end
    end

    return -1
end

function issink(ellg::EllhGraph, s::Int)::Bool
    hasoutgoing(ellg, s) && return false

    if isassigned(ellg.lastn_1, s)
        curr_u = ellg.lastn_1[s]
    else
        curr_u = ellg.g.undirlist[s].node.next # First element of list
    end

    if isassigned(ellg.lastn_2, s)
        curr_v = ellg.lastn_2[s]
    else
        curr_v = ellg.g.undirlist[s].node.next # First element of list
    end

    while !has_end_reached(ellg.g.undirlist[s], curr_u)
        u = ellg.g.undirlist[s][curr_u]
        if ellg.removed[u]
            curr_u = curr_u.next
            curr_v = ellg.g.undirlist[s].node.next # First element of list
            ellg.lastl[s] = false
            continue
        end

        while true
            l = ellg.lastl[s] ? ellg.g.inlist : ellg.g.undirlist
            while !has_end_reached(l[s], curr_v)
                v = l[s][curr_v]
                if !isadjacent(ellg, u, v) && !ellg.removed[v] && u != v
                    ellg.lastn_1[s] = curr_u
                    ellg.lastn_2[s] = curr_v
                    return false
                end
                curr_v = curr_v.next
            end
            ellg.lastl[s] && break
            ellg.lastl[s] = true # undir neighbors done, continue with ingoing
            curr_v = ellg.g.inlist[s].node.next # First element of list
        end

        curr_u = curr_u.next
        curr_v = ellg.g.undirlist[s].node.next # First element of list
        ellg.lastl[s] = false
    end

    return true
end

function has_end_reached(l::LinkedList, v::ListNode)::Bool
    return l.node == v
end

function removesink!(ellg::EllhGraph, s::Int)
    # Assumption: s is a sink (i.e., there are no outgoing edges)
    delete!(ellg.vertices[degree(ellg, s)+1], s)

    for v in ellg.g.inlist[s]
        deg = degree(ellg, v)
        delete!(ellg.vertices[deg+1], v)
        push!(ellg.vertices[deg], v)
        remedge!(ellg, v, s, true)
    end
    for v in ellg.g.undirlist[s]
        deg = degree(ellg, v)
        delete!(ellg.vertices[deg+1], v)
        push!(ellg.vertices[deg], v)
        remedge!(ellg, s, v, false)
    end

    delete!(ellg.g.vertices, s)
    ellg.g.n -= 1
    ellg.removed[s] = true
end