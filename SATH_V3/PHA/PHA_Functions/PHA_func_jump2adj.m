% corr = PHA_func_jump2adj(adj, mode)

function corr = PHA_func_jump2adj(adj, mode)
    if strcmp(mode,'forward') % jump -> bias
        adj(isnan(adj)) = 0;
        adj  = [zeros(size(adj,1),1) adj];
        corr = cumsum(adj,2);
        corr = corr(:,1:end-1); 
    else                      % jump -> correction
        adj(isnan(adj)) = 0;
        corr = cumsum(fliplr(adj),2);
        corr = corr(:,end:-1:1); 
    end
end