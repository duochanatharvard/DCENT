export excld_smll_bns=1                       # TODO

source ../DCENT_config.sh
export dir_list_file="../dir_list.txt"
dir_log=$(grep "log" "$dir_list_file" | head -n 1)
echo $dir_log

# Call AOI Main ###########################################################################
export AOI=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J AOI_R1
#SBATCH --nodes=1 
#SBATCH --array=1-100
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_net_mem}
#SBATCH -o ${dir_log}/err_AOI_R1

matlab -nosplash -nodesktop -nodisplay -r "num=\${SLURM_ARRAY_TASK_ID}; addpath(genpath('..'));  Para_AOI = AOI_assign_parameters; Para_AOI.do_round = 1;  Para_AOI.excld_smll_bns = ${excld_smll_bns}; AOI_Step_01_pair_with_HadSST4(num,Para_AOI);  AOI_Step_02_get_scaling(num,Para_AOI);  AOI_Step_03_scale_data(num,Para_AOI); quit;">>${dir_log}/log_AOI_R1_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : AOI : ${AOI} 


# Call AOI Main ###########################################################################
export AOI=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J AOI_R3
#SBATCH --nodes=1 
#SBATCH --array=1-100
#SBATCH -t ${cluster_time}
#SBATCH --mem-per-cpu=${SATH_net_mem}
#SBATCH -o ${dir_log}/err_AOI_R3

matlab -nosplash -nodesktop -nodisplay -r "num=\${SLURM_ARRAY_TASK_ID}; addpath(genpath('..'));  Para_AOI = AOI_assign_parameters; Para_AOI.do_round = 3;  Para_AOI.excld_smll_bns = ${excld_smll_bns}; AOI_Step_01_pair_with_HadSST4(num,Para_AOI);  AOI_Step_02_get_scaling(num,Para_AOI);  AOI_Step_03_scale_data(num,Para_AOI); quit;">>${dir_log}/log_AOI_R3_\${SLURM_ARRAY_TASK_ID}

EOF
)

echo Submitted Job ID : AOI : ${AOI} 
