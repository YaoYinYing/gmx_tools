
# Yinying notes here that this script is designed for md tutorial use cases, including 
# setups, runs , analyses of molecular dynamics simulations using GROMACS and Bio3D.
# This means user must need to know how and what to do and why they are doing so.
# This is not a fully automated pipeline, but a collection of useful scripts for
# common tasks in MD simulations. It assumes user has basic knowledge of MD simulations
# and GROMACS/Bio3D usage, as lo.

# This script performs various GROMACS analysis tasks based on the specified stage.
# It requires certain environment variables to be set depending on the analysis stage.
# Make sure to set the following environment variables as needed:
# stage: The analysis stage to perform (e.g., em, nvt, npt, traj_center, gyrate, dssp, hbond_bb, hbond_sc, hbond_psol, rms, rmsf, sasa, traj_xtc2dcd, traj_gro2pdb, bio3d)

# pdb_prefix: The prefix for the PDB/GRO files (required for some stages)
# traj_prefix: The prefix for the trajectory files (required for some stages)
# project_id: The project identifier (required for bio3d stage)
# variant_id: The variant identifier (required for bio3d stage)
# workdir: The working directory (required for bio3d stage)
# dcd_prefix: The prefix for the DCD files (required for bio3d stage)   

# example usages

# run trajectory centering:
# for i in 0 1 2;do 
#     stage=traj_center  traj_prefix=md_0_100_${i} \n 
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh;
# done

# run gro2pdb:
# for i in 0 1 2;do 
#     stage=traj_gro2pdb pdb_prefix=md_0_100_${i}  traj_prefix=md_0_100_${i}_center \n 
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh;
# done

# run xtc2dcd:
# for i in 0 1 2;do 
#     stage=traj_xtc2dcd  traj_prefix=md_0_100_${i}_center \n 
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh;
# done    


# run bio3d:
# for i in 0 1 2;do 
#     stage=bio3d project_id=t5ah2 variant_id=wt workdir=$PWD pdb_prefix=md_0_100_${i} dcd_prefix=md_0_100_${i}_center \n 
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh;
# done

# run gyrate:
# for i in 50 70 100;do 
#     stage=gyrate pdb_prefix=md_0_200 traj_prefix=md_0_${i}_center \n 
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh;
# done  

# run sasa:
# for i in 50 70 100;do 
#     stage=sasa  pdb_prefix=md_0_200 traj_prefix=md_0_${i}_center \n 
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh ;
# done 

# run dssp:
# for i in 50 70 100;do 
#     stage=dssp pdb_prefix=md_0_200 traj_prefix=md_0_${i}_center \n 
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh;
# done 

# run rmsf:
# for i in 50 70 100;do 
#     stage=rmsf pdb_prefix=md_0_200 traj_prefix=md_0_${i}_center \n
#     bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh ;
# done 

source activate ${GMX_CONDA_PREFIX}
source ${GMX_INSTALL}
source ${GMX_TOOLS}/util.sh


CheckStageName() {
    if [[ -z "${stage}" ]];then
        echo "Not stage specified. Exiting .."
        exit 1
    fi
}


echo "Processing stage: ${stage} ..."

res_dir=analysis
mkdir ${res_dir}

case ${stage} in
    "em" )
        CheckFile "em.edr"
        echo Visualizing Energy Minimization results
        echo 'Potential' '' | gmx energy -f em.edr -o ${res_dir}/em_potential.xvg
    ;;
    "nvt" )
        CheckFile "nvt.edr"
        echo Visualizing NVT results
        echo 'Temperature' '' | gmx energy -f nvt.edr -o ${res_dir}/nvt_temperature.xvg
    ;;
    "npt" ) 
        CheckFile "npt.edr"
        echo Visualizing NPT results
        echo 'Pressure' '' | gmx energy -f npt.edr -o ${res_dir}/npt_pressure.xvg
        echo 'Density' '' | gmx energy -f npt.edr -o ${res_dir}/npt_density.xvg
    ;;
    "traj_center" )
        RequireVar traj_prefix
        CheckFile "${traj_prefix}.xtc"
        echo "Center System to Protein"
        echo "Protein" "System" | gmx trjconv -s ${traj_prefix}.tpr -f ${traj_prefix}.xtc -o ${traj_prefix}_center.xtc -center -pbc mol 
    ;;
    "traj_fit" )
        RequireVar traj_prefix
        CheckFile "${traj_prefix}.xtc"
        echo Fitting System to Backbone
        echo "[Warning]: Fitting should only be used for visualization purpose, not for analysis!"
        echo "Backbone" "System" | gmx trjconv -s ${traj_prefix}.tpr -f ${traj_prefix}_center.xtc -o ${traj_prefix}_fit.xtc -fit rot+trans
    ;;
    "gyrate" )
        RequireVar traj_prefix
        CheckFile "${traj_prefix}.xtc"

        echo Calculate Radius of Gyration
        echo 'Protein' | gmx gyrate -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -o ${res_dir}/${pdb_prefix}_${traj_prefix}_gyrate.xvg -tu ns
    ;;
    "dssp" )
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.tpr"
        CheckFile "${traj_prefix}.xtc"

        echo Calculate DSSP
        gmx dssp -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -tu ns -o ${res_dir}/${pdb_prefix}_${traj_prefix}_dssp.dat -num ${res_dir}/${pdb_prefix}_${traj_prefix}_dssp_num.xvg
    ;;
    "hbond_bb" ) 
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.tpr"
        CheckFile "${traj_prefix}.xtc"
        echo Calculate Backbone Hydrogen Bonds
        echo -e '"MainChain+H"\n' '"MainChain+H"\n' | gmx hbond -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -tu ns -num ${res_dir}/${pdb_prefix}_${traj_prefix}_hbnum_bb.xvg
    ;;
    "hbond_sc" ) 
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.tpr"
        CheckFile "${traj_prefix}.xtc"
        echo Calculate Sidechain Hydrogen Bonds
        echo -e '"SideChain"\n' '"SideChain"\n' | gmx hbond -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -tu ns -num ${res_dir}/${pdb_prefix}_${traj_prefix}_hbnum_sc.xvg
    ;;
    "hbond_psol" ) 
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.tpr"
        CheckFile "${traj_prefix}.xtc"
        
        echo Calculate Protein-Solvent Hydrogen Bonds
        echo -e '"Protein"\n' '"Water"\n' | gmx hbond -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -tu ns -num ${res_dir}/${pdb_prefix}_${traj_prefix}_hbnum_psol.xvg
    ;;
    "rms" | "rmsd" )
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.tpr"
        CheckFile "${traj_prefix}.xtc"
        
        echo Calculate RMSD
        echo "Backbone" 'Protein' | gmx rms -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -o ${res_dir}/${pdb_prefix}_${traj_prefix}_rmsd.xvg -tu ns
    ;;
    "rmsf" ) 
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.tpr"
        CheckFile "${traj_prefix}.xtc"
        

        echo Calculate RMSF
        echo "Backbone" | gmx rmsf -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -o ${res_dir}/${pdb_prefix}_${traj_prefix}_rmsf.xvg
    ;;
    "sasa" )
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.tpr"
        CheckFile "${traj_prefix}.xtc"

        echo Calculate SASA
        # gmx sasa -f hot_sample.trr -s cubic_em_hot_sample.tpr -o area.xvg
        echo "Protein" | gmx sasa -s ${pdb_prefix}.tpr -f ${traj_prefix}.xtc -o ${res_dir}/${pdb_prefix}_${traj_prefix}_sasa.xvg -tu ns
    ;;
    "traj_xtc2dcd" )
        RequireVar pdb_prefix
        RequireVar traj_prefix
        CheckFile "${pdb_prefix}.gro"
        CheckFile "${traj_prefix}.xtc"

        echo Convert XTC to DCD
        mdconvert ${traj_prefix}.xtc -t ${pdb_prefix}.gro -o ${traj_prefix}.dcd
    ;;
    "traj_gro2pdb" )
        echo Convert GRO to PDB
        RequireVar pdb_prefix
        CheckFile "${pdb_prefix}.gro"
        gmx editconf -f ${pdb_prefix}.gro  -o ${pdb_prefix}.pdb
    ;;
    "bio3d" )
        RequireVar project_id
        RequireVar variant_id
        RequireVar workdir
        RequireVar pdb_prefix
        RequireVar dcd_prefix
        echo "Processing Bio3D analysis ..."


        bash ${GMX_TOOLS}/analysis/run_bio3d.sh
    ;;

    * )
        echo "Unknown stage name: ${stage}. Exiting ..."
        exit 1
esac
