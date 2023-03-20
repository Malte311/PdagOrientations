function dfs(G, u, vis, ts)
    vis[u] = true
    for v in G.out[u]
        !vis[v] && dfs(G, v, vis, ts)
    end
    push!(ts, u)
end

function top_sort(G)
    n = nv(G)
    ts = Vector{Int}()
    vis = falses(n)
    for u in G.vertices
        !vis[u] && dfs(G, u, vis, ts)
    end
    return reverse(ts)
end


function order_parents(G)
    n = nv(G)
    ts = top_sort(G)
    inc = [Vector{Int}() for i = 1:n]
    for v in ts
        for x in outneighbors(G, v)
            push!(inc[x], v)
        end
    end
    for v in G.vertices
        reverse!(inc[v])
    end
    return ts, inc
end

function dag2cpdag(G)
    ts, ordered_parents = order_parents(G)
    n = nv(G)
    labelled = Set{Edge}()
    compelled = [Vector{Int}() for i = 1:n]
    reversible = [Vector{Int}() for i = 1:n]
    for y in ts
        allcompelled = false
        allreversible = false
        for x in ordered_parents[y]
            if Edge(x,y) in labelled
                continue
            end
            if allcompelled
                push!(compelled[y], x)
                continue
            end
            if allreversible
                push!(reversible[y], x)
                continue
            end
            for w in compelled[x]
                if !isadjacent(G, w, y)
                    allcompelled = true
                    push!(compelled[y], x)
                else
                    push!(compelled[y], w)
                    push!(labelled, Edge(w,y))
                end
            end
            if allcompelled
                continue
            end
            for z in ordered_parents[y]
                if z != x && !isadjacent(G, z, x)
                    allcompelled = true
                    push!(compelled[y], x)
                end
            end
            if !allcompelled
                push!(reversible[y], x)
                allreversible = true
            end
        end
    end
    # construct graph
    for v in G.vertices
        # make reversible edges undirected
        for u in reversible[v]
            remedge!(G, u, v, true)
            addedge!(G, u, v, false)
        end
    end
    return G, ts
end
