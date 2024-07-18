LME_setup_ship_SSTs;
file_save  = LME_output_files('SST_Pairs_sum',P);

disp('==============================================================>')
disp('Load in data ...')
rm_list  = {'C1_DCK','C0_CTY_CRT','QC_FINAL_SST','C1_ND','C1_PT'};

% Find a list of year-month to be combined
process_list = [];
for yr = P.subset_yr_list;
    for mon = 1:12
        process_list = [process_list; [yr mon]];
    end
end

% Find a list of year-month that has been combined
if exist('do_update','var')
    if do_update ~= 0
        yr_list  = P.subset_yr_list(end);
        file_previous = LME_output_files('SST_Pairs_sum',P);
        try
            DATA_previous = load(file_previous);
        catch
            try
                P2 = P;  P2.subset_yr_list(end) = []; 
                file_previous = LME_output_files('SST_Pairs_sum',P2);
                DATA_previous = load(file_previous);
            catch
                disp('start from beginning')
                DATA_previous.P1.C0_YR = zeros(0,1);
                DATA_previous.P1.C0_MO = zeros(0,1);
                do_update =0;
            end
        end
        ymu = unique([DATA_previous.P1.C0_YR DATA_previous.P1.C0_MO],'rows');

        % only need to do the remaining year-month
        process_list = process_list(~ismember(process_list,ymu,'rows'),:);
    end
end

% Combine year - month that needs to be combined ---------------------
clear('P1','P2')
for ct = 1:size(process_list,1) 
    yr  = process_list(ct,1);
    mon = process_list(ct,2);

    disp(['Starting year: ',num2str(yr),'  month:', num2str(mon)])
    PP = P;     PP.yr = yr;  PP.mon = mon; 
    file_load = LME_output_files('SST_Pairs_sub',PP);

    try
        clear('DATA_save');  load(file_load,'DATA_save');

        PP = P;PP.yr = yr;PP.mon = mon;PP.select_UID = DATA_save(1,:);
        clear('P1_temp'); P1_temp = ICOADS_read_ship(PP); clear('PP')
        if strcmp(P.case_name,'nation_deck_method')
            P1_temp = LME_function_adjust_WWII(P1_temp);
            P1_temp.SI_Std(ismember(P1_temp.SI_Std,[7 9])) = -1;
            P1_temp.SI_Std(ismember(P1_temp.SI_Std,[4]))   = 3;
        end
        P1_temp = rmfield(P1_temp,rm_list);

        PP = P;PP.yr = yr;PP.mon = mon;PP.select_UID = DATA_save(2,:);
        clear('P2_temp'); P2_temp = ICOADS_read_ship(PP); clear('PP')
        if strcmp(P.case_name,'nation_deck_method')
            P2_temp = LME_function_adjust_WWII(P2_temp);
            P2_temp.SI_Std(ismember(P2_temp.SI_Std,[7 9])) = -1;
            P2_temp.SI_Std(ismember(P2_temp.SI_Std,[4]))   = 3;
        end
        P2_temp = rmfield(P2_temp,rm_list);

        if ~exist('P1','var')
            P1 = P1_temp;      P2 = P2_temp;
        else
            P1 = ICOADS_combine(P1,P1_temp);
            P2 = ICOADS_combine(P2,P2_temp);
        end
    catch
        disp(['Problems in Year ',num2str(yr),' Month ',num2str(mon)]);
    end
end

clear('P1_temp','P2_temp','var_list_temp','DATA_save','yr','mon');
disp('Load in data completes!')
disp(' ')

% If in the update mode, combine with pairs in the previous year
if exist('do_update','var')
    if do_update ~= 0
        P1 = ICOADS_combine(DATA_previous.P1,P1);
        P2 = ICOADS_combine(DATA_previous.P2,P2);
    end
end

save(file_save,'P1','P2','-v7.3');
