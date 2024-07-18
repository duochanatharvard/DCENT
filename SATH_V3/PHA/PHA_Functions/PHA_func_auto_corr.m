% [auto,auto_biased] = PHA_func_auto_corr(input,yrs)
%
function [auto,auto_biased] = PHA_func_auto_corr(input,yrs)

    if ~exist('yrs','var'),  yrs = []; end
    if ~isempty(yrs),   yrs([1 end]) = [];  end

    % reshape and remove nan at the beginning and end
    input       = reshape(input,1,numel(input));

    st_id       = find(~isnan(input),1);
    ed_id       = find(~isnan(input),1,'last');
    
    input       = input(st_id:ed_id);
    yrs         = yrs - st_id + 1;

    % disp(nnz(~isnan(input)))

    % loop over segments to calculate auto
    win_len     = floor(min(nnz(~isnan(input))/3,100));
    window      = 1:win_len; 
    R           = []; 
    for slide   = 1:1:(length(input)-win_len+1)
        temp    = input(window+slide-1);
        if all(~ismember(window+slide,yrs))
            if nnz(~isnan(temp(1:end-1) + temp(2:end))) >= 5
                R       = [R CDC_corr(temp(1:end-1),temp(2:end))]; 
            end
        end
    end
    
    % report the median as the final estimate
    auto = quantile(R,0.5);

    % also report a potentially biased estimate if jump exists
    auto_biased = CDC_corr(input(1:end-1),input(2:end));
end