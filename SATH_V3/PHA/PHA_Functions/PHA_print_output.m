function PHA_print_output(data, print_type, data_type, Para, D)

    if strcmp(print_type,'pair')
        % -----------------------------------------------------------------
        disp(repmat('=',1,100))
        disp('UID1         UID2   time  type   magnitude    zscore    rmv_st  rmv_ed  inferred?  auto-corr  yrmon  ')
        if ~isempty(data)
            data      = data(data(:,9)==0,:);
            data_show = data(:,[1:9 11]);
            for ct = 1:size(data_show,1)
                out(ct,1) = timstp2yrmon(1970, 1, data_show(ct,3)-1);
            end

            disp(num2str([data_show out],...
                'S%6.0f - S%6.0f : %4.0f %6.0f %11.6f %10.3f %6.0f %6.0f %8.0f %8.2f %8.0f '))
        end
        disp(repmat('-',1,100))
        disp(num2str(size(data,1),['A total of %6.0f ',data_type]))
        disp(repmat('=',1,100))
        % -----------------------------------------------------------------
    elseif strcmp(print_type,'attribute') || strcmp(print_type,'combine')
        disp('UID      time   year  month     type    magnitude     zscore   auto-corr   #NB')
        if ~isempty(data)
            [~,I]       = sort(data(:,1));
            disp(repmat('=',1,100))
            disp(repmat('-',1,100))
            disp(num2str(data(I,1:9),...
                'S%6.0f:%5.0f%7.0f%7.0f%10.0f%10.5f%10.5f%10.2f%7.0f'))
        end
        disp(repmat('-',1,100))
        disp(num2str(size(data,1),['A total of %6.0f ',data_type]))
        disp(repmat('=',1,100))
        % -----------------------------------------------------------------
    elseif strcmp(print_type,'combine_debug')
        disp('UID      time   year  month     type  magnitude     zscore   auto-corr   #NB')
        if ~isempty(data)
            disp(repmat('=',1,100))
            disp(repmat('-',1,100))
            disp(num2str(data(:,1:9),...
                'S%6.0f:%5.0f%7.0f%7.0f%10.0f%10.5f%10.5f%10.2f%7.0f'))
        end
        disp(repmat('-',1,100))
        disp(num2str(size(data,1),['A total of %6.0f ',data_type]))
        disp(repmat('=',1,100))
        % -----------------------------------------------------------------
    elseif strcmp(print_type,'adjust')

        Ns = numel(D.UID);

        disp(repmat('=',1,100))
        disp('UID      time   #NB  adjust adjust_rnd')
        disp(repmat('-',1,100))
        if ~isempty(data)
            for sta_id = 1:Ns
                disp(['Station',num2str(sta_id),'  ',D.Sta(sta_id,:)])
                if any(data(:,1) == sta_id)
                    adj   = sortrows(data(data(:,1) == sta_id,:),2);
                    yrs   = [1  adj(:,2)'  size(D.T,2)*size(D.T,3)];
                    adjs  = flipud([0; cumsum(flipud(-adj(:,10)))]);
                    for ct = (numel(yrs)-1):-1:1
                        disp(['     ',num2str(timstp2yrmon(Para.Fixed_para_yr_st, 1, yrs(ct)-1)),' - ', ...
                            num2str(timstp2yrmon(Para.Fixed_para_yr_st, 1, yrs(ct+1)-1)), ...
                            '     Adjustment ',num2str(adjs(ct),'%6.2f')]);
                    end
                else
                    disp('     No adjustment made to this station !!!')
                end
            end
        end
        disp(repmat('=',1,100))
    end
end