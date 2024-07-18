How to download data
nohup ./download_ds548.0_1800s.csh  &
nohup ./download_ds548.0_1900s.csh  &
nohup ./download_ds548.0_2000s.csh  &

# ==========================================================

To switch between final and total files, simply copy "ICOADS_NC_function_read_final/total.m" to "ICOADS_NC_function_read.m" 
Also, so not forget to change the data directory in "ICOADS_NC_OI.m"
