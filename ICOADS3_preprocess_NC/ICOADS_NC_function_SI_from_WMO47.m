function C7_WMOMM = ICOADS_NC_function_SI_from_WMO47(C7_SIM)

    % disp('Converting WMO No47 Metadata ...');

    % Assign name list of measurement methods -----------------------------
    mm_list = {'BU ','C  ','HC ','HT ','RAD','TT ','OT ','BTT'};
    mm_num  = [ 0     1     3     4     5     2     -1     6   ];

    clear('C7_WMOMM');
    C7_WMOMM  = ones (size(C7_SIM,1),1) * -1;

    % Convert WMO47 into measurement numbers ------------------------------
    for m = 1:size(mm_list,2)
        clear('logic');
        logic = C7_SIM(:,1) == mm_list{m}(1) & C7_SIM(:,2) == mm_list{m}(2) & C7_SIM(:,3) == mm_list{m}(3);
        C7_WMOMM (logic) = mm_num(m);
    end

    % disp('Converting WMO No47 Metadata Compeletes!');
    % disp(' ');
end