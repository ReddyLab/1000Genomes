#!/bin/bash
#
#SBATCH -J combine
#SBATCH -o combine.output
#SBATCH -e combine.output
#SBATCH -A combine
#
cd /data/reddylab/Reference_Data/1000Genomes/analysis/assembly
src/combine-assembled-genomes.pl

