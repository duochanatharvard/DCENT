% [WM,ST,NUM] = LME_function_grd_average(in_var,is_w,is_un)
% 1. access of weight,
% 2. access of uncertainty
%
% Last updata: 2017-04-07
function [WM,ST,NUM] = LME_function_grd_average(in_var,is_w,is_un)

    WM = NaN(size(in_var));
    ST = NaN(size(in_var));
    NUM = NaN(size(in_var));

    for i = 1:size(in_var,1)
        for j = 1:size(in_var,2)
            for k = 1:size(in_var,3)

                if nnz(~isnan(in_var{i,j,k}))

                    clear('temp','w','un')
                    temp = in_var{i,j,k};
                    temp = temp(:,~isnan(temp(1,:)));

                    if ~isempty(is_w)
                        w = temp(is_w,:);
                    else
                        w = ones(1,size(temp,2));
                    end

                    if ~isempty(is_un)
                        un = temp(is_un,:);
                    end

                    WM(i,j,k) = nanmean(temp(1,:).*w) / nanmean(w);

                    if ~isempty(is_un)
                        ST(i,j,k) = sqrt( nansum(un.^2 .* w.^2) ./ (nansum(w)^2) );
                    else
%                         ST(i,j,k) = sqrt(var(temp(1,:),w));
                    end

                    NUM(i,j,k)= size(temp,2);

                end
            end
        end
    end
end
