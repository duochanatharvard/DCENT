
for ct = 1:100
    disp(num2str(ct))
    if ct <= 50
        PHA_version = 'auto'; 
         mem_id     = ct;
    else
        PHA_version = 'GAPL';
         mem_id     = ct - 50;
    end
    disp(num2str(mem_id))
    N(ct)           = N_sparse_stations(PHA_version,mem_id);
end

function N = N_sparse_stations(PHA_version,mem_id)

case_name = 'GHCN';

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

N = nnz(l_sparse)

end
