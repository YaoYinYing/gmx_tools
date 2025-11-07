#!/bin/bash
#SBATCH --job-name=run_bio3d
#SBATCH --output=run_bio3d.out
#SBATCH --error=run_bio3d.err
#SBATCH --mem=200G

# example usage:
# 
# for i in 50 70 100;do 
# project_id=t5ah2 variant_id=wt workdir=$PWD pdb_prefix=md_0_200 dcd_prefix=md_0_${i}_center bash ${GMX_TOOLS}/analysis/run_bio3d.sh;
# done



# use r-bio3d
source activate ${BIO3D_CONDA_PREFIX}
source ${GMX_TOOLS}/util.sh

# Check mandatory inputs
RequireVar project_id
RequireVar variant_id
RequireVar workdir
RequireVar pdb_prefix
RequireVar dcd_prefix

res_dir=bio3d_analysis/${variant_id}/${pdb_prefix}_${dcd_prefix}

mkdir -p $res_dir

curdir=$PWD
cd $res_dir
echo Go to working dir: $res_dir

echo "Processing variant: ${project_id}::${variant_id}..."
# run the script
Rscript ${GMX_TOOLS}/analysis/md_plot.R $project_id $variant_id $workdir $pdb_prefix $dcd_prefix


cd $curdir
echo Back to dir: $curdir
echo "Done processing variant: ${project_id}::${variant_id}. Bye."