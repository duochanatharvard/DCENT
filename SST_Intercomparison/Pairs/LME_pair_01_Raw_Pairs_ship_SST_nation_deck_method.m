% sbatch --account=huybers_lab  -J Pair  -t 10080 -p huce_intel -n 1 --array 1-360 --mem=40000 -o err --wrap='matlab -nosplash -nodesktop -nodisplay -r "LME_setup; num=$SLURM_ARRAY_TASK_ID; [yr_num,mon_num] = ind2sub([30,12],num);for yr = (1991+yr_num):-30:1850,for mon = mon_num,try P.yr = yr;P.mon = mon;LME_pair_01_Raw_Pairs_ship_SST_nation_deck_method(P);catch,end;end;end;quit">>logs/log_pair_ship_SSTs'
% 
% *************************************************************************
% This version pairs all measurements within the ship category
% Pairs are save following below groups:
% 1. Bucket and Bucket
% 2. ERI + Hull and ERI + Hull
% 3. Bucket and ERI + Hull
% 4. Ships and Ships excluding 1, 2, and 3
% This function runs on ICOADS .netcdf files.
% *************************************************************************
%
% Last update: 2021-06-23
 
function LME_pair_01_Raw_Pairs_ship_SST_nation_deck_method(P)

    LME_setup_ship_SSTs;

    % *********************************************************************
    % Loading data                   
    % *********************************************************************
    % DATA = LME_pair_function_read_data(P);                 % 2018 version
    DATA = ICOADS_read_ship(P);      
    disp('Loading data completes!')

    % *********************************************************************
    % File name for the saving data 
    % *********************************************************************
    file_save = LME_output_files('SST_Pairs_all',P);

    % *********************************************************************
    % Pickout pairs
    % *********************************************************************
    if ~isempty(DATA)

        clear('Method','Markers')
        if ~isfield(P,'pair_type'),  P.pair_type = 'nation_deck';   end 
        
        % Assign group ====================================================
        % Method = DATA.C0_SI_4;                             % 2018 version
        Method = DATA.SI_Std;
        l = Method > 0.05   & Method <= 0.5;    Method(l) = 13;
        l = Method > 0.5    & Method < 0.95;    Method(l) = 14;
        l = Method >= 0     & Method <= 0.05;   Method(l) = 0;
        l = Method >= 0.95  & Method <= 1;      Method(l) = 1;
        % Markers = [double(DATA.C0_CTY_CRT)  DATA.C1_DCK'  Method'];  % 2018 version

        % In this initial pairing, decks are not connected because
        % we want the maximum number of pairs being paired
        % If we choose to connect decks, pairs from the same
        % connected decks will be excluded in later screening steps.
        Markers = [DATA.C0_CTY_CRT  DATA.C1_DCK  Method];
        
        % Prepare Data ====================================================
        % in_var  = [DATA.C98_UID; DATA.C0_LON;  DATA.C0_LAT;...
        %            DATA.C0_UTC;  DATA.C0_SI_4];     % 2018 version
        in_var  = [DATA.C98_UID  DATA.C0_LON  DATA.C0_LAT  DATA.C0_UTC  DATA.SI_Std]';        
        uid_index    = 1;
        lon_index    = 2;
        lat_index    = 3;
        utc_index    = 4;
        method_index = 5;
        reso_s       = 5;       % Resolution for binning during pairing
        c_lim        = 300;     % Threshold for distance in space in km
        y_lim        = 3;       % Threshold for distance in latitude;
                                %    it does not subset anything,
                                %    if y_clim<=c_clim/100
        t_lim        = 48;      % Threshold for distance in time in hour
        mode         = 1;       % Mode 1: uses great circle distance (km)
                                % Mode 2: uses distance in x and y (degree)
        N_data = size(in_var,1);
        
        % Subset data for debug ===========================================
        if isfield(P,'debug')
            if P.debug == 1       % for debug
                disp('*************')
                disp('in debug mode')
                disp('*************')
                in_var = in_var(:,1:40:end);
                Markers = Markers(1:40:end,:);
            end
        end
        
        % Pair Data =======================================================
        disp('Pairing data begins!')
        [Pairs,~] = LME_function_get_pairs...
                       (in_var,Markers,lon_index,lat_index,utc_index,...
                        reso_s,[],c_lim,y_lim,t_lim,mode);

        if ~isempty(Pairs)

            % *************************************************************
            % Pickout pairs by combinations of methods
            % *************************************************************
            clear('m1','m2','l_bb','l_be','l_ee','l_ss')
            m1 = Pairs(method_index,:);
            m2 = Pairs(method_index + size(in_var,1),:);
            vars = [uid_index  uid_index+N_data];
            % only save UID     [2021-06-23]
            
            % 1. Bucket vs. Bucket
            l_bb = m1 == 0 & m2 == 0;
            Bucket_vs_Bucket = Pairs(vars,l_bb);
            
            % 2. Bucket vs. ERI + Hull
            l_be = (m1 == 0 & ismember(m2,[1 3])) |...
                   (m2 == 0 & ismember(m1,[1 3]));
            Bucket_vs_ERI = Pairs(vars,l_be); 
            
            % 3. ERI + Hull vs. ERI + Hull
            l_ee = ismember(m1,[1 3]) & ismember(m2,[1 3]);
            ERI_vs_ERI = Pairs(vars,l_ee); 
            
            % 4. Ship vs. Ship excluding 1., 2., and 3.
            l_ss = ~l_bb & ~l_be & ~l_ee;
            Ship_vs_Ship = Pairs(vars,l_ss);

            % *************************************************************
            % Save Data
            % *************************************************************
            disp('Saving data')
            save(file_save,'Bucket_vs_Bucket','Bucket_vs_ERI',...
                           'ERI_vs_ERI','Ship_vs_Ship','-v7.3');
        end
    end
end
