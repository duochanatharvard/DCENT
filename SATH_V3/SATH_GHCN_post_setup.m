PHA_setup;
d = datevec(date);
yr_end_GHCN = d(1);

case_name = 'GHCN';
if num <= 50
    mem_id = num - 1;
    PHA_version = 'auto';
else
    mem_id = num - 51;
    PHA_version = 'GAPL';
end
P             = PHA_assign_parameters(PHA_version,mem_id);
P.mem_id      = mem_id;
P.PHA_version = PHA_version;
