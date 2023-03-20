using LinkedLists

function mcs(G, K)
    n = Graphs.nv(G)
    copy_K = copy(K)
    
    # data structures for MCS
    sets = [LinkedLists.LinkedList{Int}() for i = 1:n+1]
    pointers = Vector(undef,n)
    size = Vector{Int}(undef, n)
    visited = falses(n)
    
    # output data structures
    mcsorder = Vector{Int}(undef, n)
    invmcsorder = Vector{Int}(undef, n)
    subgraphs = Array[]

    # init
    visited[collect(copy_K)] .= true
    for v in Graphs.vertices(G)
        size[v] = 1
        vispush!(sets[1], pointers, v, visited[v])
    end
    maxcard = 1

    for i = 1:n
        # first, the vertices in K are chosen
        # they are always in the set of maximum cardinality vertices
        if !isempty(copy_K)
            v = pop!(copy_K)
        # afterwards, the algorithm chooses any vertex from maxcard
        else
            v = first(sets[maxcard])
        end
        # v is the ith vertex in the mcsorder
        mcsorder[i] = v
        invmcsorder[v] = i
        size[v] = -1

        # immediately append possible subproblems to the output
        if !visited[v]
            vertexset = Vector{Int}()
            for x in sets[maxcard]
                visited[x] && break
                visited[x] = true
                push!(vertexset, x)
            end
            sg = Graphs.induced_subgraph(G, vertexset)
            subgraphs = vcat(subgraphs, (map(x -> sg[2][x], Graphs.connected_components(sg[1]))))
        end

        deleteat!(sets[maxcard], pointers[v])

        # update the neighbors
        for w in Graphs.inneighbors(G, v)
            if size[w] >= 1
                deleteat!(sets[size[w]], pointers[w])
                size[w] += 1
                vispush!(sets[size[w]], pointers, w, visited[w])
            end
        end
        maxcard += 1
        while maxcard >= 1 && isempty(sets[maxcard])
            maxcard -= 1
        end
    end

    return mcsorder, invmcsorder, subgraphs
end

@inline function vispush!(l::LinkedLists.LinkedList, pointers, x, vis)
    if vis
        pointers[x] = push!(l,x)
    else
        pointers[x] = pushfirst!(l,x)
    end
end

function ischordal(G)
    mcsorder, invmcsorder, _ = mcs(G, Set())
    
    n = length(mcsorder)
    
    f = zeros(Int, n)
    index = zeros(Int, n)
    for i=n:-1:1
        w = mcsorder[i]
        f[w] = w
        index[w] = i
        for v in Graphs.neighbors(G, w)
            if invmcsorder[v] > i
                index[v] = i
                if f[v] == v
                    f[v] = w
                end
            end
        end
        for v in Graphs.neighbors(G, w)
            if invmcsorder[v] > i
                if index[f[v]] > i
                    return false
                end
            end
        end
    end
    return true
end