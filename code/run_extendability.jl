using BenchmarkTools, Statistics

@isdefined(Graph)         || include("graph.jl")
@isdefined(HGraph)        || include("graph_h.jl")
@isdefined(EhGraph)       || include("graph_eh.jl")
@isdefined(WblGraph)      || include("graph_wbl.jl")
@isdefined(pdag2dag_dt)   || include("pdag2dag_dt.jl")
@isdefined(pdag2dag_dtch) || include("pdag2dag_dtch.jl")
@isdefined(pdag2dag_dth)  || include("pdag2dag_dth.jl")
@isdefined(pdag2dag_wbl)  || include("pdag2dag_wbl.jl")
@isdefined(readgraph)     || include("utils.jl")

@enum InputType begin
    UG   # Undirected graph
    PDG  # Partially directed graph
end

"""
    run_eval(dir="instances/extendability/", outf="out-ext.csv", itype=PDG, samples=5, evals=1)

Run the experiments for extendability. Parameters:
- `dir`: The directory containing the instances
- `outf`: The file to write the results to
- `itype`: The input type of the instances, one of `UG`, `PDG`
- `samples`: The number of samples to take
- `evals`: The number of evaluations for each sample
"""
function run_eval(dir="instances/extendability/", outf="out-ext.csv", itype=PDG, samples=5, evals=1)
    algorithms = [pdag2dag_dt, pdag2dag_dtch, pdag2dag_dth, pdag2dag_wbl]
    outfile = string(@__DIR__, "/results/", outf)
    fexists = isfile(outfile)
    isundir = itype == UG

    open(outfile, "a") do io
        !fexists && write(io, "file,n,m,dir,undir,isext,algo,min,max,median,mean,std\n")
        for (root, dirs, files) in walkdir(string(@__DIR__, "/$dir"))
            for f in files
                (!occursin(".DS_Store", f) && !occursin("README", f) && !occursin(".gitkeep", f)) || continue
                fpath = string(root, endswith(root, "/") ? "" : "/", f)
                pdag = readgraph(fpath, isundir)
                n = nv(pdag)
                mdir, mundir = ndiredges(pdag), nundiredges(pdag)
                m = mdir + mundir

                @info "$f (n=$n, m=$m, mdir=$mdir, mundir=$mundir, type=$itype)"

                emptygraphs = falses(length(algorithms))
                for (index, algo) in enumerate(algorithms)
                    @info "Running algorithm '$algo'..."

                    bench = @benchmark $algo($pdag) samples=samples evals=evals seconds=60
                    result = algo(pdag)

                    if result.n == -1
                        emptygraphs[index] = true
                    elseif !isvalidext(result, pdag)
                        @error "Algorithm '$algo' found no consistent extension for file '$f'!"
                        exit()
                    end

                    t = (
                        string(round(nanosec2millisec(minimum(bench.times)), digits=3)),
                        string(round(nanosec2millisec(maximum(bench.times)), digits=3)),
                        string(round(nanosec2millisec(median(bench.times)), digits=3)),
                        string(round(nanosec2millisec(mean(bench.times)), digits=3)),
                        string(round(nanosec2millisec(std(bench.times)), digits=3)),
                    )
                    write(io, join([f, n, m, mdir, mundir, !emptygraphs[index], algo, t...], ","), "\n")
                    flush(io)
                end
                if !all(emptygraphs) && !all(e -> !e, emptygraphs)
                    e = collect(zip(algorithms, emptygraphs))
                    @error "Algorithms found different non-extendable graphs for file '$f': $e"
                    exit()
                end
            end
        end
    end
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
        run_eval("instances/extendability/chordal/", "results-ext-chordal.csv", UG,  10, 1)
    elseif t == "cpdag"
        run_eval("instances/extendability/cpdag/",   "results-ext-cpdag.csv",   PDG, 10, 1)
    elseif t == "pdag"
        run_eval("instances/extendability/pdag/",    "results-ext-pdag.csv",    PDG, 10, 1)
    else
        @error "Unsupported input type: $t"
    end
end