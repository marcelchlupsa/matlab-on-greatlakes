#!/bin/bash

#SBATCH --account=shahani0

#SBATCH --job-name=ex_nrst_nebrs
#SBATCH --output=res.out
#SBATCH --error=res.err

#SBATCH --mail-user=uniqname@umich.edu
#SBATCH --mail-type=ALL

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4000m
#SBATCH --partition=standard
#SBATCH --time=1:00:00

module purge
module load matlab

srun -c 1 matlab load nrst_nbrs_input.mat
srun -c 1 matlab [NN, time] = nrst_nbrs_timed(numElement, adj, mis_area)

wait
