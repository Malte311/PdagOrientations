@isdefined(EhGraph) || include("graph_eh.jl")

"""
    pdag2dag_dtch(g::Graph)::Graph

Compute a consistent DAG extension of a partially directed acyclic graph
using the algorithm by Dor and Tarsi with a cache for already checked
neighbours and a heuristic when iterating over the vertices.
"""
function pdag2dag_dtch(g::Graph)::Graph
    n = nv(g)
    tmp = EhGraph(
        deepcopy(g),
        [Set{Int64}() for _ in 1:n],
        [Set{Tuple{Int, Int}}() for _ in 1:n],
        [Dict{Int, Set{Int}}() for _ in 1:n],
        falses(n)
    )
    res = deepcopy(g)

    setupehgraph!(tmp)

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

function setupehgraph!(ehg::EhGraph)
    for v = 1:nv(ehg)
        push!(ehg.vertices[degree(ehg, v)+1], v)
    end
end

function findsink(ehg::EhGraph)::Int
    # First check vertices with degree 0, then degree 1, etc.
    for i = 1:nv(ehg)
        for v in ehg.vertices[i]
            issink(ehg, v) && return v
        end
    end

    return -1
end

function issink(ehg::EhGraph, s::Int)::Bool
    isempty(ehg.g.out[s]) || return false
    isempty(ehg.badn[s]) || return false
    ehg.nchecked[s] && return true

    flag = true
    for u in ehg.g.undir[s]
        for v in union(ehg.g.in[s], ehg.g.undir[s])
            u != v || continue
            if !isadjacent(ehg, u, v)
                push!(ehg.badn[s], otuple(u, v))
                addatkey!(ehg.badnof[u], s, v)
                addatkey!(ehg.badnof[v], s, u)
                flag = false
            end
        end
    end
    ehg.nchecked[s] = true

    return flag
end

function removesink!(ehg::EhGraph, s::Int)
    # Assumption: s is a sink (i.e., there are no outgoing edges)
    # and ehg.badn[s] is never accessed after deleting s
    delete!(ehg.vertices[degree(ehg, s)+1], s)

    for v in ehg.g.in[s]
        deg = degree(ehg, v)
        delete!(ehg.vertices[deg+1], v)
        push!(ehg.vertices[deg], v)
        remedge!(ehg.g, v, s, true)
    end
    for v in ehg.g.undir[s]
        deg = degree(ehg, v)
        delete!(ehg.vertices[deg+1], v)
        push!(ehg.vertices[deg], v)
        remedge!(ehg.g, s, v, false)
    end

    for (key, val) in ehg.badnof[s]
        for v in val
            delete!(ehg.badn[key], otuple(s, v))
            delete!(ehg.badnof[v][key], s)
        end
    end

    delete!(ehg.g.vertices, s)
    ehg.g.n -= 1
end

function otuple(u::Int, v::Int)::Tuple{Int, Int}
    # Ordered tuple (smallest value first)
    return u < v ? (u, v) : (v, u)
end

function addatkey!(dict::Dict{Int, Set{Int}}, key::Int, val::Int)
    # Adds val to the set at key, or creates a new set if key is not in dict
    if !haskey(dict, key)
        dict[key] = Set{Int}([val])
    else
        push!(dict[key], val)
    end
end