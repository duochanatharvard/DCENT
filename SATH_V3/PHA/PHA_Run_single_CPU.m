% =========================================================================
% [D, NET, BP] = PHA_Run_single_CPU(D,Para,PHA_version)
% 
% A wrapped up script for running PHA on a single CPU.  Best use for small
% or middle sized network (< 4000 stations).  For a network of about 4000
% stations, it generally takes about 3 hours to run the entire analysis
% using SNHT, when using penalized likelihood (PL; do_SNHT == 0), it takes
% significantly much longer time for the analysis to complete.
%
% -------------------------------------------------------------------------
% [Input]
% D           :: data structure
% Para        :: Parameter structure
% 
% -------------------------------------------------------------------------
% [Output]
% D           :: Output data
%   |_T_corr(:,:,1:x) ::   Corrected temperatures in iteration x
%   |_CORR(:,:,1:x)   ::   Corrections / adjustments in iteration x
% NET         :: Network of stations
%   |_pair    ::   pairwise
%   |_att     ::   attribution
%   |_adj     ::   adjustment
% BP          :: Breakpoints
%   |_pair    ::   initial breakpoints after using SNHT or PL
%   |_att     ::   attreibuted breakpoints
%   |_comb    ::   combined breakpoints
%   |_adj     ::   sent to adjustment estimation
%   |_ADJ     ::   adjusted
% 
% -------------------------------------------------------------------------
% [Format of D]
% T           :: temperature to be homogenized [Ns x Nt] / [Ns x 12 x Nyr]
% Lon         :: Longitude    [Ns x 1]
% Lat         :: Latitude     [Ns x 1]
% Sta         :: Station list [Ns x 11]
% UID         :: Station universal ID [Ns x 1]
% T_true      :: True temperature (optional)
% T_corr      :: Corrected/adjusted temperatures (optional)
% 
% ......................................................................... 
% [Format of NET]
% 1.UID1   2.UID2
%
% ......................................................................... 
% [Format of BP.pair]
% 1. UID1   2. UID2   3.TID   4.TYPE   5.BP_MAG  6.Z-score
% 7-8.RMV Data  9. Assigned BP?  10. IBP UID  11.auto-correlation
%
% ......................................................................... 
% [Format of BP.att / BP.comb / BP.adj]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
%
% .........................................................................
% [Format of BP.ADJ]
% 1.UID  2.TID  3.YR  4.MO  5. TYPE  6.MADJ  7.Z-score  8. auto  9.#NB
% 10. Central estimate of adjustment   
% 11-X. randomized estimate of adjustments
% =========================================================================

function [D, NET, BP] = PHA_Run_single_CPU(D,Para,PHA_version)
    
    sta_list  = 1:size(D.T,1);
    
    PHA_func_debug_flag;
    
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    tic;
    disp(repmat('#',1,100))
    disp('1. Identify neighbors')
    [NET_pair, NET_att, NET_adj] = PHA_S1_get_neighbors(D, sta_list, Para);
    disp(repmat('=',1,100))
    toc;
    
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    disp(repmat('#',1,100))
    disp('2. SNHT and test for individual segment point')
    pair_list   = 1:size(NET_pair,1);
    if strcmp(PHA_version,'white') || strcmp(PHA_version,'auto')
        BP_pair = PHA_S2_initial_BP(D, NET_pair, pair_list, Para);
    else
        BP_pair = PHA_S2_initial_BP_GAPL(D,NET_pair,pair_list,Para);
    end
    if any(ismember([0 9], do_debug))
        PHA_print_output(BP_pair, 'pair', 'Initial BP', Para);
    end
    toc;
    
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    disp(repmat('#',1,100))
    disp('3. Attribute breakpoints')
    BP_att  = PHA_S3_attribution_all(BP_pair, Para, NET_att);
    if any(ismember([0 9], do_debug))
        PHA_print_output(BP_att, 'attribute', 'Attibuted BP', Para);
    end
    toc;
    
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    disp(repmat('#',1,100))
    disp('4. Combine nearby breakpoints')
    BP_comb = PHA_S4_combine_bps_NOAA(BP_att, D, sta_list, Para);
    if any(ismember([0 9], do_debug))
        PHA_print_output(BP_adj, 'combine', 'Combined BP', Para);
    end
    toc;
    
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % Do the first round --------------------------------------------------
    disp(repmat('#',1,100))
    BP_rmn{1}   = BP_comb;
    DD{1}       = D;
    for ct = 1:Para.N_itr
        disp(['5-',num2str(ct),'. Estimate adjustments'])
        [ADJ{ct+1}, DD{ct+1}, BP_rmn{ct+1}] = ...
            PHA_S5_est_adj(BP_rmn{ct}, BP_pair, DD{ct}, NET_adj, Para);
        D.T_corr(:,:,ct)    = DD{ct+1}.T_corr(:,:);
        D.CORR(:,:,ct)      = DD{ct+1}.CORR(:,:);
        BP.ADJ_rmn{ct}      = BP_rmn{ct+1};
        BP.ADJ_out{ct}      = ADJ{ct+1};
        toc;
        if ct == Para.N_itr, disp(repmat('#',1,100)); else, disp(repmat('-',1,100)); end
    end

    if any(ismember([0 9], do_debug))
        PHA_print_output(ADJ1, 'combine', 'Adjusted BP', Para);
        PHA_print_output(ADJ1, 'adjust', [], Para, DD);
    end
    toc;
    
    % >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    BP.comb         = BP_comb;
    BP.pair         = BP_pair;
    BP.att          = BP_att;
    NET.pair        = NET_pair;
    NET.att         = NET_att;
    NET.adj         = NET_adj;
end