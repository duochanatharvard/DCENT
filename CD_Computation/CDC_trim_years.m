function [out, yr] = CDC_trim_years(in, yr, yr_start, yr_end)

    trg1 = 1;
    trg2 = yr_end - yr_start + 1;
    
    sub1 = yr_start - yr(1) + 1;
    sub2 = yr_end - yr(1) + 1;
    
    if sub1 < 1       
        sub1 = 1;    
        trg1 = yr(1) - yr_start + 1;
    end
    if sub2 > numel(yr)
        sub2 = numel(yr); 
        trg2 = yr(end) - yr_start + 1;
    end
    
    out = nan(size(in,1),size(in,2),size(in,3),yr_end-yr_start+1);
    out(:,:,:,trg1:trg2) = in(:,:,:,sub1:sub2);

    yr = yr_start : yr_end;
end