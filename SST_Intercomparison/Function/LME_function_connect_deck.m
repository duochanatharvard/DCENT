% grp_out = LME_function_connect_deck(grp_in,P)

function grp_out = LME_function_connect_deck(grp_in,P)

    list{1} = double([156 156 156; 'DE',156]);
    list{2} = double(['DE',192;'DE',196]);
    list{3} = double(['NL',193;'NL',189]);
    list{4} = double(['JP',187;'JP',761]);
    list{5} = double(['GB',184;'GB',194;'GB',902]);
    list{6} = double(['GB',204;'GB',229;'GB',239]);
    % OWS are not used at all in the analysis                    % Removed on 20181016
    list{7} = double([203 203 203; 207 207 207; 209 209 209; 213 213 213; ...
                      223 223 223; 227 227 227; 233 233 233]);
    list{8} = double(['GB',205;'GB',211]);
    list{9} = double([792 792 792; 892 892 892; 992 992 992]);   % Added 992 on 20221120
    list{10} = double([927,927,927; 128,128,128; 254,254,254; 926 926 926]);  % Added on 20180512

    if isfield(P,'connect_Kobe')
        if P.connect_Kobe == 1
            list{11} = double(['JP',118;'JP',119;'JP',762]);
        end
    end

    grp_out = grp_in;
    for i = 1:numel(list)
        logic = ismember(grp_in(:,1:3),double(list{i}),'rows');
        grp_out(logic,1:3) = repmat(double(list{i}(1,:)),nnz(logic),1);
    end

    logic = ismember(grp_in(:,3),[927, 128, 254, 926]);
    grp_out(logic,3) = 927;                                      % Added on 20180512

    logic = ismember(grp_in(:,3),[792, 892, 992]);
    grp_out(logic,3) = 792;                                      % Added on 20181016

    logic = ismember(grp_in(:,3),[203, 207, 209, 213, 223, 227, 233]);
    grp_out(logic,3) = 203;                                      % Added on 20181016
    % selected ships

end
