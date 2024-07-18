function [ita_new, numeric_new] = GA_update_para_li ...
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

        % First find mother and father ....................................
        clear('ita_son')
        id1                     = GA_choose_parent(L);
        id2                     = GA_choose_parent(L);

        % combine mother and father .......................................
        if numel(size(ita)) == 2
            ita_temp            = ita(:,id1) | ita(:,id2);
        elseif numel(size(ita)) == 3
            ita_temp            = ita(:,:,id1) | ita(:,:,id2);
        end

        % remove with 0.5 probability .....................................
        l_keep                  = unifrnd(0,1,Np,Ns) <= 0.5;
        ita_temp(~l_keep)       = false;

        % randomly shift one thing for or back-ward .......................
        pst                     = find(ita_temp);
        l_rnd                   = unifrnd(0,1,numel(pst),1);
        pst(l_rnd<0.3)          = pst(l_rnd<0.3) - 1;
        pst(l_rnd>0.7)          = pst(l_rnd>0.7) + 1;

        % generate new member .............................................
        ita_son                 = false(Np,Ns);
        l_rm                    = rem(pst,Np) == 0;
        pst(l_rm)               = [];
        ita_son(pst)            = true;
        
        % randomize alpha .................................................
        numeric_son             = numeric(:,id1);
        ids                     = round(unifrnd(0,1,Nn,1))+1;
        numeric_son(ids == 2)   = numeric(ids == 2,id2);

        % mutation -> for non-break become break with a small .............
        % probability
        l_mutation              = ita_son == false & unifrnd(0,1,Np,Ns) < 0.01;
        ita_son(l_mutation)     = true;

        % mutation -> alpha ...............................................
        if unifrnd(0,1,1,1) < 0.05
            numeric_prop        = numeric_son + stepsize .* normrnd(0,1,Nn,1);
            l_acpt              = unifrnd(0,1,Nn,1) < 0.1;
            numeric_son(l_acpt) = numeric_prop(l_acpt);
        end

        if numel(size(ita)) == 2
            ita_new(:,ct)       = ita_son; 
        else
            ita_new(:,:,ct)     = ita_son; 
        end
        numeric_new(:,ct)       = numeric_son; 
    end

    % ---------------------------------------------------------------------
    for ct = 1:Nn
        l_small                 = numeric_new(ct,:) < bounds(ct,1);
        numeric_new(ct,l_small) = bounds(ct,1);

        l_large                 = numeric_new(ct,:) > bounds(ct,2);
        numeric_new(ct,l_large) = bounds(ct,2);
    end
end