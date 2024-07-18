% DATA = ICOADS_read_ship_kent_id(P)
%
% P.yr
% P.mon
% P.var: a string or a cell list of strings
%        The function will omit 'CX_' when reading data
% P.ref: 'SST' or 'NMAT' or 'None'(shortcut '-')  -->  default: 'SST'
% [Option] P.select_UID      subset by UIDs in the assigned order
%
% Description:
% return only ship data (PT 0~5), and the metadata read for grouping is
% tracked ships from Kent, only SSTs that pass QC and have valid ID are read.
%
% Last updata: 2021-06-23

function DATA = ICOADS_read_ship_kent_id(P)

    if ~isfield(P,'var')
        P.var = {'C0_LON','C0_LAT','C0_UTC','SI_Std','ID_Kent',...
                 'C1_PT','C0_SST','C0_OI_CLIM','C98_UID'};
    end

    DATA = ICOADS_read(P);

    % Remove buoy and CMAN measurements and only use ship measurements
    l_use = DATA.SI_Std ~= -2 & DATA.SI_Std ~= -3 & ...
           (DATA.C1_PT >=0 & DATA.C1_PT <=5);

    % Remove ship without a valid kent ID
    clear('l_empty','l','l_NA')
    l_empty = all(DATA.ID_Kent == 32,2);
    l_NA    = ismember(DATA.ID_Kent, ['NA',repmat(' ',1,28)],'rows');
    l_use   = l_use & ~l_empty & ~l_NA;

    [DATA,~] = ICOADS_subset(DATA,l_use);

end

% For plotting individual ship tracks for debug
% [ship_uni,~,J] = unique(DATA.ID_Kent,'rows');
% lon = DATA.C0_LON;
% lat = DATA.C0_LAT;
% utc = DATA.C0_UTC;
% clf; hold on;
% for ct = 1:10:size(ship_uni,1)
%     plot3(lon(J==ct),lat(J==ct),zeros(nnz(J==ct),1)+ct,'.-');
% end
