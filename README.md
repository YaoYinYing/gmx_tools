# Gromacs-Bio3d Tools (GMX_TOOLs)

## Description
This repo contains a series of tools for Gromacs-Bio3d related tasks, including:
- **MD setup**: prepare a Gromacs-Bio3d simulation
- **MD simulation**: run Gromacs-Bio3d simulation w/ SLURM
- **MD analysis**: analyze Gromacs-Bio3d simulation

## Prerequisites
- A valid gromacs installation
- A Conda environment for md analysis (`mdtraj`)
- A Conda environment for bio3d (`r-bio3d`)

## Installation
### Gromacs

See the [Gromacs installation guide](https://manual.gromacs.org/current/install-guide/index.html) for the most optimized way to build/install Gromacs.

### Conda env for md analysis
```bash
conda create -n gromacs_copilot python=3.11 -y
conda activate gromacs_copilot
pip install mdtraj
```

### Conda env for bio3d

```bash
conda create -n r-bio3d -c conda-forge r-base r-bio3d r-lattice r-ncdf4 -y
conda activate r-bio3d
```


### This repository
- Clone this repository
- Update the submodules if md setup task is used
- edit the `GMXTOOLRC.sh` file for your environment names and gmx executable (`GMXRC` file path)
- Source the `GMXTOOLRC.sh` file to apply the changes before using any of the scripts



## Usage

### Source the `GMXTOOLRC.sh` file
```bash
source /path/to/GMXTOOLRC.sh
```

### MD setup


### MD simulation run

### MD analysis

#### Trajectory preprocessing

1. Center the trajectory: `stage=traj_center traj_prefix=md_0_100_real bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh`
2. 

#### Gromacs Build-in tools


#### R-Bio3d
1. Gro to pdb: `stage=traj_gro2pdb traj_prefix=md_0_100_real_center pdb_prefix=md_0_100_real bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh`
2. XTC to DCD: `stage=traj_xtc2dcd traj_prefix=md_0_100_real_center pdb_prefix=md_0_100_real  bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh`
3. Run bio3d: `stage=bio3d project_id=fsr variant_id=WT workdir=$PWD pdb_prefix=md_0_100_real dcd_prefix=md_0_100_real_center  bash ${GMX_TOOLS}/analysis/run_gmx_analysis.sh`





