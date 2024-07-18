function [WM,ST,NUM] = ICOADS_NC_function_WM(var_grd)

    WM  = NaN(size(var_grd));
    ST  = NaN(size(var_grd));
    NUM = NaN(size(var_grd));

    for i = 1:size(var_grd,1)
        for j = 1:size(var_grd,2)
            for k = 1:size(var_grd,3)
                
                clear('temp','temp1','temp0','logic')
                temp = var_grd{i,j,k};
                logic = ~isnan(temp);

                if nnz(logic)
                    
                    % [i,j,k]

                    temp1 = temp(logic);
                    temp0 = temp1;

                    if(numel(temp1)>=4)
                        clear('q25','q75','logic_1','logic_2')
                        q25 = quantile(temp1,0.25);
                        q75 = quantile(temp1,0.75);
                        logic_1 = temp1 <= q25;
                        logic_2 = temp1 >= q75;
                        temp1(logic_1) = q25;
                        temp1(logic_2) = q75;
                        WM(i,j,k) = nanmean(temp1);
                    else
                        WM(i,j,k) = nanmean(temp1);
                    end

                    ST(i,j,k) = sqrt(nansum((temp0 - WM(i,j,k)).^2) / numel(temp1));
                    NUM(i,j,k)= numel(temp1);

                end
            end
        end
    end
end
