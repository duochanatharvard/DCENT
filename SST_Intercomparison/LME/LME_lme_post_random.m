function out = LME_lme_post_random(BB,logic,id,N_cat,N_groups,do_sampling)

    N_rnd = do_sampling;

    bias_random = nan(size(logic));
    bias_random(logic) = BB.bias_temp{id};
    out.bias_random = reshape(bias_random',N_cat,N_groups);

    if do_sampling ~= 0
        bias_random_std = nan(size(logic));
        bias_random_std(logic) = BB.bias_std_temp{id};
        out.bias_random_std = reshape(bias_random_std',N_cat,N_groups);

        bias_random_rnd = squeeze(nan([size(logic),N_rnd]));
        bias_random_rnd(logic,:) = BB.bias_random_temp{id}';
        out.bias_random_rnd = reshape(bias_random_rnd,N_cat,N_groups,N_rnd);
    end
end
