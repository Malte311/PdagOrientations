@isdefined(Measurement) || include("utils.jl")

"""
    meek(g::Graph, m::Measurement)::Graph

Compute the maximum orientation (MPDAG) of a partially directed acyclic graph
using the algorithm by Meek applied naively.

`m` is a helper struct for measuring times.
"""
function meek(g::Graph, m::Measurement)::Graph
    g = deepcopy(g)

    while true
        changed = false

        # Meek rule 1
        # a -> b - c => b -> c
        for b in g.vertices, c in g.undir[b]
            for a in g.in[b]
                if a != b && a != c && !isadjacent(g, a, c)
                    directedge!(g, b, c)
                    changed = true
                    break
                end
            end
        end

        # Meek rule 2
        # a -> b -> c and a - c => a -> c
        for a in g.vertices, c in g.undir[a]
            if !isempty(intersect(g.out[a], g.in[c]))
                directedge!(g, a, c)
                changed = true
            end
        end

        # Meek rule 3
        # a - d -> c <- b with a - b and a - c => a -> c
        for d in g.vertices, c in g.out[d], b in g.in[c]
            if b != d && !isadjacent(g, b, d)
                for a in intersect(g.undir[b], g.undir[c], g.undir[d])
                    directedge!(g, a, c)
                    changed = true
                end
            end
        end

        # Meek rule 4
        # d -> c -> b with a - b, a - c, and a - d => a -> b
        for c in g.vertices, b in g.out[c], d in g.in[c]
            if b != d && !isadjacent(g, b, d)
                for a in intersect(g.undir[b], g.undir[c], g.undir[d])
                    directedge!(g, a, b)
                    changed = true
                end
            end
        end

        !changed && break
    end

    add_measurement!(m, 1)
    return g
end