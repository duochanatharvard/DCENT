function ICOADS_version = ICOADS_NC_version(yr)
    if yr <= 2014
        ICOADS_version = '3.0.0';
    else
        ICOADS_version = '3.0.2';
    end
end