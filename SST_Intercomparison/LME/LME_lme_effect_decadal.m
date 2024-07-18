function group_decade = LME_lme_effect_decadal(yrs,P)

    group_decade = ceil((yrs-P.yr_start+1)/P.yr_interval);

end
