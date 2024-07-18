#!/bin/bash

export Matlab=/n/helmod/apps/centos7/Core/matlab/R2021a-fasrc01/bin/matlab        # TODO

current_year=$(date +%Y)
current_month=$(( $(date +%m) - 2 ))
if [ $current_month -lt 1 ]; then
    current_year=$((current_year - 1))  # Decrease year by 1
    current_month=$((current_month + 12))  # Increase month by 12
fi

echo $current_year
echo $current_month

# Set Cluster Config
source ../DCENT_config.sh
export redo=0   # Whether to redo the reprocessing of ICOADS data

# Set directories
export dir_list_file="../dir_list.txt"
export ICOADS_dir=$(grep "ICOADS" "$dir_list_file" | head -n 1)
export ICOADS_raw=${ICOADS_dir}"/ICOADS_01_nc_files/" 
export ICOADS_QCed=${ICOADS_dir}"/ICOADS_QCed/"

export LME_dir=$(grep "GWSST" "$dir_list_file" | head -n 1)
export LME_pairs=${LME_dir}"/Step_02_Screen_Pairs/"

dir_log=$(grep "log" "$dir_list_file" | head -n 1)

export DCENT_dir="$(dirname "$(pwd)")"
export ICOADS_tool=${DCENT_dir}"/ICOADS3_preprocess_NC/"
export LME_tool=${DCENT_dir}"/SST_Intercomparison/"

export yr_st=2023

export do_update=1           # TODO
echo $cluster_bigmem  $LME_mem

# LME analysis ***********************************************************************
if [ ${do_update} = "1" ]; then

    # [4] LME analysis ###########################################################################
    export excld_smll_bns=1    # TODO

fi

    # [5] Correction ###########################################################################
    export N_years=$(expr ${current_year} - 1849)

export JOB_corr_full=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J JOB_corr_full
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH --array=1-${N_years}
#SBATCH -t ${cluster_time}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/GWSST_05_annual_corr_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); P.en = \${SLURM_ARRAY_TASK_ID}; LME_setup_ship_SSTs; P.excld_smll_bns = ${excld_smll_bns}; LME_correct_2022_pattern(P); quit;">>${dir_log}/GWSST_05_annual_corr_log_\${SLURM_ARRAY_TASK_ID}

EOF
)
echo JOB_corr_full  ID $JOB_corr_full

# Reassemble individual years into files containting all years ..........................................
export JOB_corr_assemble=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J JOB_corr_rnd
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH --array=1-11
#SBATCH --dependency=afterok:${JOB_corr_full}
#SBATCH -t ${cluster_time}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/GWSST_06_assemble_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); num = \${SLURM_ARRAY_TASK_ID};  en_list = [1:20]+(num-1)*20 -2;  en_list(en_list>200) = [];  for ct_en = en_list, P = []; P.en = ct_en; LME_setup_ship_SSTs; P.excld_smll_bns = ${excld_smll_bns}; LME_correct_2022_pattern_sum(P); end; quit;">>${dir_log}/GWSST_06_assemble_log_\${SLURM_ARRAY_TASK_ID}

EOF
)
echo JOB_corr_assemble  ID $JOB_corr_assemble

