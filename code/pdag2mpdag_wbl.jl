struct Edge
    src::Int
    dst::Int
end

@isdefined(dag2cpdag)   || include("dag2cpdag.jl")
@isdefined(Measurement) || include("utils.jl")

"""
    fastmeek(g::Graph, m::Measurement, pdag2dag::Function = pdag2dag_dtch)::Graph

Compute the maximum orientation (MPDAG) of a partially directed acyclic graph
using the algorithm by Wienöbst, Bannach, and Liśkiewicz (2021) for applying
Meek's rules.

`m` is a helper struct for measuring the times of different steps inside of
the algorithm separately.

The parameter `pdag2dag` specifies the algorithm to be used to
compute a consistent DAG extension of the input in the beginning.
"""
function fastmeek(g::Graph, m::Measurement, pdag2dag::Function = pdag2dag_dtch)::Graph
    D = pdag2dag(g)
    add_measurement!(m, 1)

    C, ts = dag2cpdag(D)
    add_measurement!(m, 2)

    pos = zeros(Int, nv(g))
    for i = 1:nv(g)
        pos[ts[i]] = i
    end

    for U in undir_components(C)
        # v is by definition in U
        for u in U, v in C.undir[u]
          hasedge(g, u, v, true) && directedge!(C, u, v)
          hasedge(g, v, u, true) && directedge!(C, v, u)
        end
        

        for v in sort(collect(U), by=p -> pos[p])
            # Meek rule 1
            # a -> p - v => a -> p -> v
            for p in C.undir[v]
                (p in U && pos[p] < pos[v]) || continue
                for a in C.in[p]
                    a in U || continue
                    if a != p && a != v && !isadjacent(C, a, v)
                        directedge!(C, p, v)
                        break
                    end
                end
            end

            # Meek rule 4
            # d -> p -> v - a, a - p, => a -> v
            for p in C.in[v]
                (p in U && pos[p] < pos[v]) || continue
                for a in intersect(C.undir[p], C.undir[v])
                    (a in U && pos[a] < pos[v]) || continue
                    for d in C.in[p]
                        (d in U && d != a) || continue
                        if !isadjacent(C, d, v)
                            directedge!(C, a, v)
                            break
                        end
                    end
                end
            end

            # Meek rule 2
            # p -> b -> v and p - v => p -> v
            for p in sort(collect(C.undir[v]), by=p -> pos[p], rev=true)
                (p in U && pos[p] < pos[v]) || continue
                for b in intersect(C.out[p], C.in[v])
                    b in U || continue
                    directedge!(C, p, v)
                    break
                end
            end
        end
    end

    add_measurement!(m, 3)
    return C
end
