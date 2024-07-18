#!/usr/bin/env csh
#
# c-shell script to download selected files from rda.ucar.edu using Wget
# NOTE: if you want to run under a different shell, make sure you change
#       the 'set' commands according to your shell's syntax
# after you save the file, don't forget to make it executable
#   i.e. - "chmod 755 <name_of_script>"
#
# Experienced Wget Users: add additional command-line flags to 'opts' here
#   Use the -r (--recursive) option with care
#   Do NOT use the -b (--background) option - simultaneous file downloads
#       can cause your data access to be blocked
set opts = "-N"
#
# Check wget version.  Set the --no-check-certificate option 
# if wget version is 1.10 or higher

Path to the directory list file
set dir_list_file = "../dir_list.txt"

# Use grep to find the line containing "ICOADS", then cut to extract the path
set dir_ICOADS = `grep "ICOADS" $dir_list_file | head -n 1`

# Check if the variable is not empty
if ("$dir_ICOADS" != "") then
    echo "ICOADS directory path is: $dir_ICOADS"
else
    echo "ICOADS directory path was not found."
endif
set dir_ICOADS=$dir_ICOADS"/ICOADS_01_nc_files"
if (! -d "$dir_ICOADS") then
    # The directory does not exist, so create it
    mkdir -p "$dir_ICOADS"
    echo "Created directory: $dir_ICOADS"
else
    # The directory exists
    echo "Directory already exists: $dir_ICOADS"
endif

set v = `wget -V |grep 'GNU Wget ' | cut -d ' ' -f 3`
set a = `echo $v | cut -d '.' -f 1`
set b = `echo $v | cut -d '.' -f 2`
if(100 * $a + $b > 109) then
  set cert_opt = "--no-check-certificate"
else
  set cert_opt = ""
endif

set filelist= ( \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_aaaa-bb.nc  \
)
while($#filelist > 0)
  set syscmd = "wget $cert_opt $opts -P $dir_ICOADS $filelist[1]"
  echo "$syscmd ..."
  $syscmd
  shift filelist
end

