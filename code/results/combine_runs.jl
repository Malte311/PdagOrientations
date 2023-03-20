@enum ProblemType begin
    Extendability
    MaxOrient
end

function combine_runs(file::String, type::ProblemType)
    # Number of columns in the .csv file
    clengths = Dict{ProblemType, Int}(Extendability  => 12, MaxOrient => 12)

    averages = Dict()
    open(file, "r") do io
        readline(io) # Remove header
        for line in readlines(io)
            lsplit = split(line, ",")
            if length(lsplit) != clengths[type]
                @error string(
                    "Expected $(clengths[type]) columns, ",
                    "but found $(length(lsplit)) columns!"
                )
                exit()
            end
            i = replace(first(lsplit), r"-\d{1,2}.gr" => "-avg.gr")
            a = lsplit[type == Extendability ? 7 : 6]
            haskey(averages, i) || (averages[i] = Dict())
            if type == Extendability
                haskey(averages[i], a) || (averages[i][a] = [])
                push!(averages[i][a], lsplit)
            elseif type == MaxOrient
                t = lsplit[7]
                haskey(averages[i], a) || (averages[i][a] = Dict())
                haskey(averages[i][a], t) || (averages[i][a][t] = [])
                push!(averages[i][a][t], lsplit)
            else
                @error "Unknown type: $type"
                exit()
            end
        end
    end
    open(file, "a") do io
        for (i, algos) in averages
            for (a, ts) in algos
                if isa(ts, Dict)
                    for (t, lines) in ts
                        avgs = []
                        for line in lines
                            f, n, m, dir, undir, a, t, min, max, median, mean, std = line
                            push!(avgs, parse.(Float64, [n, m, dir, undir, min, max, median, mean ,std]))
                        end
                        avgs = reduce(+, avgs) / length(avgs)
                        write(io, "$i,$(join(avgs[1:4], ",")),$a,$t,$(join(avgs[5:end], ","))\n")
                    end
                else
                    avgs = []
                    for line in ts
                        f, n, m, dir, undir, isext, a, min, max, median, mean, std = line
                        push!(avgs, parse.(Float64, [n, m, dir, undir, min, max, median, mean ,std]))
                    end
                    avgs = reduce(+, avgs) / length(avgs)
                    e = first(ts)[6]
                    write(io, "$i,$(join(avgs[1:4], ",")),$e,$a,$(join(avgs[5:end], ","))\n")
                end
            end
        end
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    files = [
        (string(@__DIR__, "/results-maxorient-cpdag.csv"), MaxOrient),
        (string(@__DIR__, "/results-maxorient-pdag.csv"),  MaxOrient),
        (string(@__DIR__, "/results-ext-chordal.csv"),     Extendability),
        (string(@__DIR__, "/results-ext-cpdag.csv"),       Extendability),
        (string(@__DIR__, "/results-ext-pdag.csv"),        Extendability),
        (string(@__DIR__, "/results-ext-chordal-ll.csv"),  Extendability),
        (string(@__DIR__, "/results-ext-cpdag-ll.csv"),    Extendability),
        (string(@__DIR__, "/results-ext-pdag-ll.csv"),     Extendability)
    ]
    for (file, type) in files
        isfile(file) && combine_runs(file, type)
    end
end