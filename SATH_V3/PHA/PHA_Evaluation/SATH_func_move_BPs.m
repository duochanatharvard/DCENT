function BP_meta = SATH_func_move_BPs(BP_meta,Data)

    % If metadata indicated break happens in a month without data
    % move the metadata indicated breakpoint to the nearest month 
    % that has data and is within up to +/- 2 months
    % Otherwise, this breakpoint is discarded
    Data_exist = ~isnan(Data);
    BP_meta = BP_meta(:,:);

    for ct = 1:1:size(BP_meta,1)
        bp_meta    = BP_meta(ct,:);
        data_exist = Data_exist(ct,:);
        lst_mt     = find(bp_meta);
        lst_dt     = find(data_exist);
        for ct_mt  = 1:numel(lst_mt)
            id0    = lst_mt(ct_mt);
            if data_exist(id0) == 0 || data_exist(id0-1) == 0
                id1               = max(lst_dt(lst_dt < id0));
                bp_meta(id1)      = bp_meta(id0);
                if any(isnan(bp_meta))
                    bp_meta(id0)  = nan;
                else
                    bp_meta(id0)  = 0;
                end
            end
        end
        BP_meta(ct,:) = bp_meta;
    end
end
