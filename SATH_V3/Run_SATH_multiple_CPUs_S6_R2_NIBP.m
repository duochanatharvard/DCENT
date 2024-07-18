SATH_setup;

% #########################################################################
% Load data to be further corrected
% #########################################################################
fsave   = SATH_IO(case_name,'initial_R2',mem_id,PHA_version,sub_id);

if ~isfile(fsave)
    D           = SATH_IO(case_name,'raw_data',mem_id,PHA_version);
    fload       = SATH_IO(case_name,'result',mem_id,PHA_version);
    load(fload,'T_corr_output');
    
    % setup parameters
    Ns          = size(T_corr_output,1);
    Nt          = size(T_corr_output,2);
    Ny          = Nt / 12;
    D.T         = reshape(T_corr_output,Ns,12,Ny);
    
    % find stations in the data sparse period
    a           = D.T(:,:,(1700:1900)-1699);
    l_use       = sum(~isnan(a(:,:)),2) >= 60;
    
    % subset data to run an additional pair-wise comparison
    D           = CDC_subset2(D,l_use,1);
    D.T         = D.T(:,:,(1700:1900)-1699);
    D.UID_round1 = D.UID;
    D.UID       = (1:nnz(l_use))';
    
    % #########################################################################
    % Find the network of comparison
    % #########################################################################
    Para        = PHA_assign_parameters(PHA_version, mem_id, D);
    
    sta_list    = 1:size(D.T,1);
    [NET_pair, NET_att, NET_adj] = PHA_S1_get_neighbors(D, sta_list, Para);
    
    % #########################################################################
    % % Calculate the list of stations to be processed 
    % #########################################################################
    N_pairs         = size(NET_pair,1);
    N_pairs_sub     = ceil(N_pairs/N_sub);
    pair_list       = (1:N_pairs_sub) + (sub_id-1) * N_pairs_sub;
    pair_list(pair_list > N_pairs) = [];
    disp(num2str(pair_list([1 end]),'Pair_list: %8.0f - %8.0f'))
    
    % -------------------------------------------------------------------------
    disp(repmat('#',1,100))
    disp('2. SNHT and test for individual segment point')
    
    if strcmp(PHA_version,'white') || strcmp(PHA_version,'auto')
        BP_pair     = PHA_S2_initial_BP(D, NET_pair, pair_list, Para);
    else
        BP_pair     = PHA_S2_initial_BP_GAPL(D,NET_pair,pair_list,Para); 
    end
    
    % -------------------------------------------------------------------------
    if sub_id == 1
        save(fsave,'BP_pair','NET_pair','NET_att','NET_adj','D','-v7.3');
    else
        save(fsave,'BP_pair','-v7.3');
    end
end

