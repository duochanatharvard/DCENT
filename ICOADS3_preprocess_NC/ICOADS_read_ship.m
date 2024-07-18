% DATA = ICOADS_read_ship(P)
%
% P.yr
% P.mon
% P.var: a string or a cell list of strings
%        The function will omit 'CX_' when reading data
% P.ref: 'SST' or 'NMAT' or 'None'(shortcut '-')  -->  default: 'SST'
% P.do_connect      default: 1
% P.connect_Kobe    default: 1
% [Option] P.subset_method   subset only one type of SSTs
% [Option] P.select_UID      subset by UIDs in the assigned order
%
% Description:
% return only ship data (PT 0~5), and the metadata read for grouping is
% nation-deck-method, only SSTs that pass QC are read. The function
% automatically combines deck.
%
% Last updata: 2021-06-23

function DATA = ICOADS_read_ship(P)

    if ~isfield(P,'var')
        P.var = {'C0_LON','C0_LAT','C0_UTC','SI_Std','C1_DCK','C0_CTY_CRT',...
                 'C1_PT','C0_SST','C0_OI_CLIM','C98_UID','QC_FINAL_SST','C1_ND'};
    end

    DATA = ICOADS_read(P);

    % Connect decks
    if ~isfield(P,'do_connect'),    P.do_connect = 1;   end
    if ~isfield(P,'connect_Kobe'),  P.connect_Kobe = 1; end
    DATA.DCK = LME_function_preprocess_deck([DATA.C0_CTY_CRT DATA.C1_DCK],P);

    % Remove buoy and CMAN measurements and only use ship measurements
    % Subset using PT1--5 and missing PT
    % However, as long as the SST method belongs to 0--6, we use the record
    l_use = DATA.SI_Std ~= -2 & DATA.SI_Std ~= -3 & ...
           (DATA.C1_PT >=0 & DATA.C1_PT <=5 | isnan(DATA.C1_PT));
    l_ship = ismember(DATA.SI_Std,[0,1,2,3,4,5,6]);
    l_use = l_use | l_ship;
    if isfield(P,'subset_method')
        l_use = l_use & ismember(DATA.SI_Std,P.subset_method);
    end
    [DATA,~] = ICOADS_subset(DATA,l_use);
    
    % Combine 797/798 ships into 792 :: 20221120
    l_chg  = DATA.DCK(:,3) == 797 | DATA.DCK(:,3) == 798;
    l3_chg = (DATA.DCK(:,3) == 797 | DATA.DCK(:,3) == 798) & DATA.DCK(:,1) > 100;
    DATA.DCK(l_chg,3)  = 792;
    DATA.DCK(l3_chg,:) = 792;
end
