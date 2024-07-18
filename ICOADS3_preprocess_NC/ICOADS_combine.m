function P = ICOADS_combine(P,P_temp)

    var_list = fieldnames(P);
    var_list_temp = fieldnames(P_temp);
    
    if all(ismember(var_list,var_list_temp)) && ...
                                      all(ismember(var_list_temp,var_list))
        for var = 1:numel(var_list)
            eval(['P.',var_list{var},' = [P.',var_list{var},...
                                          '; P_temp.',var_list{var},'];']);
        end
    else
        error('Variables in P and P_temp do not match !!!')
    end  
end