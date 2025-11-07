#!/bin/bash
#SBATCH --job-name=gmx_md_production_custom
#SBATCH --output=gmx_md_production_custom.out
#SBATCH --error=gmx_md_production_custom.err
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --array=0-2

source ${GMX_INSTALL}




gmx mdrun -deffnm ${md_file_name}_${SLURM_ARRAY_TASK_ID} -nb gpu -bonded gpu -pme gpu -update gpu -pin on -ntomp ${SLURM_CPUS_PER_TASK}
