if ~strcmp(computer,'MACI64') || strcmp(computer,'MACI64')
    addpath('./PHA')
end
PHA_setup;
d = datevec(date);
yr_end_GHCN = d(1);
