function M = LME_lme_matrix_generate(DD,PP)
% (N_pairs,N_groups,J_grp_1,J_grp_2,W_X,pos_val,neg_val)

    if ~isfield(DD,'W_X'),
        DD.W_X = zeros(1,PP.N_groups);
    end

    if ~isfield(PP,'pos_val'),
        PP.pos_val = 1;
        PP.neg_val = -1;
    end

    M = sparse(PP.N_pairs,PP.N_groups);

    index_pos = sub2ind([PP.N_pairs,PP.N_groups],[1:PP.N_pairs]',DD.J_grp_1);
    index_neg = sub2ind([PP.N_pairs,PP.N_groups],[1:PP.N_pairs]',DD.J_grp_2);

    logic = index_pos == index_neg;
    index_pos(logic) = [];
    index_neg(logic) = [];

    M(index_pos) = PP.pos_val;
    M(index_neg) = PP.neg_val;
    M = [M; DD.W_X];

    clear('index_pos','index_neg','logic');
end
