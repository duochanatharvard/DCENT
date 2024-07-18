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

# Path to the directory list file
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
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2000-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2001-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2002-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2003-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2004-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2005-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2006-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2007-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2008-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2009-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2010-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2011-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2012-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2013-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.0_2014-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2015-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2016-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2017-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2018-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2019-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2020-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2021-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2022-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-02.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-03.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-04.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-05.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-06.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-07.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-08.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-09.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-10.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-11.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2023-12.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2024-01.nc  \
  https://data.rda.ucar.edu/ds548.0/netcdf_r3.0/ICOADS_R3.0.2_2024-02.nc  \
)
while($#filelist > 0)
  set syscmd = "wget $cert_opt $opts -P $dir_ICOADS $ $filelist[1]"
  echo "$syscmd ..."
  $syscmd
  shift filelist
end
