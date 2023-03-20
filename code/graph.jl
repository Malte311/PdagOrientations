mutable struct Graph
    n::Int
    vertices::Set{Int}
    in::Vector{Set{Int}}
    out::Vector{Set{Int}}
    undir::Vector{Set{Int}}
end

Base.deepcopy(g::Graph) = Graph(
    g.n,
    deepcopy(g.vertices),
    deepcopy(g.in),
    deepcopy(g.out),
    deepcopy(g.undir)
)

Base.:(==)(g1::Graph, g2::Graph) =
    g1.n == g2.n &&
    g1.vertices == g2.vertices &&
    g1.in == g2.in &&
    g1.out == g2.out &&
    g1.undir == g2.undir

function emptygraph(n::Int)::Graph
    return Graph(
        n,
        Set{Int}([i for i in 1:n]),
        [Set{Int}() for _ in 1:n],
        [Set{Int}() for _ in 1:n],
        [Set{Int}() for _ in 1:n]
    )
end

function isadjacent(g::Graph, u::Int, v::Int)::Bool
    return (v in g.in[u]) || (v in g.out[u]) || (v in g.undir[u])
end

function degree(g::Graph, v::Int)::Int
    return length(g.in[v]) + length(g.out[v]) + length(g.undir[v])
end

function hasedge(g::Graph, u::Int, v::Int, isdir::Bool)::Bool
    return isdir ? (v in g.out[u]) : (v in g.undir[u])
end

function vertices(g::Graph)::Set{Int}
    return g.vertices
end

function outneighbors(g::Graph, v::Int)::Set{Int}
    return g.out[v]
end

function inneighbors(g::Graph, v::Int)::Set{Int}
    return g.in[v]
end

function undirneighbors(g::Graph, v::Int)::Set{Int}
    return g.undir[v]
end

function allneighbors(g::Graph, v::Int)::Set{Int}
    return union(g.in[v], g.out[v], g.undir[v])
end

function nv(g::Graph)::Int
    return length(g.vertices)
end

function ne(g::Graph)::Int
    return sum(length(g.in[v]) for v in g.vertices) +
        convert(Int, sum(length(g.undir[v]) for v in g.vertices) / 2)
end

function ndiredges(g::Graph)::Int
    return sum(length(g.in[v]) for v in g.vertices)
end

function nundiredges(g::Graph)::Int
    return convert(Int, sum(length(g.undir[v]) for v in g.vertices) / 2)
end

function addedge!(g::Graph, u::Int, v::Int, isdir::Bool)
    if isdir
        push!(g.out[u], v)
        push!(g.in[v], u)
    else
        push!(g.undir[u], v)
        push!(g.undir[v], u)
    end
end

function remedge!(g::Graph, u::Int, v::Int, isdir::Bool)
    if isdir
        delete!(g.out[u], v)
        delete!(g.in[v], u)
    else
        delete!(g.undir[u], v)
        delete!(g.undir[v], u)
    end
end

function directedge!(g::Graph, u::Int64, v::Int64)
    delete!(g.undir[u], v)
    delete!(g.undir[v], u)
    push!(g.in[v], u)
    push!(g.out[u], v)
end

function undirectedge!(g::Graph, u::Int64, v::Int64)
    delete!(g.out[u], v)
    delete!(g.in[v], u)
    push!(g.undir[v], u)
    push!(g.undir[u], v)
end

function isdag(g::Graph)::Bool
    return isdirected(g) && !iscyclic(g)
end

function isdirected(g::Graph)::Bool
    return reduce((x, y) -> x && y, map(x -> isempty(x), g.undir); init=true)
end

function iscyclic(g::Graph)::Bool
    # Expects a fully directed graph as input
    isdirected(g) || error("Input is no directed graph!")

    # 0: not visited, 1: in stack, 2: done
    visited = zeros(UInt8, nv(g))
    for v in g.vertices
        if visited[v] == 0
            stack = Vector{Int}([v])
            visited[v] = 1
            !iscyclic_rec(g, stack, visited) || return true
        end
    end

    return false
end

function iscyclic_rec(g::Graph, stack::Vector{Int}, visited::Vector{UInt8})::Bool
    for v in g.out[stack[end]]
        visited[v] != 1 || return true
        if visited[v] == 0
            push!(stack, v)
            visited[v] = 1
            !iscyclic_rec(g, stack, visited) || return true
        end
    end

    visited[stack[end]] = 2
    pop!(stack)

    return false
end

function skeleton(g::Graph)::Graph
    s = deepcopy(g)
    for v in g.vertices, w in g.out[v]
        undirectedge!(s, v, w)
    end
    return s
end

function orient_vstructs!(s::Graph, g::Graph)
    # Orient v-structures in s as in g
    for u in g.vertices, v in g.out[u], w in g.in[v]
        if u != w && !isadjacent(g, u, w)
            directedge!(s, u, v)
            directedge!(s, w, v)
        end
    end
end

function undir_components(g::Graph)::Vector{Set{Int}}
    visited = falses(nv(g))
    components = []
    for v in g.vertices
        if !visited[v]
            uccg = undir_visit(g, v, visited, Set{Int}())
            push!(components, uccg)
        end
    end
    return components
end

function undir_visit(g::Graph, v::Int, visited::BitVector, uccg::Set{Int})::Set{Int}
    visited[v] = true
    for w in g.undir[v]
        !visited[w] && undir_visit(g, w, visited, uccg)
    end
    push!(uccg, v)
    return uccg
end
