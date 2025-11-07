#!/bin/bash
#SBATCH --job-name=npt_equilibration
#SBATCH --output=gmx_npt_equilibration.out
#SBATCH --error=gmx_npt_equilibration.err
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1

source ${GMX_INSTALL}

gmx mdrun -deffnm npt
