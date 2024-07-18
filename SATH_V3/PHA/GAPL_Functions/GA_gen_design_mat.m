function D = GA_gen_design_mat(tim,ita)

    % break indicate the ending of the current seg
    Nt             = size(tim,1);
    if Nt == 1, Nt = size(tim,2); end

    D       = zeros(Nt,nnz(ita)+1);
    D(:,1)  = 1;
    tim_bp  = find(ita);
    for ct  = 1:numel(tim_bp)
        l   = (tim_bp(ct)+1):Nt;
        D(l,ct+1) = 1;
    end
end