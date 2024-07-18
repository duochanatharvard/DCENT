function [T_corr, CORR] = PHA_S6_generate_corr_data(ADJ, mask, do_rnd, D)

    Ns      = size(D.T,1);
    Nt      = size(D.T(:,:),2);

    % Generate correction fields ..........................................
    CORR    = zeros(Ns,Nt);

    if ~isempty(ADJ)
        temp    = ADJ(:,[1 2 10+do_rnd]);
        I       = sub2ind([Ns, Nt],temp(:,1),temp(:,2));    
        CORR(I) = temp(:,3);
        CORR    = PHA_func_jump2adj(CORR, 'backward');
    end

    % Mask out segments that are required to be removed ...................
    CORR(mask)  = nan;
    % if ~isempty(Data_RMV)
    %     for ct = 1:size(Data_RMV,1)
    %         CORR(Data_RMV(ct,1),Data_RMV(ct,2):Data_RMV(ct,3)) = nan;
    %     end
    % end

    % Output is the summation between the raw and correction/adjustment ...
    T_corr = CORR + D.T(:,:);
end