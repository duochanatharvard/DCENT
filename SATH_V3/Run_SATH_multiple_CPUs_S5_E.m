SATH_setup;

% *************************************************************************
% Load data 
% *************************************************************************
try
    f_load      = SATH_IO(case_name,'result',mem_id, PHA_version);
    load(f_load,'D','BP','NET')

    fload       = SATH_IO(case_name,'attribute',mem_id, PHA_version);
    load(fload,'Para');

    disp('restart from existing files')
    do_restart  = 1;

catch

    fload       = SATH_IO(case_name,'attribute',mem_id, PHA_version);
    load(fload,'Para','BP_pair','BP_att');
    
    fload       = SATH_IO(case_name,'combined',mem_id, PHA_version);
    load(fload,'BP_comb');
    
    fname       = SATH_IO(case_name,'net',mem_id,PHA_version);
    load(fname,'NET_adj','NET_att','NET_pair');
    
    D           = SATH_IO(case_name,'raw_data',mem_id,PHA_version);
    
    disp('start from new files')
    do_restart  = 0;

    BP.comb         = BP_comb;
    BP.pair         = BP_pair;
    BP.att          = BP_att;
    NET.pair        = NET_pair;
    NET.att         = NET_att;
    NET.adj         = NET_adj;
end

% >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
disp(repmat('#',1,100))
if do_restart == 0
    BP_rmn{1}       = BP_comb;
    DD{1}           = D;
    ct              = 0;
    do_continue     = 1;
else
    ct              = numel(BP.ADJ_out);              % Round already run
    BP_rmn{ct+1}    = BP.ADJ_rmn{ct};
    DD{ct+1}        = D;
    DD{ct+1}.CORR   = DD{ct+1}.CORR(:,:,end);
    DD{ct+1}.T_corr = DD{ct+1}.T_corr(:,:,end);
    do_continue     = size(BP.ADJ_out{ct},1) > 100;
end

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
    fsave         = SATH_IO(case_name,'result',mem_id, PHA_version);
    T_corr_output = D.T_corr(:,:,end);
    UID_output    = D.UID;
    disp(fsave)
    save(fsave,'D','BP','NET','T_corr_output','UID_output','-v7.3');

    do_continue         = size(BP.ADJ_out{ct},1) > 100;
end