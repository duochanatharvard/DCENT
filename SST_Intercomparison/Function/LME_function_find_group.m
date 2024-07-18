function group = LME_function_find_group(JJ)

    N = max(JJ(:));
    check = zeros(1,N);
    group = sparse(zeros(1,N));
    ct = 0;

    for i = 1:N
        if(check(i) == 0)
            list = [i];
            ct = ct + 1;
            while isempty(list) == 0,
                ii = list(1);
                check(ii) = 1;
                group(ct,ii) = 1;
                temp = unique([JJ(JJ(:,1) == ii,2); JJ(JJ(:,2) == ii,1)]);
                temp(check(temp) == 1) = [];
                if ~isempty(temp),
                    temp = temp(~ismember(temp,list));
                    list = [list; temp];
                end
                list(1) = [];
            end
        end
    end
end
