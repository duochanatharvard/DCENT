function [ita_new, numeric_new] = GA_update_para_standard...
                                        (L, ita, numeric, stepsize, bounds)

    % Assign parameters ===================================================
    sz_ita      = size(ita);
    sz_num      = size(numeric);

    Nm          = numel(L);         % Number of members in the population 
    if numel(sz_ita) == 3, Ns = size(ita,2); else, Ns = 1; end % # stations
    Nn          = sz_num(1);        % Number of numertic parameters

    % run through each member ---------------------------------------------
    ita_new     = ita;
    numeric_new = numeric;

    for ct = 1:Nm
        clear('ita_son')

        if unifrnd(0,1,1) < 0.05      % mutation ..........................
            id                  = GA_choose_parent(L);
            if numel(size(ita)) == 2
                ita_son         = ita(:,id);
            elseif numel(size(ita)) == 3
                ita_son         = ita(:,:,id);
            end
            thshd               = 0.01 + 0.49 * ita_son;
            do_mut              = unifrnd(0,1,size(ita_son)) < thshd;
            ita_son(do_mut)     = ~ita_son(do_mut);

            numeric_son         = numeric(:,id);
            numeric_prop        = numeric_son + stepsize .* normrnd(0,1,Nn,1);
            l_acpt              = unifrnd(0,1,Nn,1) < 0.1;
            numeric_son(l_acpt) = numeric_prop(l_acpt);

        else  % crossover .................................................
            id1                 = GA_choose_parent(L);
            id2                 = GA_choose_parent(L);
            ids                 = round(unifrnd(0,1,Np,Ns))+1;
            ita_son             = false(Np,Ns);
            if numel(size(ita)) == 2
                ita_son(ids == 1)   = ita(ids == 1,id1);
                ita_son(ids == 2)   = ita(ids == 2,id2);
            else
                temp                = ita(:,:,id1);
                ita_son(ids == 1)   = temp(ids == 1);
                temp                = ita(:,:,id2);
                ita_son(ids == 2)   = temp(ids == 2);
            end
            numeric_son             = numeric(:,id1);
            ids                     = round(unifrnd(0,1,Nn,1))+1;
            numeric_son(ids == 2)   = numeric(ids == 2,id2);
        end
        if numel(size(ita)) == 2
            ita_new(:,ct)           = ita_son; 
        else
            ita_new(:,:,ct)         = ita_son; 
        end
        numeric_new(:,ct)           = numeric_son; 
    end

    % ---------------------------------------------------------------------
    for ct = 1:Nn
        l_small                 = numeric_new(ct,:) < bounds(ct,1);
        numeric_new(ct,l_small) = bounds(ct,1);

        l_large                 = numeric_new(ct,:) > bounds(ct,2);
        numeric_new(ct,l_large) = bounds(ct,2);
    end
end