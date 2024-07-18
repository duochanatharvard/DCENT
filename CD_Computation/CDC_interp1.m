function AT_itp = CDC_interp1(AT,l_exclude,extrapolate)

    if size(AT,1)~=1, AT = AT'; end
    
    if exist('l_exclude','var')
        if isempty(l_exclude)
            l_exclude = false(size(AT)); 
        else
            if size(l_exclude,1)~=1 
                l_exclude = l_exclude'; 
            end
        end
    else
        l_exclude = false(size(AT)); 
    end

    if ~exist('extrapolate','var')
        extrapolate = 0;
    end

    xx = 1:numel(AT);
    
    ll  = ~isnan(AT) & ~l_exclude;
    
    AT_itp = interp1(xx(ll),AT(ll),xx);
    
    if extrapolate == 1
        AT_itp(1:find(ll,1)) = AT_itp(find(ll,1));
        AT_itp(find(ll,1,'last'):end) = AT_itp(find(ll,1,'last'));
    end
    
    if size(AT_itp,1) == 1, AT_itp = AT_itp';  end

end