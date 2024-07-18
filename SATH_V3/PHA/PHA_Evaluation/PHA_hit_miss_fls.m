function [stats, hit, miss, hit2, fls_alrm, x] = ...
                           PHA_hit_miss_fls(BP_result, BP_true, do_hist, x)

    if size(BP_true,2) == 3  % At the station level
        [ID_uni, ~, J] = unique([BP_result(:,1); BP_true(:,1)]);
        level          = 1;

    elseif size(BP_true,2) == 4  % At the pair-wise level
        [ID_uni, ~, J] = unique([BP_result(:,1:2); BP_true(:,1:2)],'rows');
        level          = 2;
    end
    J_result       = J(1:size(BP_result,1));
    J_true         = J((size(BP_result,1)+1):end);

    % Calculate hit / miss / and false alarms
    hit         = false(size(BP_true,1),1);
    miss        = false(size(BP_true,1),1);
    hit2        = false(size(BP_result,1),1);
    fls_alrm    = false(size(BP_result,1),1);
    for ct  = 1:size(ID_uni,1)

        if rem(ct,10000) == 0; disp(num2str(ct)); end
        
        l_rslt      = J_result == ct;
        bp_result   = BP_result(l_rslt,level + 1);

        l_true      = J_true == ct;
        bp_true     = BP_true(l_true,level + 1);

        [hit(l_true,1), miss(l_true,1), hit2(l_rslt,1), fls_alrm(l_rslt,1)] = ...
                               PHA_hit_miss_fls_single(bp_result, bp_true);
    end

    % Calculate statistics ================================================
    stats = [nnz(hit); nnz(miss); nnz(hit2); nnz(fls_alrm)];

    % Calculate histogram =================================================
    if ~exist('do_hist','var'), do_hist = 1; end
    if ~exist('x','var'), x = -4.95:0.1:4.95; end
    
    if do_hist == 1
        hit             = hist(BP_true(hit == 1, level + 2), x);
        miss            = hist(BP_true(miss == 1, level + 2), x);
        if level == 1
            hit2        = hist(BP_result(hit2 == 1, 6), x);
            fls_alrm    = hist(BP_result(fls_alrm == 1, 6), x);
        elseif level == 2
            hit2        = hist(BP_result(hit2 == 1, 5), x);
            fls_alrm    = hist(BP_result(fls_alrm == 1, 5), x);
        end
    end
end

% *************************************************************************
function [hit, miss, hit2, fls_alrm] = ...
                PHA_hit_miss_fls_single(bp_result, bp_true)

    epoch = 12;

    % first calculate hit and miss
    bp_reference = bp_true;     % here reference is truth, so hit is hit
                                % not hit is miss, and the output has the 
                                % same dimensionality as truth
    bp_compared  = bp_result;
    hit          = false(0);
    for ct = 1:size(bp_reference,1)
        hit(ct)  = any(abs(bp_reference(ct,1) - bp_compared(:,1)) <= epoch);
    end
    miss = ~hit;

    % first calculate hit and miss
    bp_reference = bp_result;   % here reference is result, so hit is hit
                                % not hit is false alarm, and the output 
                                % has the same dimensionality as result
    bp_compared  = bp_true;
    hit2         = false(0);
    for ct = 1:size(bp_reference,1)
        hit2(ct)  = any(abs(bp_reference(ct,1) - bp_compared(:,1)) <= epoch);
    end
    fls_alrm = ~hit2;

end