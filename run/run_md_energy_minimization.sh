#!/bin/bash
#SBATCH --job-name=energy_minimization
#SBATCH --output=gmx_energy_minimization.out
#SBATCH --error=gmx_energy_minimization.err
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1

source ${GMX_INSTALL}

gmx mdrun -v -deffnm em
