#!/bin/bash
#SBATCH --job-name=nvt_equilibration
#SBATCH --output=gmx_nvt_equilibration.out
#SBATCH --error=gmx_nvt_equilibration.err
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1

source ${GMX_INSTALL}

gmx mdrun -deffnm nvt
