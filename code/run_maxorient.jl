using BenchmarkTools, Statistics

@isdefined(Graph)         || include("graph.jl")
@isdefined(HGraph)        || include("graph_h.jl")
@isdefined(EhGraph)       || include("graph_eh.jl")
@isdefined(WblGraph)      || include("graph_wbl.jl")
@isdefined(pdag2dag_dt)   || include("pdag2dag_dt.jl")
@isdefined(pdag2dag_dtch) || include("pdag2dag_dtch.jl")
@isdefined(pdag2dag_dth)  || include("pdag2dag_dth.jl")
@isdefined(pdag2dag_wbl)  || include("pdag2dag_wbl.jl")
@isdefined(meek)          || include("pdag2mpdag_meek.jl")
@isdefined(fastmeek)      || include("pdag2mpdag_wbl.jl")
@isdefined(readgraph)     || include("utils.jl")

"""
    run_eval(dir="instances/maxorient/", outf="out-mo.csv", samples=5)

Run the experiments for maximum orientation. Parameters:
- `dir`: The directory containing the instances
- `outf`: The file to write the results to
- `samples`: The number of samples to take
"""
function run_eval(dir="instances/maxorient/", outf="out-mo.csv", samples=5)
    algorithms = [meek, fastmeek]
    outfile = string(@__DIR__, "/results/", outf)
    fexists = isfile(outfile)

    open(outfile, "a") do io
        !fexists && write(io, "file,n,m,dir,undir,algo,type,min,max,median,mean,std\n")
        for (root, dirs, files) in walkdir(string(@__DIR__, "/$dir"))
            for f in files
                (!occursin(".DS_Store", f) && !occursin("README", f) && !occursin(".gitkeep", f)) || continue
                fpath = string(root, endswith(root, "/") ? "" : "/", f)
                pdag = readgraph(fpath, false)
                n = nv(pdag)
                mdir, mundir = ndiredges(pdag), nundiredges(pdag)
                m = mdir + mundir

                @info "$f (n=$n, m=$m, mdir=$mdir, mundir=$mundir)"

                results = []
                for algo in algorithms
                    @info "Running algorithm '$algo'..."

                    is_res_saved = false
                    for i in 1:2 # Do a first run and take result from second run
                        i == 2 && (for _ in 1:5 GC.gc() end) # Call GC five times
                        ms = Measurement(0, 0, algo == meek ? [[]] : [[], [], []])
                        for _ in 1:samples
                            ts = time_ns()
                            ms.start = ts
                            ms.last = ts
                            result = algo(pdag, ms)
                            if !is_res_saved
                                push!(results, result)
                                is_res_saved = true
                            end
                        end

                        i == 1 && continue

                        for (i, ts) in enumerate(ms.times)
                            t = (
                                string(round(nanosec2millisec(minimum(ts)), digits=3)),
                                string(round(nanosec2millisec(maximum(ts)), digits=3)),
                                string(round(nanosec2millisec(median(ts)), digits=3)),
                                string(round(nanosec2millisec(mean(ts)), digits=3)),
                                string(round(nanosec2millisec(std(ts)), digits=3)),
                            )
                            write(io, join([f, n, m, mdir, mundir, algo, i, t...], ","), "\n")
                            flush(io)
                        end

                        algo == meek && continue

                        ts = reduce(+, ms.times)
                        t = (
                            string(round(nanosec2millisec(minimum(ts)), digits=3)),
                            string(round(nanosec2millisec(maximum(ts)), digits=3)),
                            string(round(nanosec2millisec(median(ts)), digits=3)),
                            string(round(nanosec2millisec(mean(ts)), digits=3)),
                            string(round(nanosec2millisec(std(ts)), digits=3)),
                        )
                        write(io, join([f, n, m, mdir, mundir, algo, "total", t...], ","), "\n")
                        flush(io)
                    end
                end
                if !all(r -> r == first(results), results)
                    @error "Algorithms found different maximum orientations for file '$f'!"
                    exit()
                end
            end
        end
    end
end

l = length(ARGS)
allowed = ["all", "cpdag", "pdag"]
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
    if t == "cpdag"
        run_eval("instances/maxorient/cpdag/", "results-maxorient-cpdag.csv", 10)
    elseif t == "pdag"
        run_eval("instances/maxorient/pdag/",  "results-maxorient-pdag.csv",  10)
    else
        @error "Unsupported input type: $t"
    end
end
