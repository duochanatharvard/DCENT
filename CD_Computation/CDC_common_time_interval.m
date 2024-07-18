function [yr_start,yr_end] = CDC_common_time_interval

    yr_start = 1850;
    vec = datevec(date);
    yr_end   = vec(1);
    % yr_end   = 2023;
end
