source ../DCENT_config.sh

# Redo the processing
export redo=0

# Set up the log file for output
dir_list_file="../dir_list.txt"
dir_log=$(grep "log" "$dir_list_file" | head -n 1)

export JOB_process=$(sbatch << EOF | egrep -o -e "\b[0-9]+$"
#!/bin/sh
#SBATCH --account=${cluster_account}
#SBATCH -p ${cluster_use}
#SBATCH -J ICOADS_preprocess
#SBATCH -n 1
#SBATCH --nodes=1 
#SBATCH -t ${cluster_time}
#SBATCH --mem=${ICOADS_preprocess_mem}
#SBATCH -o ${dir_log}/ICOADS_03_Neighbor_std_err

matlab -nosplash -nodesktop -nodisplay -r "addpath(genpath('..')); for id = 1:2, ICOADS_NC_Step_03_Neighbor_std(id,${redo}); end; quit;">>${dir_log}/ICOADS_03_Neighbout_std_log

EOF
)

echo submitted ICOADS Neighbout std job :: $JOB_process
