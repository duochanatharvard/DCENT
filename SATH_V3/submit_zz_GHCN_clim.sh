export case_name=$1
export PHA_version=$2
export N_rnd=$3         # How many members to run : 0 ~ N_rnd-1
export do_round=$4

export my_lab="huybers_lab"
export partition="huce_ice"

export dir_log="/n/holyscratch01/huybers_lab/dchan/SATH_V3/PHA_output/"${case_name}"/logs/"  # TODO
mkdir -p ${dir_log}

###########################################################################
# Part 1 :: Calculate Climatology at 5x5 resolution
###########################################################################
export job_P6=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${my_lab}
#SBATCH -p ${partition}
#SBATCH -J P6_${case_name}_${PHA_version}_${do_round}
#SBATCH -n 1
#SBATCH --array=1-${N_rnd}
#SBATCH -t 10080
#SBATCH --mem-per-cpu=50000
#SBATCH -o logs/${case_name}_err_P6_${PHA_version}_${do_round} 

matlab -nosplash -nodesktop -nodisplay -r "case_name = '${case_name}'; PHA_version = '${PHA_version}'; mem_id = \${SLURM_ARRAY_TASK_ID}-1; do_round = ${do_round};  SATH_GHCN_post_06_clim; quit;">>${dir_log}/${case_name}_log_P6_${PHA_version}_${do_round}_\${SLURM_ARRAY_TASK_ID}
EOF
)
echo Submitted Job ID : P6_CLIM : ${job_P6}
