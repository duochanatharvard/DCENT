function id = GA_choose_parent(Loss)
    [~,I]   = sort(Loss);
    R       = 1:length(Loss);
    R(I)    = R;
    p       = (1./R) ./ sum(1./R);
    p_acc   = cumsum(p);
    id      = find(unifrnd(0,1,1) < p_acc,1,'first');
end
