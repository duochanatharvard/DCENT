SATH_setup;

% *************************************************************************
% Load initial BPs from individual subsets
% *************************************************************************
BP_pair     = zeros(0,11);
if strcmp(PHA_version(1:4),'GAPL')
    N_sub = 15;
else
    N_sub = 1;
end
for sub_id  = 1:N_sub
    fname   = SATH_IO(case_name,'initial_R2',mem_id, PHA_version,sub_id);
    if sub_id == 1
        load(fname);
    else
        temp    = load(fname);
        BP_pair = [BP_pair; temp.BP_pair];
    end
end

% *************************************************************************
% Do later steps
% *************************************************************************
Para        = PHA_assign_parameters(PHA_version, mem_id, D);

tic;
disp(repmat('#',1,100))
disp('3. Attribute breakpoints')
BP_att  = PHA_S3_attribution_all_fast(BP_pair, Para);
toc;

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
tic;
sta_list    = 1:size(D.T,1);  
disp(repmat('#',1,100))
disp('4. Combine nearby breakpoints')
BP_comb = PHA_S4_combine_bps_NOAA(BP_att, D, sta_list, Para);
toc;

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
BP.comb         = BP_comb;
BP.pair         = BP_pair;
BP.att          = BP_att;
NET.pair        = NET_pair;
NET.att         = NET_att;
NET.adj         = NET_adj;

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
disp(repmat('#',1,100))
BP_rmn{1}       = BP_comb;
DD{1}           = D;
ct              = 0;
do_continue     = 1;

tic;

while do_continue
    ct = ct + 1;
    disp(['5-',num2str(ct),'. Estimate adjustments'])

    [ADJ{ct+1}, DD{ct+1}, BP_rmn{ct+1}] = ...
        PHA_S5_est_adj(BP_rmn{ct}, BP.pair, DD{ct}, NET.adj, Para);
    D.T_corr(:,:,ct)    = DD{ct+1}.T_corr(:,:);
    D.CORR(:,:,ct)      = DD{ct+1}.CORR(:,:);
    BP.ADJ_rmn{ct}      = BP_rmn{ct+1};
    BP.ADJ_out{ct}      = ADJ{ct+1};
    toc;
    disp(repmat('-',1,100));

    disp('save data...')
    fsave         = SATH_IO(case_name,'result_R2',mem_id, PHA_version);
    T_corr_output = D.T_corr(:,:,end);
    UID_output    = D.UID;
    disp(fsave)
    save(fsave,'D','BP','NET','T_corr_output','UID_output','-v7.3');

    do_continue         = size(BP.ADJ_out{ct},1) > 100;
end