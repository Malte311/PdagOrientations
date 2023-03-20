import Graphs

@isdefined(LlGraph)    || include("graph_ll.jl")
@isdefined(WblLlGraph) || include("graph_wbl_ll.jl")

# Helper struct to measure parts of maximum orientation separately
mutable struct Measurement
    start::UInt
    last::UInt
    times::Vector{Vector{UInt}}
end

function readgraph(file = stdin, undirected = false)::Graph
    io = open(file, "r")

    (n, m) = parse.(Int, split(readline(io), " "))
    readline(io) # Remove empty line
    g = emptygraph(n)

    for _ = 1:m
        (u, v) = parse.(Int, split(readline(io), " "))
        addedge!(g, u, v, !undirected)
    end

    close(io)
    undirected && return g

    for u = 1:nv(g)
        for v = u+1:nv(g)
            if hasedge(g, u, v, true) && hasedge(g, v, u, true)
                remedge!(g, u, v, true)
                remedge!(g, v, u, true)
                addedge!(g, u, v, false)
            end
        end
    end

    return g
end

function writegraph(g::Graph, file = stdout, undirected = false)
    n = nv(g)
    m = ndiredges(g) + (undirected ? 1 : 2) * nundiredges(g)
    done = Set{Tuple{Int, Int}}()
    open(file, "w") do io
        write(io, "$n $m\n\n")
        for u in vertices(g)
            for v in outneighbors(g, u)
                write(io, "$u $v\n")
            end
            for v in undirneighbors(g, u)
                if !((u, v) in done)
                    write(io, "$u $v\n")
                    undirected && push!(done, (v, u))
                end
            end
        end
    end
end

function digraph2graph(g::Graphs.DiGraph)::Graph
    res = emptygraph(Graphs.nv(g))
    for u = 1:Graphs.nv(g)
        for v in Graphs.outneighbors(g, u)
            if Graphs.has_edge(g, v, u)
                !hasedge(res, u, v, false) && addedge!(res, u, v, false)
            else
                !hasedge(res, u, v, true) && addedge!(res, u, v, true)
            end
        end
    end
    return res
end

function graph2llgraph(g::Graph, iswbl::Bool)::Union{LlGraph, LlGraphWbl}
    res = iswbl ? emptyllwblgraph(nv(g)) : emptyllgraph(nv(g))
    for u = 1:nv(g)
        for v in g.undir[u]
            !hasedge(res, u, v, false) && addedge!(res, u, v, false)
        end
        for v in g.out[u]
            !hasedge(res, u, v, true) && addedge!(res, u, v, true)
        end
    end
    return res
end

function llgraph2graph(g::Union{LlGraph, LlGraphWbl})::Graph
    res = emptygraph(nv(g))
    for u = 1:nv(g)
        for v in g.undirlist[u]
            !hasedge(res, u, v, false) && addedge!(res, u, v, false)
        end
        for v in g.outlist[u]
            !hasedge(res, u, v, true) && addedge!(res, u, v, true)
        end
    end
    return res
end

function isvalidext(g1::Graph, g2::Graph)::Bool
    # Checks whether g1 is a consistent DAG extension of g2
    # (i.e., g1 is a DAG with the same skeleton and v-structs as g2)
    (g1.n != -1 && nv(g1) == nv(g2) && isdag(g1)) || return false

    skel1 = skeleton(g1)
    skel2 = skeleton(g2)

    skel1 == skel2 || return false

    orient_vstructs!(skel1, g1)
    orient_vstructs!(skel2, g2)

    return skel1 == skel2
end

function isvalidext(g1::LlGraph, g2::LlGraph)::Bool
    return isvalidext(llgraph2graph(g1), llgraph2graph(g2))
end

function isvalidext(g1::LlGraphWbl, g2::LlGraphWbl)::Bool
    return isvalidext(llgraph2graph(g1), llgraph2graph(g2))
end

function nanosec2millisec(t)
    # Nano /1000 -> Micro /1000 -> Milli /1000 -> Second
    return t / 1000 / 1000
end

function add_measurement!(m::Measurement, idx::Int)
    elapsed = time_ns() - m.last
    push!(m.times[idx], elapsed)
    m.last = time_ns()
end
