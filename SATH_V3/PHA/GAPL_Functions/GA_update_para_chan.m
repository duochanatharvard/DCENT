% [ita_new, numeric_new] = GA_update_para_chan...
%             (L, L_sta, ita, bp_mag, numeric, stepsize, bounds, round_all)
% 
% This version allows to choose whether to perform sexual reproduction。
% a.k.a. cross over, at the later stage of optimization, when the
% results are very close to optimal, we need asexual reproduction with
% small mutations to fine tune results!
% Parameter controling this behavior is: do_cross 

function [ita_new, numeric_new] = GA_update_para_chan...
                                   (L, L_sta, ita, bp_mag, numeric, ...
                                    stepsize, bounds, round_all)

    % Assign parameters ===================================================
    sz_ita      = size(ita);
    sz_num      = size(numeric);

    Nm          = numel(L);         % Number of members in the population 
    Nt          = sz_ita(1);        % Number of boolean parameters
    if numel(sz_ita) == 3, Ns = size(ita,2); else, Ns = 1; end % # stations
    Nn          = sz_num(1);        % Number of numertic parameters

    p_mut       = 0.004;

    if round_all > 40, allow_asex  = 1; else, allow_asex  = 0; end

    % The parameters below are desides whether location of breaks can move
    % freely, which is gradually frozen to implement simulated annealing
    stp_legth   = 3 * exp(-round_all / 40);

    % This function below calculates the rate of throwing away a detected
    % breakpoint, which starts with equal likelihood of throwing away
    % regardless of magnitude, but gradually moves into tend to keep large
    % breaks and drop small breaks
    sigmoid_scl = @(x) 1 ./ (1 + exp(- (x-9) / 4));
    kp_scl      = 3 * (sigmoid_scl(round_all) - sigmoid_scl(1)); 
    p_kp        = @(x) 1 ./ (1 + exp(-(kp_scl .* (x - 0.5))));

    % run through each member =============================================
    ita_new     = ita;
    numeric_new = numeric;
    for ct = 1:Nm

        % First determine ita ---------------------------------------------
        ita_son                 = false(Nt,Ns);

        for ct_sta = 1:Ns

            if allow_asex == 1
                do_cross = unifrnd(0,1,1) > 0.5;
            else
                do_cross = 1;
            end

            if ct_sta <= size(L_sta,1)
                id1         = GA_choose_parent(L_sta(ct_sta,:));
                if do_cross == 1
                    id2     = GA_choose_parent(L_sta(ct_sta,:));
                end
            else
                id1         = GA_choose_parent(L);
                if do_cross == 1
                    id2     = GA_choose_parent(L);
                end
            end

            % Remove with certain probability .............................
            % starts with a single parent
            pst         = find(ita(:,ct_sta,id1));
            bpm         = bp_mag(:,ct_sta,id1);
            if do_cross == 1    % combine with another when crossover
                pst     = [pst; find(ita(:,ct_sta,id2))];
                bpm     = [bpm; bp_mag(:,ct_sta,id2)];
            else
                pst     = [pst; find(ita(:,ct_sta,id1))];
                bpm     = [bpm; bp_mag(:,ct_sta,id1)];                
            end
            bpm(bpm == 0) = [];

            keep_seed   = unifrnd(0,1,size(pst));
            if ct_sta > size(L_sta,1)
                l_kp    = keep_seed <= min(p_kp(bpm)/2,0.5);
            else
                l_kp    = keep_seed <= min(p_kp(bpm),0.75);
            end
            pst(~l_kp)  = [];
            pst         = unique(pst);

            % randomly shift one thing for or back-ward ...................
            pst         = pst + round(normrnd(0,stp_legth,size(pst)));
            pst(pst < 2) = 2;
            pst(pst > Nt-1) = Nt-1;

            ita_son(pst,ct_sta) = true;
        end

        % Mutation -> for non-break become break with a small probability .
        % how mutation is introduced should depends on the phase you are in
        % specifically, in the exploration phase, every single data point
        % can become a break with every small probability.  However, in the
        % fine tunning stage, every single station is forced to have one
        % mutation at only one time.  This forcing is simply to speed up
        % convergence.
        if do_cross == 1
            l_mut               = ita_son == false;
            l_mut               = l_mut & unifrnd(0,1,Nt,Ns) < p_mut;
        else
            l_mut   = sub2ind([Nt,Ns], round(unifrnd(1,Nt,1,Ns)), 1:Ns);
        end
        ita_son(l_mut)          = true;

        % generate new member for numeric outputs -------------------------
        id1                     = GA_choose_parent(L);
        id2                     = GA_choose_parent(L);
        numeric_son             = numeric(:,id1);
        ids                     = round(unifrnd(0,1,Nn,1))+1;
        numeric_son(ids == 2)   = numeric(ids == 2,id2);

        % mutation -> alpha ...............................................
        if unifrnd(0,1,1,1) < 0.05
            numeric_prop        = numeric_son + stepsize .* normrnd(0,1,Nn,1);
            l_acpt              = unifrnd(0,1,Nn,1) < 0.1;
            numeric_son(l_acpt) = numeric_prop(l_acpt);
        end

        ita_new(:,:,ct)         = ita_son; 
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