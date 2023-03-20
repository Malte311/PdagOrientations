"""
    pdag2dag_wbl(g::Graph)::Graph

Compute a consistent DAG extension of a partially directed acyclic graph
using the algorithm by Wienöbst, Bannach, and Liśkiewicz (2021).
"""
function pdag2dag_wbl(g::Graph)::Graph
    tmp = setupwbldograph(g)
    res = deepcopy(g)

    sinks = listsinks(tmp)
    while !isempty(sinks)
        s = pop!(sinks)

        for v in res.undir[s]
            remedge!(res, s, v, false)
            addedge!(res, v, s, true)
        end

        popsink!(tmp, sinks, s)
    end

    ne(tmp) > 0 && (res.n = -1)
    return res
end

function setupwbldograph(g::Graph)::WblGraph
    wblg = emptywblgraph(nv(g))

    (ordering, index) = degeneracyorder(g)

    for v in ordering
        for u in g.undir[v]
            index[u] < index[v] && addedge!(wblg, u, v, false)
        end
        for u in g.out[v]
            index[u] < index[v] && addedge!(wblg, v, u, true)
        end
        for u in g.in[v]
            index[u] < index[v] && addedge!(wblg, u, v, true)
        end
    end

    return wblg
end

function degeneracyorder(g::Graph)::Tuple{Vector{Int}, Vector{Int}}
    # Reference: David W. Matula, Leland L. Beck (1983).
    j = nv(g)
    gcopy = deepcopy(g)
    result = Vector{Int}(undef, j)
    index = Vector{Int}(undef, j)

    # Compute initial degrees for each vertex, updated in each iteration
    (auxarray, degstr) = degstruct(gcopy)

    while j > 0
        v = popmindegvertex!(degstr)

        for u in gcopy.undir[v]
            updatedegs!(u, auxarray, degstr)
            remedge!(gcopy, u, v, false)
        end

        for u in gcopy.in[v]
            updatedegs!(u, auxarray, degstr)
            remedge!(gcopy, u, v, true)
        end

        for u in gcopy.out[v]
            updatedegs!(u, auxarray, degstr)
            remedge!(gcopy, v, u, true)
        end

        result[j] = v
        index[v] = j
        j -= 1
    end

    return (result, index)
end

function degstruct(g::Graph)::Tuple{Vector{Int}, Vector{Set{Int}}}
    n = nv(g)
    auxarray = Vector{Int}(undef, n)
    degstr = [Set{Int}() for _ in 1:n]

    for v = 1:n
        deg = degree(g, v)
        auxarray[v] = deg
        push!(degstr[deg+1], v)
    end

    return (auxarray, degstr)
end

function popmindegvertex!(degs::Vector{Set{Int}})::Int
    for deg = 1:length(degs)
        !isempty(degs[deg]) && return pop!(degs[deg])
    end

    return -1
end

function updatedegs!(v::Int, aux::Vector{Int}, degs::Vector{Set{Int}})
    index = aux[v]+1 # Index 1 holds degree 0, index 2 degree 1, etc.
    delete!(degs[index], v)
    push!(degs[index-1], v)
    aux[v] -= 1
end

function listsinks(wblg::WblGraph)::Set{Int}
    result = Set{Int}()

    for v in wblg.g.vertices
        issink(wblg, v) && push!(result, v)
    end

    return result
end

function issink(wblg::WblGraph, s::Int)::Bool
    isempty(wblg.g.out[s]) &&
    wblg.beta[s] == length(wblg.g.undir[s]) * length(wblg.g.in[s]) &&
    wblg.alpha[s] == binomial(length(wblg.g.undir[s]), 2)
end

function popsink!(wblg::WblGraph, sinks::Set{Int}, s::Int)
    oldn = union(wblg.g.undir[s], wblg.g.in[s])

    # Delete directed edges first
    for u in wblg.g.in[s]
        for v in wblg.g.undir[s]
            (u in wblg.g.undir[v]) && (wblg.alpha[v] += -1)
            (u in wblg.g.in[v])    && (wblg.beta[v]  += -1)
        end
        remedge!(wblg.g, u, s, true) # No update of alpha, beta
    end

    # Deleted undirected edges
    for u in wblg.g.undir[s]
        remedge!(wblg, u, s, false) # Update of alpha, beta
    end

    # Check if neighbors became a sink
    for v in oldn
        issink(wblg, v) && push!(sinks, v)
    end
end