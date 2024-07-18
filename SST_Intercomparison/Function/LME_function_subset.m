% [P,var_list] = LME_function_subset(P,l_rm)

function [P,var_list] = LME_function_subset(P,l_rm)

    var_list = fieldnames(P);
    for var = 1:numel(var_list)
        if ~ismember(var_list{var},{'C0_ID','C0_CTY_CRT','GRP','DCK'})
            eval(['P.',var_list{var},' = P.',var_list{var},'(~l_rm);']);
        else
            eval(['P.',var_list{var},' = P.',var_list{var},'(~l_rm,:);']);
        end
    end
end