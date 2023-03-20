using Random

@isdefined(Graph)         || include("graph.jl")
@isdefined(ischordal)     || include("mcs.jl")
@isdefined(writegraph)    || include("utils.jl")
@isdefined(pdag2dag_dtch) || include("pdag2dag_dtch.jl")

"""
    generate_chordal(n::Int, k::Int, seed::Int = 123)::Graph

Generate an undirected chordal graph with `n` vertices using the
subtree intersection approach by Seker et al. (2017) with `2*k`
specifying the average size of the random subtrees.
"""
function generate_chordal(n::Int, k::Int, seed::Int = 123)::Graph
    Random.seed!(seed)
    G = emptygraph(n)

    # 1. Create a random tree
    tree = emptygraph(n)
    for v in 2:n
        u = rand(1:v-1)
        addedge!(tree, u, v, false)
    end

    # 2. Generate a random chordal graph via subtree-intersection
    caps = [Set{Int}() for _ in 1:n]
    for v in 1:n
        subtree = Set{Int}()
        border = Vector{Int}()
        nbrs = Set{Int}()
        size = min(n, rand(1:2*k))
        for _ in 1:size
            x = isempty(border) ? rand(1:nv(tree)) : border[rand(1:length(border))]
            push!(subtree, x)
            for u in allneighbors(tree, x)
                !(u in subtree) && push!(border, u)
            end
            x in border && deleteat!(border, findfirst(e -> e == x, border))
            for w in caps[x]
                w in nbrs && continue
                addedge!(G, v, w, false)
                push!(nbrs, w)
            end
            push!(caps[x], v)
        end
    end

    return G
end

"""
    generate_cpdag(n::Int, m::Int, sf::Bool = false, seed::Int = 123)::Graph

Generate a CPDAG with `n` vertices and `m` edges, by
applying the following algorithm:

1. Generate a random DAG. Set `sf` to true to generate a scale-free DAG.
2. Compute the skeleton of the DAG.
3. Orient v-structures in the skeleton and return the result.

"""
function generate_cpdag(n::Int, m::Int, sf::Bool = false, seed::Int = 123)::Graph
    Random.seed!(seed)
    D = sf ? scalefreedag(n, m, seed) : randomdag(n, m, seed)
    S = skeleton(D)
    orient_vstructs!(S, D)
    return S
end

"""
    generate_pdag(n::Int, m::Int, sf::Bool = false, seed::Int = 123)::Graph

Generate a PDAG with `n` vertices and `m` edges, by
applying the following algorithm:

1. Generate a random CPDAG.
2. Orient 2-5 randomly chosen edges in the CPDAG.

"""
function generate_pdag(n::Int, m::Int, sf::Bool = false, seed::Int = 123)::Graph
    Random.seed!(seed)
    G = generate_cpdag(n, m, sf, seed)
    D = pdag2dag_dtch(G)

    k = rand(2:5)
    undir_edges = Set{Tuple{Int,Int}}()
    for u = 1:nv(G), v = u+1:nv(G)
        t = (u < v ? u : v, u < v ? v : u)
        hasedge(G, u, v, false) && !(t in undir_edges) && push!(undir_edges, t)
    end

    @assert length(undir_edges) == nundiredges(G)
    @assert k < length(undir_edges)

    for _ = 1:k
        (u, v) = rand(undir_edges)
        remedge!(G, u, v, false)
        hasedge(D, u, v, true) && addedge!(G, u, v, true)
        hasedge(D, v, u, true) && addedge!(G, v, u, true)
        delete!(undir_edges, (u, v))
    end

    return G
end

"""
    scalefreedag(n::Int, m::Int, seed::Int = 123)::Graph

Generate a scale-free DAG with `n` vertices and `m` edges, by
applying the following algorithm:

1. Generate a scale-free undirected graph (Barabási-Albert model).
2. Generate a random permutation of the vertices.
3. Remove all edges violating the topological sorting given by the
random permutation.

"""
function scalefreedag(n::Int, m::Int, seed::Int = 123)::Graph
    Random.seed!(seed)
    G = Graphs.SimpleDiGraph(n)
    k = convert(Int, floor(1/2 * (n-sqrt(max(n^2 - 4*m, 0)))))

    # Use SimpleDiGraph instead of SimpleGraph
    for e in Graphs.edges(Graphs.barabasi_albert(n, k, seed=seed))
        Graphs.add_edge!(G, e.src, e.dst)
        Graphs.add_edge!(G, e.dst, e.src)
    end

    # Add random edges if there are not exactly m edges
    # (might happen as we have to specify k instead of m
    # in the Barabasi-Albert model)
    ecount = convert(Int, Graphs.ne(G) / 2)
    while ecount < m
        u = rand(1:n)
        v = rand(1:n)
        if u != v && !Graphs.has_edge(G, u, v) && !Graphs.has_edge(G, v, u)
            Graphs.add_edge!(G, u, v)
            Graphs.add_edge!(G, v, u)
            ecount += 1
        end
    end

    ts = randperm(n) # topological sorting
    for a in 1:n, b in Graphs.inneighbors(G, a)
        ts[b] < ts[a] && Graphs.rem_edge!(G, a, b)
    end

    return digraph2graph(G)
end

"""
    randomdag(n::Int, m::Int, seed::Int = 123)::Graph

Generate a random DAG with `n` vertices and `m` edges, by
applying the following algorithm:

1. Generate a random undirected graph (Erdős-Rényi model).
2. Generate a random permutation of the vertices.
3. Remove all edges violating the topological sorting given by the
random permutation.

"""
function randomdag(n::Int, m::Int, seed::Int = 123)::Graph
    Random.seed!(seed)
    G = Graphs.SimpleDiGraph(n)

    # Use SimpleDiGraph instead of SimpleGraph
    for e in Graphs.edges(Graphs.erdos_renyi(n, m, seed=seed))
        Graphs.add_edge!(G, e.src, e.dst)
        Graphs.add_edge!(G, e.dst, e.src)
    end

    ts = randperm(n) # topological sorting
    for a in 1:n, b in Graphs.inneighbors(G, a)
        ts[b] < ts[a] && Graphs.rem_edge!(G, a, b)
    end

    return digraph2graph(G)
end


l = length(ARGS)
allowed = ["all", "chordal", "cpdag", "pdag"]
if l < 1 || (l == 1 && !(ARGS[1] in allowed)) ||
        (l > 1 && !all(a -> a in setdiff(allowed, ["all"]), ARGS))
    msg = string(
        "Run this file via 'julia $PROGRAM_FILE <TYPE>' with TYPE being ",
        "'all' or one or more (separated by spaces) of ",
        join(setdiff(allowed, ["all"]), ", "),
        "."
    )
    @error msg
    exit()
end

types = ARGS[1] == "all" ? setdiff(allowed, ["all"]) : ARGS
for t in types
    if t == "chordal"
        for rep = 1:10
            for n in [128, 256, 512, 1024, 2048, 4096, 8192]
                for d in [3, 5, round(Int, log2(n)), round(Int, sqrt(n))]
                    nstr = lpad(n, 4, "0")
                    dstr = lpad(d, 2, "0")
                    rstr = lpad(rep, 2, "0")
                    f = string(@__DIR__, "/instances/extendability/chordal/", "chordal-$nstr-$dstr-$rstr.gr")
                    isfile(f) && continue
                    g = generate_chordal(n, d, rep)
                    writegraph(g, f, true)
                end
            end
        end
    elseif t == "cpdag"
        for rep = 1:10
            for n in [128, 256, 512, 1024, 2048, 4096, 8192]
                for d in [3, 5, round(Int, log2(n)), round(Int, sqrt(n))]
                    m = d*n
                    for sf in [false, true]
                        nstr = lpad(n, 4, "0")
                        mstr = lpad(m, 6, "0")
                        rstr = lpad(rep, 2, "0")
                        s = sf ? "ba" : "er"
                        f1 = string(@__DIR__, "/instances/maxorient/cpdag/", "cpdag-$nstr-$mstr-$s-$rstr.gr")
                        f2 = string(@__DIR__, "/instances/extendability/cpdag/", "cpdag-$nstr-$mstr-$s-$rstr.gr")
                        isfile(f1) && isfile(f2) && continue
                        g = generate_cpdag(n, m, sf, rep)
                        !isfile(f1) && writegraph(g, f1, false)
                        !isfile(f2) && writegraph(g, f2, false)
                    end
                end
            end
        end
    elseif t == "pdag"
        for rep = 1:10
            for n in [128, 256, 512, 1024, 2048, 4096, 8192]
                for d in [3, 5, round(Int, log2(n)), round(Int, sqrt(n))]
                    m = d*n
                    for sf in [false, true]
                        nstr = lpad(n, 4, "0")
                        mstr = lpad(m, 6, "0")
                        rstr = lpad(rep, 2, "0")
                        s = sf ? "ba" : "er"
                        f1 = string(@__DIR__, "/instances/maxorient/pdag/", "pdag-$nstr-$mstr-$s-$rstr.gr")
                        f2 = string(@__DIR__, "/instances/extendability/pdag/", "pdag-$nstr-$mstr-$s-$rstr.gr")
                        isfile(f1) && isfile(f2) && continue
                        seed_var = rep
                        while true
                            try
                                # Might throw an assertion error
                                g = generate_pdag(n, m, sf, seed_var)
                                !isfile(f1) && writegraph(g, f1, false)
                                !isfile(f2) && writegraph(g, f2, false)
                                break
                            catch
                                @warn "generate_pdag failed with seed $seed_var."
                                seed_var += 10
                            end
                        end
                    end
                end
            end
        end
    else
        @error "Unsupported input type: $t"
    end
end
