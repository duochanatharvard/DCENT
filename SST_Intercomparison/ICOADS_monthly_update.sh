#!/bin/bash

# export Matlab=/n/helmod/apps/centos7/Core/matlab/R2021a-fasrc01/bin/matlab        # TODO

current_year=$(date +%Y)
current_month=$(( $(date +%m) - 1))
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

# Download raw data **************************************************************
for ((year=${yr_st}; year<=current_year; year++)); do
    end_month=12
    if [ $year -eq $current_year ]; then
        end_month=$current_month
    fi
    for ((month=1; month<=end_month; month++)); do
        file_name=${ICOADS_raw}"ICOADS_R3.0.2_${year}-$(printf "%02d" $month).nc"
        if [ -e "$file_name" ]; then
            echo "$file_name exists"
        else
            echo "$file_name does not exist"
            sed "s/netcdf_r3\.0\/ICOADS_R3\.0\.2_aaaa-bb\.nc/netcdf_r3\.0\/ICOADS_R3\.0\.2_${year}-$(printf "%02d" $month)\.nc/" download_ds548.0_monthly_update.csh > download_ds548.0_monthly_run.csh
            ./download_ds548.0_monthly_run.csh
        fi
    done
done

# Process newly downloaded ICOADS ************************************************
job_list=()
for ((year=${yr_st}; year<=current_year; year++)); do
    export yr=${year}
    end_month=12
    if [ $year -eq $current_year ]; then
        end_month=$current_month
    fi
    for ((month=1; month<=end_month; month++)); do
        export mon=${month}
        file_raw=${ICOADS_raw}"ICOADS_R3.0.2_${year}-$(printf "%02d" $month).nc"
        file_name=${ICOADS_QCed}"ICOADS_R3.0.2_${year}-$(printf "%02d" $month)_QCed.nc"
        if [ -e "$file_raw" ]; then
            if [ -e "$file_name" ]; then
                echo "$file_name exists"
            else
                echo "$file_name does not exist"
                cd ${ICOADS_tool}
export job_id=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J ICOADS_preprocess
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH -t ${cluster_time}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/ICOADS_01_preprocess_err

matlab -nosplash -nodesktop -nodisplay -r "ICOADS_NC_Step_01_pre_QC(${yr},${mon},${redo}); ICOADS_NC_Step_02_WM(${yr},${mon},1,${redo});  ICOADS_NC_Step_02_WM(${yr},${mon},2,${redo}); ICOADS_NC_Step_04_Buddy_check(${yr},${mon},${redo}); quit;">>${dir_log}/ICOADS_01_preprocess_log_\$SLURM_ARRAY_TASK_ID

EOF
)
                echo JOB_pre_processing ${year} - ${month}  ID $job_id
                job_list=$(echo $job_list:$job_id)
                cd ${LME_tool}
            fi
        fi
    done
done
Pre_process=${job_list:1}
echo "Preprocess:" ${Pre_process}

# Update the pairing of shipbased SSTs *******************************************
export do_update=1
export yr_st=2023     # TODO
job_list=()
for ((year=${yr_st}; year<=current_year; year++)); do
    export yr=${year}
    end_month=12
    if [ $year -eq $current_year ]; then
        end_month=$current_month
    fi
    for ((month=1; month<=end_month; month++)); do
        export mon=${month}
        file_raw=${ICOADS_raw}"ICOADS_R3.0.2_${year}-$(printf "%02d" $month).nc"
        file_name=${LME_pairs}"IMMA1_R3.0.2_${year}-$(printf "%02d" $month)_Ship_pairs_nation_deck_method.mat"
        file_raw0=${ICOADS_raw}"ICOADS_R3.0.0_${year}-$(printf "%02d" $month).nc"
        file_name0=${LME_pairs}"IMMA1_R3.0.0_${year}-$(printf "%02d" $month)_Ship_pairs_nation_deck_method.mat"
        if [ -e "$file_raw" ] || [ -e "$file_raw0" ]; then
            if [ -e "$file_name" ] || [ -e "$file_name0" ]; then
                echo "$file_name exists"
                # export do_update=0
            else
                echo "$file_name does not exist -> update pairing"

if [ -n "${Pre_process}" ]; then
  DEPENDENCY_OPTION="--dependency=afterok:${Pre_process}"
else
  DEPENDENCY_OPTION=""
fi

export JOB_find_pairs=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J GW_Pair
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH -t ${cluster_time}
#SBATCH ${DEPENDENCY_OPTION}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/GWSST_01_pair_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); P.yr = ${yr}; P.mon = ${mon}; LME_pair_01_Raw_Pairs_ship_SST_nation_deck_method(P); LME_pair_02_Screen_Pairs_ship_SST_nation_deck_method(P); quit">>${dir_log}/GWSST_01_pair_log_${yr}_${mon}

EOF
)
                echo JOB_find_pairs  ${year} - ${month}  ID $JOB_find_pairs
                job_list=$(echo $job_list:$JOB_find_pairs)
                export do_update=1
            fi
        fi
    done
done
Pair_list=${job_list:1}
echo ${Pair_list}

echo do_update LME ${do_update}
# SUM Pair *****************************************************************************
# If anything is updated, then update the sumation of pairs and LME analysis accordingly

if [ -n "${Pair_list}" ]; then
  export do_update_pair_sum=1
else
  export do_update_pair_sum=0
fi

if [ ${do_update_pair_sum} = "1" ]; then

export JOB_sum_SST_pairs=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J GW_SUM_Pair
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH -t ${cluster_time}
#SBATCH --dependency=afterok:${Pair_list}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/GWSST_03_SUM_pair_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); do_update = 1; LME_pair_03_Sum_Pairs_ship_SST_with_SST;  quit">>${dir_log}/GWSST_03_SUM_pair_log

EOF
)
echo JOB_sum_SST_pairs  ID $JOB_sum_SST_pairs
fi

# BIN for LME ****************************************************************************
if [ ${do_update} = "1" ]; then

if [ -n "${JOB_sum_SST_pairs}" ]; then
  DEPENDENCY_OPTION="--dependency=afterok:${JOB_sum_SST_pairs}"
else
  DEPENDENCY_OPTION=""
fi

    # Update pair binning
    export N_bin_sub=25   # TODO
export JOB_BIN=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J GW_bin_pair
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH --array=1-${N_bin_sub}
#SBATCH ${DEPENDENCY_OPTION}
#SBATCH -t ${cluster_time}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/GWSST_03_bin_pair_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); LME_setup_ship_SSTs; P.bin_sub_id = \${SLURM_ARRAY_TASK_ID};  LME_lme_bin_2021_pattern(P);  quit">>${dir_log}/GWSST_03_bin_pair_log_\${SLURM_ARRAY_TASK_ID}

EOF
)
echo JOB_BIN  ID $JOB_BIN

# ....................................................................................

export JOB_bin_sum=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J GW_SUM_bin
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${JOB_BIN}
#SBATCH -t ${cluster_time}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/GWSST_03_SUM_bin_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); LME_setup_ship_SSTs; LME_lme_bin_2021_pattern_sum(P); quit;">>${dir_log}/GWSST_03_SUM_bin_log

EOF
)

echo JOB_bin_sum  ID $JOB_bin_sum

fi

# LME analysis ***********************************************************************
if [ ${do_update} = "1" ]; then

    # [4] LME analysis ###########################################################################
    export excld_smll_bns=1    # TODO

export JOB_LME=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_bigmem}
#SBATCH -J GW_LME
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH --dependency=afterok:${JOB_bin_sum}
#SBATCH -t ${cluster_long_time}
#SBATCH --mem=${LME_mem}
#SBATCH -o ${dir_log}/GWSST_04_LME_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); LME_setup_ship_SSTs; P.excld_smll_bns = ${excld_smll_bns}; LME_lme_fit_2021_pattern(P);  quit">>${dir_log}/GWSST_04_LME_log

EOF
)
fi

if [ ${do_update} = "1" ]; then
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
#SBATCH --dependency=afterok:${JOB_LME}
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

fi
