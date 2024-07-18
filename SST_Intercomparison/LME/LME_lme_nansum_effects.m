function out = LME_lme_nansum_effects(field_nat,field_dck,Pos,logic)

    temp1 = field_nat(:,Pos,:);
    temp2 = field_dck;
    temp2(isnan(temp2)) = 0;
    out = temp1 + temp2;

    N = size(out,3);
    N_groups = size(field_dck,2);
    N_region = size(field_dck,1);
    mask = reshape(logic, N_region, N_groups);
    out(repmat(full(mask),1,1,N) == 0) = nan;

end
