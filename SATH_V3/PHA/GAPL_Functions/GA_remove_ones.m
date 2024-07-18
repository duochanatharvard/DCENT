function ita = GA_remove_ones(ita,Nt)

    if ~exist('Nt','var'), Nt = 2; end

    for ct = 1:Nt
        l = ita(1:(end-ct),:) == true & ita((1+ct):end,:) == true;
        l((end+1):size(ita,1),:) = false;
        ita(l)                   = false;
    end

    ita(1:2,:)          = false;
    ita(end-1:end,:)    = false;
end