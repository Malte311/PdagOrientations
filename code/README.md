## Running the Experiments

In order to run the experiments, execute the bash script `run_all.sh`. This
script first generates the data (it will populate `instances/maxorient/pdag/`
and so on) and afterwards runs the four algorithms for the extension task and the two
algorithms for the maximal orientation task on these instances. The measured times are stored in
`.csv` files in the directory `results/`.

## Producing the Plots
The raw data produced by running the experiments contains the measurements for
all ten graph instances per parameter choice. The script `combine_runs.jl`
averages the corresponding runs. Afterward, the plots may be produced with the
R script `plot.r`.
