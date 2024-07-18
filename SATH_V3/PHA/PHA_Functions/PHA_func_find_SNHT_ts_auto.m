% Find threshold for SNHT TS values
function thshd = PHA_func_find_SNHT_ts_auto(NN,auto,Para)

    if NN > Para.SNHT_N_list(end)
        NN = Para.SNHT_N_list(end);
        
    elseif NN < Para.SNHT_N_list(1)
        NN = Para.SNHT_N_list(1);
    end

    if auto > .95
        auto = .95;
    elseif auto < -0
        auto = 0;
    end

    thshd = interp2(Para.SNHT_N_list,Para.SNHT_auto_list,...
                    Para.SNHT_ts',NN,auto,'linear');
    if isnan(thshd)
        thshd = interp2(Para.SNHT_N_list,Para.SNHT_auto_list,...
                        Para.SNHT_ts',NN,0,'linear');
    end
        
end