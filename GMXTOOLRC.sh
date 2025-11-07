

# Selfcheck for the installation dir
# See: https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script
fetchRepoDir() {
  SHELL_TYPE=$(basename  $SHELL)
  if [[ "$SHELL_TYPE" == "bash" ]]; then
    core_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
  elif [[ "$SHELL_TYPE" == "zsh" ]]; then
    core_script_dir=${0:A:h}
  fi
  echo $core_script_dir
}

# auto fetch the repo dir
export GMX_TOOLS=$(fetchRepoDir)

# configure conda envs and gromacs installation
export GMX_CONDA_PREFIX='gromacs_copilot'
export BIO3D_CONDA_PREFIX='r-bio3d'
export GMX_INSTALL='/mnt/data/software/gromacs/2025.3-cuda-nompi-avx2_256/bin/GMXRC'

