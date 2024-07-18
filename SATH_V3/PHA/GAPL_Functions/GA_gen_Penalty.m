function Penalty = GA_gen_Penalty(ita)
    m       = sum(ita == 1,1);
    N       = size(ita,1);
    Penalty = (2*m+4) .* log10(N);
end