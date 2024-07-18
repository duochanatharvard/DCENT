function [l_high_quality,r] = AOI_func_high_quality_stations(raw_AST_anm,raw_SST_anm,P)


    raw_SST_anm = raw_SST_anm + raw_AST_anm * 0;
    raw_AST_anm = raw_SST_anm * 0 + raw_AST_anm;
    
    raw_SST_anm = raw_SST_anm - nanmean(raw_SST_anm,3);
    raw_AST_anm = raw_AST_anm - nanmean(raw_AST_anm,3);
    
    temp1  = CDC_detrend(raw_SST_anm(:,:),2);
    temp2  = CDC_detrend(raw_AST_anm(:,:),2);
    
    r      = CDC_corr(temp1,temp2,2);

    l_high_quality = r > P.key;
    
end
