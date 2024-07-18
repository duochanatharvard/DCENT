function out = timstp2yrmon(year0, month0, X)

    year_final  = year0;
    month_final = month0;
    for i = 1:X
        month_final = month_final + 1;
        if month_final > 12
            month_final = 1;
            year_final = year_final + 1;
        end
    end
    out = year_final * 100 + month_final;
end
