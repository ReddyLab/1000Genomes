#!/bin/bash
#
#SBATCH -J map
#SBATCH -o map.output
#SBATCH -e map.output
#SBATCH -A map
#
cd /data/reddylab/Reference_Data/1000Genomes/analysis/assembly
src/map-anno-to-haplotypes-all.pl

