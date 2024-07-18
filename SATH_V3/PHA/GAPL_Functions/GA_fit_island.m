% [Loss_record, ita_best, beta, numeric_best, mu_hat] = ...
%                            GA_fit_MVN_island(x,dis,model_type,tim,scheme)
% Input:
% x          :: data -> dimensionality Ntx1
% model_type :: "no_slope" "one_slope" "multiple_slopes"
% tim        :: time (default = (1:Nt)')
% scheme     :: 1. classic GA       2. Li and Laud 2012

% all inputs and outputs have the dimensionality of Nt x Ns

function [Loss_record, ita_best, beta, numeric_best, mu_hat] = ...
                                 GA_fit_island(x,dis,model_type,tim,scheme,...
                                 seeding)

    do_debug    = 1;
    do_white    = 0;

    % #####################################################################
    % Setting up parameters of the fitting
    % #####################################################################
    if size(x,1)   == 1,    x = x';   end
    if size(tim,1) == 1,  tim = tim'; end

    Nt      = size(x,1);        % Number of time steps
    Ns      = size(x,2);        % Number of stations
    if ~exist('tim','var'), tim = (1:Nt)'; end
    if isempty(tim),        tim = (1:Nt)'; end 
    Ng      = 1;                % Number of groups
    Nmpg    = min(1000,max(300,Nt/2));  % Number of members per group
    Mi      = 5;                % Migeration every Mi rounds
    Mn      = 20;               % Number of imgrated members
    Nm      = Nmpg * Ng;        % Total number of members   

    if ~exist('scheme','var'), scheme = 3; end
    if isempty(scheme),        scheme = 3; end 

    switch scheme
        case 1, do_add_test = 0;
        case 2, do_add_test = 0;
        case 3, do_add_test = 1;
    end

    min_trend_length = 120;

    % #####################################################################
    % Generate random initial Ng * Nm members 
    % #####################################################################
    % >> generate random timing in ita (break points in mean (and slope))
    % dimensionality: Nt x Nm
    if strcmp(model_type,'decadal_var')
        ita             = unifrnd(0,1,Nt,Ns+1,Nm)   < 0.01;
    else
        if exist('seeding','var')
            N_each      = round(Nm/10);
            % Half of the breakpoints contains no seeding information
            ita         = unifrnd(0,1,Nt,Ns,4*N_each)   < 0.01;
            % 10% has the same as seeding, which is SNHT output
            ita(:,:,4*N_each + (1:N_each)) = repmat(seeding > 0,1,1,N_each);
            % 10% has the same as |seeding| > 0.5 plus some randomness
            ita(:,:,5*N_each + (1:N_each)) = repmat(seeding > 0.5,1,1,N_each) | ...
                                unifrnd(0,1,Nt,Ns,N_each)   < 0.002;
            % 10% has the same as |seeding| > 1 plus some randomness
            ita(:,:,6*N_each + (1:N_each)) = repmat(seeding > 1,1,1,N_each) | ...
                                unifrnd(0,1,Nt,Ns,N_each)   < 0.004;
            % 10% has the same as |seeding| > 1.5 plus some randomness
            ita(:,:,7*N_each + (1:N_each)) = repmat(seeding > 1.5,1,1,N_each) | ...
                                unifrnd(0,1,Nt,Ns,N_each)   < 0.006;
            % 10% has the same as |seeding| > 2 plus some randomness
            ita(:,:,8*N_each + (1:N_each)) = repmat(seeding > 2,1,1,N_each) | ...
                                unifrnd(0,1,Nt,Ns,N_each)   < 0.008;
            % 10% has the same as |seeding| > 0.5 plus some randomness
            ita(:,:,9*N_each + (1:N_each)) = repmat(seeding > 2.5,1,1,N_each) | ...
                                unifrnd(0,1,Nt,Ns,N_each)   < 0.01;            
        else
            ita         = unifrnd(0,1,Nt,Ns,Nm) < 0.01;
        end
    end
    ita                 = GA_remove_ones(ita);
    if strcmp(model_type,'decadal_var')
        ita(:,end,:)    = GA_remove_ones(ita(:,end,:),min_trend_length);
    end
    % >> generate alpha and decorrelation values
    if exist('seeding','var')
        if do_debug, disp('  Calculate auto-correlation using the best member'); end
        ita2            = seeding;
        ita2([1 end],:) = true;
        x_in            = x - nanmean(x,1);
        auto_prop       = PHA_func_auto_corr(x_in(:),find(ita2));
        if ~isnan(auto_prop), auto = auto_prop; end
        numeric(1,:)    = repmat(auto,1,Nm);
        if do_debug, disp(['  |-> Calculated auto-corr: ',num2str(auto,'%6.2f')]); end
    else
        numeric(1,:)    = unifrnd(0,0.99,1,Nm);
    end
    numeric(2,:)        = unifrnd(0,10,1,Nm);
    numeric(3,:)        = unifrnd(0,5,1,Nm);
    stepsize            = [0.0; 0.03; 0.05];
    bounds              = set_bounds(do_white);

    for ct = 1:size(numeric,1)
        l_small               = numeric(ct,:) < bounds(ct,1);
        numeric(ct,l_small)   = bounds(ct,1);

        l_large               = numeric(ct,:) > bounds(ct,2);
        numeric(ct,l_large)   = bounds(ct,2);
    end

    % ---------------------------------------------------------------------
    % Calculate the loss for the initial generation
    % ---------------------------------------------------------------------
    if do_debug, disp('  Calculate loss for initial population'); end
    Loss                       = nan(1,Nm);
    Loss_sta                   = nan(Ns,Nm);
    bp_mag                     = zeros(size(ita));
    for ct_mem = 1:Nm
        [Loss(1,ct_mem), Loss_sta(:,ct_mem), ~, bp_mag(:,:,ct_mem)] = ...
            GA_fit_mu_given_other_para_MVN(x,tim,...
            ita(:,:,ct_mem),numeric(:,ct_mem),dis,model_type);
    end

    % #####################################################################
    % Initialize the best fit with the first member of the first island
    % #####################################################################
    [L_min,id]          = min(Loss);
    ita_best            = ita(:,:,id);
    numeric_best        = numeric(:,id);
    bp_mag_best         = bp_mag(:,:,id);
    L_sta_min           = Loss_sta(:,id);

    % #####################################################################
    % Optimization
    % #####################################################################
    round_all           = 0;
    round_end           = 0;
    round_migration     = 0;
    auto                = 0;
    while round_end     <= 10

        round_all                  = round_all + 1;
        if do_debug, disp(repmat('-',1,100)); end
        if do_debug, disp(num2str(round_all,'Do round %5.0f')); end

        % if round_all <= 30, do_white = 0; else, do_white = 0; end
        bounds              = set_bounds(do_white);

        % -----------------------------------------------------------------
        % Estimate auto-correlation from the current best member
        % -----------------------------------------------------------------
        if do_white == 1
            numeric(1,:)    = auto;
            if do_debug, disp(['  |-> Auto-corr: ',num2str(auto,'%6.2f')]); end
        else
            if do_debug, disp('  Calculate auto-correlation using the best member'); end
            ita2            = ita_best;
            ita2([1 end],:) = true;
            x_in            = x - nanmean(x,1);
            auto_prop       = PHA_func_auto_corr(x_in(:),find(ita2));
            if ~isnan(auto_prop), auto = auto_prop; end
            numeric(1,:)    = auto;
            if do_debug, disp(['  |-> Calculated auto-corr: ',num2str(auto,'%6.2f')]); end
        end

        % -----------------------------------------------------------------
        % Replace the worst with the current best one
        % -----------------------------------------------------------------
        if do_debug, disp('  Replace the worst with the current best several'); end
        Nw                        = 10;
        [~,id_worst]              = maxk(Loss,Nw);
        ita(:,:,id_worst)         = repmat(ita_best,1,1,Nw);
        numeric(:,id_worst)       = repmat(numeric_best,1,Nw);
        Loss(1,id_worst)          = repmat(L_min,1,Nw);
        Loss_sta(:,id_worst)      = repmat(L_sta_min,1,Nw);
        bp_mag(:,:,id_worst)      = repmat(bp_mag_best,1,1,Nw);

        % -----------------------------------------------------------------
        % Apply Migration
        % -----------------------------------------------------------------
        if Ng > 1
            round_migration           = round_migration + 1;
            if round_migration == Mi
                if do_debug, disp('  Apply Migration'); end
                for ct_grp = 1:Ng
                    ids0              = (1:Nmpg) + Nmpg * (ct_grp - 1);
                    ids1              = (1:Nmpg) + Nmpg * ct_grp;
                    ids1(ids1 > Nm)   = ids1(ids1 > Nm) - Nm;
                    [~,I0]            = maxk(Loss(ids0),Mn);
                    [~,I1]            = mink(Loss(ids1),Mn);
    
                    Loss(1,ids0(I0))        = Loss(1,ids1(I1));
                    ita(:,:,ids0(I0))       = ita(:,:,ids1(I1));
                    numeric(1,ids0(I0))     = numeric(1,ids1(I1));
                    Loss_sta(:,ids0(I0))    = Loss_sta(:,ids1(I1));
                    bp_mag(:,:,ids0(I0))    = bp_mag(:,:,ids1(I1));
                end
                round_migration       = 0;
            end
        end

        % -----------------------------------------------------------------
        % Generate descedent
        % -----------------------------------------------------------------
        if do_debug, disp('  Generate descedent'); end
        for ct_grp = 1:Ng
            ids                   = (1:Nmpg) + Nmpg * (ct_grp - 1);

            switch scheme
                case 1  % Use Standard GA algorithm
                 [ita(:,:,ids),numeric(:,ids)] = GA_update_para_standard ...
                    (Loss(1,ids), ita(:,:,ids), numeric(:,ids), stepsize, bounds);

                case 2  % Use Li and Laud method
                 [ita(:,:,ids),numeric(:,ids)] = GA_update_para_li ...
                    (Loss(1,ids), ita(:,:,ids), numeric(:,ids), stepsize, bounds);

                case 3  % Use different parents for each station
                [ita(:,:,ids),numeric(:,ids)] = GA_update_para_chan...
                     (Loss(1,ids), Loss_sta(:,ids), ita(:,:,ids), ...
                     bp_mag(:,:,ids), numeric(:,ids), ...
                     stepsize, bounds, round_all, round_end);
            end
        end
        ita = GA_remove_ones(ita);
        if strcmp(model_type,'decadal_var')
            ita(:,end,:)   = GA_remove_ones(ita(:,end,:),min_trend_length);
        end
        numeric(1,:)    = auto;

        % -----------------------------------------------------------------
        % Calculate the loss for all members in all islands
        % -----------------------------------------------------------------
        if do_debug, disp('  Calculate loss for all decendents'); end
        Loss                       = nan(1,Nm);
        Loss_sta                   = nan(Ns,Nm);
        bp_mag                     = zeros(size(ita));
        for ct_mem = 1:Nm
            [Loss(1,ct_mem), Loss_sta(:,ct_mem), ~, bp_mag(:,:,ct_mem)] = ...
                GA_fit_mu_given_other_para_MVN(x,tim,...
                ita(:,:,ct_mem),numeric(:,ct_mem),dis,model_type);
        end

        % -----------------------------------------------------------------
        % Update if necessary
        % -----------------------------------------------------------------
        if do_add_test  == 1 

            % Test if the combintation of current best fit of each station 
            % leads to a better fitting

            [L_sta_min_curr, I] = min(Loss_sta,[],2);
            ita_best_curr       = ita_best;
            bp_mag_best_curr    = bp_mag_best;
            for ct = 1:Ns
                if (L_sta_min(ct) - L_sta_min_curr(ct)) > 1e-2
                    ita_best_curr(:,ct)     = ita(:,ct,I(ct));
                    bp_mag_best_curr(:,ct)  = bp_mag(:,ct,I(ct));
                end
            end

            [Loss_propose, Loss_sta_curr, ~, bp_mag_curr] = ...
                GA_fit_mu_given_other_para_MVN(x,tim,...
                ita_best_curr,numeric_best,dis,model_type);

            if (L_min - Loss_propose) > 1e-2
                round_end            = 0;
                if (Loss_propose - min(Loss)) > 1e-2
                    if do_debug, disp('  Update using lower global error'); end
                    [L_min,id]       = min(Loss);
                    ita_best         = ita(:,:,id);
                    numeric_best     = numeric(:,id);
                    bp_mag_best      = bp_mag(:,:,id);
                    L_sta_min        = Loss_sta(:,id);
                else
                    if do_debug, disp('  Minimum of each station leads to lower error'); end
                    L_min            = Loss_propose;
                    ita_best         = ita_best_curr;
                    bp_mag_best      = bp_mag_curr;
                    L_sta_min        = Loss_sta_curr;
                end
            else
                if do_debug, disp('  This round of parents does not improve fitting'); end
                round_end            = round_end + 1;
            end

        else
            % Otherwise use standard testing result
            if do_debug, disp('  Update using lower global error'); end
            if (L_min - min(Loss)) > 1e-2
                round_end           = 0;
                [L_min,id]          = min(Loss);
                ita_best            = ita(:,:,id);
                numeric_best        = numeric(:,id);
                bp_mag_best         = bp_mag(:,:,id);
                L_sta_min           = Loss_sta(:,id);
            else
                if do_debug, disp('  This round of parents does not improve fitting'); end
                round_end           = round_end + 1;
            end
        end

        % -----------------------------------------------------------------
        % Output for debugging purposes
        % -----------------------------------------------------------------
        Loss_record(round_all)      = L_min;
        if do_debug, disp(num2str(L_min,  '.....L_min so far %10.2f')); end

        % for debug usage and visulize fitting ----------------------------
        if do_debug
            figure(999);
            for ct = 1:(Ns + strcmp(model_type,'decadal_var'))
                subplot((Ns + strcmp(model_type,'decadal_var')),1,ct); cla; hold on;
                CDF_pcolor(squeeze(ita(:,ct,:)));
                xlim([0 Nt])
                ylim([0 Nm])
            end
            % pause;

            [~, ~, ~, ~, mu_hat] = GA_fit_mu_given_other_para_MVN...
                             (x,tim,ita_best,numeric_best,dis,model_type);
            figure(5); clf; hold on;
            itv = 2;
            plot(x+(1:Ns)*-itv,'r.-','linewi',1);
            plot(mu_hat+(1:Ns)*-itv,'k','LineWidth',3)
        end
    end

    % #####################################################################
    % After optimization, output the best solution
    % #####################################################################
    [~, ~, beta, ~, mu_hat] = GA_fit_mu_given_other_para_MVN...
                             (x,tim,ita_best,numeric_best,dis,model_type);
    ita_best = ita_best';
end

function bounds = set_bounds(do_white)
    if do_white == 1
        bounds          = [-0.0 0.0; 0.1 10; 0.1 10];
    else
        bounds          = [-0.99 0.99; 0.1 10; 0.1 10];
    end
end