#!/bin/bash
#SBATCH --job-name=md_production_long
#SBATCH --output=gmx_md_production_long.out
#SBATCH --error=gmx_md_production_long.err
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1

source ${GMX_INSTALL}

gmx mdrun -deffnm md_0_200 -nb gpu -bonded gpu -pme gpu -update gpu -pin on -ntomp ${SLURM_CPUS_PER_TASK}
