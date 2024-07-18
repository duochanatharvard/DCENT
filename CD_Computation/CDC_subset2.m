% [P,var_list] = CDC_subset2(P,l_use,dim)

function [P,var_list] = CDC_subset2(P,l_use,dim)

    var_list = fieldnames(P);
    
    for var = 1:numel(var_list)
        try
            eval(['P.',var_list{var},' = CDC_subset(P.',var_list{var},',dim,l_use);']);
        catch
            disp([var_list{var},' is not subset'])
        end
    end
end