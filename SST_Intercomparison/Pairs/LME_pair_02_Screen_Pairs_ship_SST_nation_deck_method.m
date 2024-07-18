% sbatch --account=huybers_lab  -J Pair  -t 10080 -p huce_intel -n 1 --array 1-360 --mem=40000 -o err --wrap='matlab -nosplash -nodesktop -nodisplay -r "LME_setup; num=$SLURM_ARRAY_TASK_ID; [yr_num,mon_num] = ind2sub([30,12],num);for yr = (1991+yr_num):-30:1850,for mon = mon_num,try P.yr = yr;P.mon = mon;LME_pair_02_Screen_Pairs_ship_SST_nation_deck_method(P);catch,end;end;end;quit">>logs/log_pair_ship_SSTs'
% 
% *************************************************************************
% This version pairs all measurements within the ship category
% Grouped by nation-deck-method
% We provide options to look at only subsets of pairs:
% 1. Bucket and Bucket
% 2. ERI + Hull and ERI + Hull
% 3. Bucket and ERI + Hull
% 4. All ship based pairs
% This function runs on ICOADS .netcdf files.
% *************************************************************************
%
% Last update: 2021-06-24

function LME_pair_02_Screen_Pairs_ship_SST_nation_deck_method(P)


    LME_setup_ship_SSTs;

    % *********************************************************************
    % File name for the saving data
    % *********************************************************************
    file_load = LME_output_files('SST_Pairs_all',P);
    file_save = LME_output_files('SST_Pairs_sub',P);
      
    % *********************************************************************
    % Load in pairs for that year and month
    % *********************************************************************                 
    try
        clear('DATA','DATA_save')
        if ~isfield(P,'type'), P.type = 'ship';   end
        if ~isfield(P,'all_ERI_in_one_group'), P.all_ERI_in_one_group = 0;   end
        load(file_load,'Bucket_vs_Bucket','Bucket_vs_ERI','ERI_vs_ERI','Ship_vs_Ship');
        if strcmp(P.type,'Bucket_vs_Bucket')
            DATA = Bucket_vs_Bucket;
        elseif strcmp(P.type,'Ship_vs_Ship')
            DATA = [Bucket_vs_Bucket  Bucket_vs_ERI   ERI_vs_ERI  Ship_vs_Ship];
        end
        clear('Bucket_vs_Bucket','Bucket_vs_ERI','ERI_vs_ERI','Ship_vs_Ship');
    catch
        disp([file_load, ' does not exist or things went wrong while reading data ...'])
        return
    end
    
    % *********************************************************************
    % Load data with corresponding Ship information
    % *********************************************************************
    PP = P;     PP.select_UID = DATA(1,:);
    P1 = ICOADS_read_ship(PP);    clear('PP')
    if strcmp(P.case_name,'nation_deck_method')
        P1.SI_Std(ismember(P1.SI_Std,[7 9])) = -1;
        P1.SI_Std(ismember(P1.SI_Std,[4]))   = 3;
    end

    PP = P;     PP.select_UID = DATA(2,:);
    P2 = ICOADS_read_ship(PP);    clear('PP')
    if strcmp(P.case_name,'nation_deck_method')
        P2.SI_Std(ismember(P2.SI_Std,[7 9])) = -1;
        P2.SI_Std(ismember(P2.SI_Std,[4]))   = 3;
    end

    % *********************************************************************
    % Compute distance in space
    % *********************************************************************
    dist_s = distance(P1.C0_LAT,P1.C0_LON,P2.C0_LAT,P2.C0_LON);
    dist_t = abs(P1.C0_UTC - P2.C0_UTC);

    % *********************************************************************
    % Remove pairs that come from the same group
    % This step is important, becase we did not process deck in step 1.
    % Also have the option to only use day or nighttime measurements
    % *********************************************************************
    clear('l_use')
    grp1  = [P1.DCK P1.SI_Std];
    grp2  = [P2.DCK P2.SI_Std];
    l_use = ~all(grp1 == grp2,2);

    if isfield(P,'pick_day_night')
        % C1_ND == 1 night;   == 2 day
        if P.pick_day_night == 1
            l_use = l_use & P1.C1_ND == 1 & P2.C1_ND == 1;
        elseif P.pick_day_night == 2
            l_use = l_use & P1.C1_ND == 2 & P2.C1_ND == 2;
        end
    end

    DATA   = DATA(:,l_use);
    dist_s = dist_s(l_use);
    dist_t = dist_t(l_use);
    clear('P1','P2','grp1','grp2','l_use');

    % *********************************************************************
    % compute distance of individual pairs
    % *********************************************************************
    clear('I')
    [~,I] = sort(dist_s + dist_t/12);

    % *********************************************************************
    % To transform UID into numbers
    % *********************************************************************
    UID_pairs           = [DATA(1,:)' DATA(2,:)'];
    [point_uni,~,J_uid] = unique(UID_pairs(:));
    NN                  = size(UID_pairs,1);
    J_uid_pairs         = [J_uid(1:NN) J_uid((NN+1):end)];

    % *********************************************************************
    % Remove ships that does not provide additional information
    % *********************************************************************
    disp('eliminating duplicate pairs')
    % each individual data point is only used once
    logic_point     = false(1,numel(point_uni));
    logic_use_pairs = false(1,size(J_uid_pairs,1));
    for ct = I(:)'  % starting searching from the smallest distance

        clear('logic_1','logic_2')
        logic_1 = logic_point(J_uid_pairs(ct,1));
        logic_2 = logic_point(J_uid_pairs(ct,2));

        if logic_1 == 0 && logic_2 == 0
            logic_point(1,J_uid_pairs(ct,:)) = 1;
            logic_use_pairs(ct) = 1;
        end
    end
    clear('ct','ct1','ct2','dist_sort','dist','dist_s','dist_t')

    % *********************************************************************
    % Screening the pairs
    % *********************************************************************
    DATA_save   = DATA(:,logic_use_pairs);

    % *********************************************************************
    % File name for saving data
    % *********************************************************************
    disp('saving data ...')
    save(file_save,'DATA_save','-v7.3');

end
