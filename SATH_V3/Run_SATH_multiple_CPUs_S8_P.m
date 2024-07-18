SATH_setup;

% #########################################################################
% Load data to be further corrected
% #########################################################################
fname           = SATH_IO(case_name,'result',mem_id, PHA_version);
R1              = load(fname,'NET','T_corr_output','UID_output');
clear('fname')

fname           = SATH_IO(case_name,'result_R2',mem_id, PHA_version);
R2              = load(fname,'NET','T_corr_output','UID_output','D');
clear('fname')

% Calculate the number of neighbors as a function of year -----------------
[N_nb1, hist_N_nb_1] = PHA_func_count_neighbor(R1.T_corr_output, R1.NET.adj);
[N_nb2, hist_N_nb_2] = PHA_func_count_neighbor(R2.T_corr_output, R2.NET.adj);

% Also, calculate the number of combined data after two iterations --------
N_nb     = N_nb1;
for ct   = 1:size(N_nb2,1)
    temp = N_nb2(ct,:);
    id   = R2.D.UID_round1(ct);
    N_nb(id,1:numel(temp)) = temp;
end
clear('ct','temp','id')

% #########################################################################
% Merge data from the two runs
% #########################################################################
T_comb   = R1.T_corr_output;
for ct   = 1:size(N_nb2,1)
    temp = R2.T_corr_output(ct,:);
    id   = R2.D.UID_round1(ct);
    T_comb(id,1:numel(temp)) = temp;
end
clear('ct','temp','id')

% #########################################################################
% Set parameters
% #########################################################################
Para            = PHA_assign_parameters(PHA_version, mem_id);

N_nb_thsld      = Para.MIN_STNS; % Fewer than X neighbors is considered sparse
N_sparse_seg    = 60;   % At least X month of sparse is worth reevaluation
Ns              = size(T_comb,1);

% #########################################################################
% Calculate segments of data by consecutive missing values
% #########################################################################
SEG         = nan(size(T_comb));
seg_n       = ones(size(T_comb,1),1);
flag        = false(size(T_comb,1),1);
ct_nan      = seg_n;
for i = 2:size(SEG,2)
    l           = isnan(T_comb(:,i));
    ct_nan(l)   = ct_nan(l) + 1;
    l           = ~isnan(T_comb(:,i)) & ct_nan >= 240 & flag == true;
    seg_n(l)    = seg_n(l) + 1;
    l           = ~isnan(T_comb(:,i));
    SEG(l,i)    = seg_n(l);
    ct_nan(l)   = 0;
    flag(l)     = true;
end
clear('ct_nan','seg_n','flag','i','l')

% Combine segments if both are have sufficient neighbors
% which is considered homogeneous after groupwise homogenization ----------
N_seg           = max(SEG,[],2);
for ct_sta      = 1:Ns
    if N_seg(ct_sta) > 1
        for ct_seg = (N_seg(ct_sta)-1):-1:1
            l1  = SEG(ct_sta,:) == ct_seg;
            l2  = SEG(ct_sta,:) == (ct_seg + 1);
            if  nanmean(N_nb(ct_sta,l1)) >= N_nb_thsld && ...
                nanmean(N_nb(ct_sta,l2)) >= N_nb_thsld
                % if both are nb-rich segments combine them
                SEG(ct_sta,l2) = ct_seg;
            end
        end
    end
end
clear('ct_sta','l1','l2')

% Only segments that contain significant amount of sparse time steps are --
% checked.
N_seg    = max(SEG,[],2);
l_sparse = false(Ns,1);
for ct_sta = 1:Ns
    seg = SEG(ct_sta,:);
    nnb = N_nb(ct_sta,:);
    for ct_seg = 1:N_seg(ct_sta)
        l_sparse(ct_sta) = l_sparse(ct_sta) | ...
                    sum(nnb(seg == ct_seg) < N_nb_thsld) >= N_sparse_seg;
    end
end
clear('nnb','ct_sta','seg')

% #########################################################################
% Perform analysis to only stations containing sparse segments
% #########################################################################
n                           = N_nb(l_sparse,:);
seg                         = SEG(l_sparse,:);
uid                         = R1.UID_output(l_sparse);
T_anm                       = CDC_demean(T_comb(l_sparse,:,end),2,12);

% Go through each model and fit the decadal trend + break model -----------
sta_list                    = 1:size(T_anm,1);
tim                         = 1:size(T_anm,2);
BP_info                     = zeros(0,3);
ct_fit                      = 0;
disp(num2str(size(T_anm,1)))
disp(' ---------- ')
for ct_sta = sta_list

    disp(num2str(ct_sta));

    clear('Dif_T','sg')
    Dif_T                       = T_anm(ct_sta,:); 
    sg                          = seg(ct_sta,:);

    for ct_seg = 1:max(sg)

        clear('l_use','corr','dif_use','tim_use','bp_info',...
              'prd_msk','bp_mag','ita_best','mu_hat')
        clear('bp_mag1','bp_mag2','ita_best1','ita_best2',...
            'mu_hat1','mu_hat2','Loss_record1','Loss_record2')

        l_use                   = ~isnan(Dif_T) & sg == ct_seg;
        Dif_use                 = Dif_T(l_use);
        tim_use                 = tim(l_use);
        prd_msk                 = n(ct_sta,l_use) >= N_nb_thsld;

        if nnz(prd_msk == 0) >= 12
    
            % Fit the model while masking periods having sufficient neighbors
            tic;
            [bp_mag1, ita_best1,~, mu_hat1, Loss_record1]      = GA_fit_chan...
                                           (Dif_use,tim_use,'decadal_var',prd_msk);
            
            [bp_mag2, ita_best2,~, mu_hat2, Loss_record2]      = GA_fit_chan...
                                           (Dif_use,tim_use,'no_slope',prd_msk);
            toc;
    
            if Loss_record1(end) < Loss_record2(end)
                bp_mag        = bp_mag1;
                ita_best      = ita_best1;
                mu_hat        = mu_hat1;
            else
                bp_mag        = bp_mag2;
                ita_best      = ita_best2;
                mu_hat        = mu_hat2;
            end
        
            % Get correction when possible
            if nnz(bp_mag(:,1))
                clear('bp_info')
                bp_info(:,2)  = tim_use(bp_mag(:,1)~=0);
                bp_info(:,3)  = bp_mag(bp_mag(:,1)~=0);
                bp_info(:,1)  = uid(ct_sta);
                BP_info       = [BP_info; bp_info];
            end

            ct_fit = ct_fit + 1;
            R3{ct_fit}.data   = Dif_use;
            R3{ct_fit}.time   = tim_use;
            R3{ct_fit}.ita    = ita_best;
            R3{ct_fit}.mu     = mu_hat;
            R3{ct_fit}.ct_sta = ct_sta;
        end

        clear('l_use','corr','dif_use','tim_use','bp_info',...
              'prd_msk','bp_mag','ita_best','mu_hat')
        clear('bp_mag1','bp_mag2','ita_best1','ita_best2',...
            'mu_hat1','mu_hat2','Loss_record1','Loss_record2')
    end
    
    disp(num2str(size(BP_info)))
    clear('Dif_T','sg')
end

clear('T_anm','seg','n','sta_list','tim','uid')
clear('ct_fit','ct_seg','ct_sta')
clear('N_nb_thsld','N_sparse_seg')

% #########################################################################
% Apply correction from single station adjustments
% #########################################################################
Nt          = size(T_comb,2);
BP          = nan(Ns,Nt);
ind         = sub2ind([Ns,Nt],BP_info(:,1), BP_info(:,2)); 
BP(ind)     = BP_info(:,3);
corr        = PHA_func_jump2adj(BP, 'backward');
T_final     = T_comb + corr;
clear('corr','BP','Nt','Ns','ind')

% Output to mat files -----------------------------------------------------
D           = SATH_IO(case_name,'raw_data',0,PHA_version);
T           = R1.T_corr_output;
lon         = D.Lon;
lat         = D.Lat;
fsave       = SATH_IO(case_name,'result_R3',mem_id, PHA_version);
save(fsave,'T','T_comb','T_final','BP_info','lon','lat','R3',...
           'l_sparse','N_nb1','N_nb2','hist_N_nb_1','hist_N_nb_2','N_nb',...
           'SEG','Para','-v7.3');