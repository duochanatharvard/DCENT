# Set up download directories
source ../DCENT_config.sh
export dir_list_file="../dir_list.txt"
dir_download=$(grep "others" "$dir_list_file" | head -n 1)

# Download HadSST4 ---------------------------------------------------------
export dir_remote="https://www.metoffice.gov.uk/hadobs/hadsst4/data/netcdf/"
export dir_local=${dir_download}"/HadSST4/"
echo ${dir_local}
mkdir -p ${dir_local}
fname="HadSST.4.0.1.0_median.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_measurement_and_sampling_uncertainty.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_uncorrelated_measurement_uncertainty.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_sampling_uncertainty.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_correlated_measurement_uncertainty.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_unadjusted.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_actuals_median.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_ensemble.zip"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="HadSST.4.0.1.0_error_covariance.zip"
curl -o "$dir_local$fname" "$dir_remote$fname"

mkdir -p ${dir_local}/HadSST4_ensemble/
mkdir -p ${dir_local}/HadSST4_error_covariance/
rm -rf ${dir_local}/HadSST4_ensemble/*
rm -rf ${dir_local}/HadSST4_error_covariance/*

unzip "${dir_local}HadSST.4.0.1.0_ensemble.zip" -d "${dir_local}HadSST4_ensemble/"
unzip "${dir_local}HadSST.4.0.1.0_error_covariance.zip" -d "${dir_local}HadSST4_error_covariance/"

rm ${dir_local}*.zip
unzip "${dir_local}HadSST4_error_covariance/*.zip" -d "${dir_local}HadSST4_error_covariance/"
rm ${dir_local}HadSST4_error_covariance/*.zip

# Download CRUTEM5 ---------------------------------------------------------
export dir_remote="https://www.metoffice.gov.uk/hadobs/crutem5/data/CRUTEM.5.0.2.0/grids/"
export dir_local=${dir_download}"/CRUTEM5/"
mkdir -p ${dir_local}
fname="CRUTEM.5.0.2.0.anomalies.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="CRUTEM.5.0.2.0.measurement_sampling.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="CRUTEM.5.0.2.0.station_uncertainty.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="CRUTEM.5.0.2.0.lower_bias.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="CRUTEM.5.0.2.0.upper_bias.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"

# Download ERSST5 ---------------------------------------------------------
export dir_remote="https://downloads.psl.noaa.gov//Datasets/noaa.ersst.v5/"
export dir_local=${dir_download}"/ERSST5/"
mkdir -p ${dir_local}
fname="sst.mnmean.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"

# Download COBESST2 -------------------------------------------------------
export dir_remote="https://downloads.psl.noaa.gov/Datasets/COBE2/"
export dir_local=${dir_download}"/CobeSST2/"
mkdir -p ${dir_local}
fname="sst.mon.mean.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"

# Download Berkeley Earth -------------------------------------------------
export dir_remote="https://berkeley-earth-temperature.s3.us-west-1.amazonaws.com/Global/Gridded/"
export dir_local=${dir_download}"/Berkeley_Earth_Land/"
mkdir -p ${dir_local}
fname="Complete_TAVG_LatLong1.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"

export dir_local=${dir_download}"/Berkeley_Earth_Global/"
mkdir -p ${dir_local}
fname="Land_and_Ocean_Alternate_LatLong1.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"

fname="Land_and_Ocean_LatLong1.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"

# Download GISTEMP --------------------------------------------------------
export dir_remote="https://data.giss.nasa.gov/pub/gistemp/"
export dir_local=${dir_download}"/GISTEMP/"
mkdir -p ${dir_local}
fname="gistemp250_GHCNv4.nc.gz"
curl -o "$dir_local$fname" "$dir_remote$fname"
gunzip -c "${dir_local}${fname}" -c > "${dir_local}gistemp250_GHCNv4.nc"
fname="gistemp1200_GHCNv4_ERSSTv5.nc.gz"
curl -o "$dir_local$fname" "$dir_remote$fname"
gunzip -c "${dir_local}${fname}" -c > "${dir_local}gistemp1200_GHCNv4_ERSSTv5.nc"
rm ${dir_local}*.nc.gz

# Download NOAA Global TEMP -----------------------------------------------
export dir_remote="https://downloads.psl.noaa.gov/Datasets/noaaglobaltemp/"
export dir_local=${dir_download}"/NOAAGlobalTemp/"
mkdir -p ${dir_local}
fname="air.mon.anom.v5.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="air.mon.v5.ltm.1981.2010.nc"
curl -o "$dir_local$fname" "$dir_remote$fname"
fname="lsmask.nc"
