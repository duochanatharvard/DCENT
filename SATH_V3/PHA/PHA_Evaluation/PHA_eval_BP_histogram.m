function [x, h, h_t] = PHA_eval_BP_histogram(BP)

    % Calculate breakpint histogram ---------------------------------------
        x = -4.95:.1:4.95;
        h = hist(BP(~isnan(BP)),x);

    % When required, also output histogram as a function of year ----------
    if nargout >= 3
        for ct   = 1:(size(BP,2)/12)
            l    = ((ct-1)*12+1) : (ct*12);
            temp = BP(:,);
            h_t(:,ct) = hist(temp(~isnan(temp)),x);
        end
    end
end