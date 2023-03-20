@isdefined(WblLlGraph) || include("graph_wbl_ll.jl")

function pdag2dag_wbl_ll(g::LlGraphWbl)::LlGraphWbl
    tmp = setupwblllgraph(g)
    res = deepcopy(g)

    sinks = listsinks(tmp)
    while !isempty(sinks)
        s = pop!(sinks)

        for v in res.undirlist[s]
            remedge!(res, s, v, false)
            addedge!(res, v, s, true)
        end

        popsink!(tmp, sinks, s)
    end

    ne(tmp) > 0 && (res.n = -1)
    return res
end

function setupwblllgraph(g::LlGraphWbl)::WblLlGraph
    wblg = emptywblllgraph(nv(g))

    (ordering, index) = degeneracyorder(g)

    for v in ordering
        for u in g.undirlist[v]
            index[u] < index[v] && addedge!(wblg, u, v, false)
        end
        for u in g.outlist[v]
            index[u] < index[v] && addedge!(wblg, v, u, true)
        end
        for u in g.inlist[v]
            index[u] < index[v] && addedge!(wblg, u, v, true)
        end
    end

    return wblg
end

function degeneracyorder(g::LlGraphWbl)::Tuple{Vector{Int}, Vector{Int}}
    # Reference: David W. Matula, Leland L. Beck (1983).
    j = nv(g)
    gcopy = deepcopy(g)
    result = Vector{Int}(undef, j)
    index = Vector{Int}(undef, j)

    # Compute initial degrees for each vertex, updated in each iteration
    (auxarray, degstr) = degstruct(gcopy)

    while j > 0
        v = popmindegvertex!(degstr)

        for u in gcopy.undirlist[v]
            updatedegs!(u, auxarray, degstr)
            remedge!(gcopy, u, v, false)
        end

        for u in gcopy.inlist[v]
            updatedegs!(u, auxarray, degstr)
            remedge!(gcopy, u, v, true)
        end

        for u in gcopy.outlist[v]
            updatedegs!(u, auxarray, degstr)
            remedge!(gcopy, v, u, true)
        end

        result[j] = v
        index[v] = j
        j -= 1
    end

    return (result, index)
end

function degstruct(g::LlGraphWbl)::Tuple{Vector{Int}, Vector{Set{Int}}}
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

function listsinks(wblg::WblLlGraph)::Set{Int}
    result = Set{Int}()

    for v in wblg.g.vertices
        issink(wblg, v) && push!(result, v)
    end

    return result
end

function issink(wblg::WblLlGraph, s::Int)::Bool
    wblg.g.outctr[s] == 0 &&
    wblg.beta[s] == wblg.g.undirctr[s] * wblg.g.inctr[s] &&
    wblg.alpha[s] == binomial(wblg.g.undirctr[s], 2)
end

function popsink!(wblg::WblLlGraph, sinks::Set{Int}, s::Int)
    # Delete directed edges first
    for u in wblg.g.inlist[s]
        for v in wblg.g.undirlist[s]
            hasedge(wblg, u, v, false) && (wblg.alpha[v] += -1)
            hasedge(wblg, u, v, true)  && (wblg.beta[v]  += -1)
        end
        remedge!(wblg.g, u, s, true) # No update of alpha, beta
        issink(wblg, u) && push!(sinks, u)
    end

    # Deleted undirected edges
    for u in wblg.g.undirlist[s]
        remedge!(wblg, u, s, false) # Update of alpha, beta
        issink(wblg, u) && push!(sinks, u)
    end
end