% This version has accounted for NaN values ===============================
% all inputs and outputs have the dimensionality of Nt x Ns
% If not, for a single time series, it will be auto matically transposed
function [Loss, Loss_sta, bpm, zscore, mu_hat, mu_bias] = ...
          GA_fit_mu_given_other_para_SNG(x,tim,ita,numeric,model_type)

    alpha          = numeric(1);

    if size(tim,1) == 1,                      tim = tim'; end
    if size(x,1)   == 1,                        x = x';   end
    if size(ita,1) == 1 || size(ita,1) == 2,  ita = ita'; end

    Nt          = size(x,1);
    Ns          = size(x,2);

    % Find design matrix for biases ---------------------------------------
    M           = GA_gen_design_mat(x,ita(:,1));
    n_seg(1)    = size(M,2);

    if strcmp(model_type,'one_trend')
        Ds       = GA_gen_design_mat_trend(tim,ita(:,end)*0);
        n_seg(2) = size(Ds,2);
    end

    if strcmp(model_type,'decadal_var')
        Ds       = GA_gen_design_mat_trend(tim,ita(:,end));
        n_seg(2) = size(Ds,2);
    end
    
    % Difference the data -------------------------------------------------
    k           = tim(2:end)-tim(1:end-1);                           % Ntx1
    scl         = [(1 - alpha^2);  (1-alpha.^2)./(1-alpha.^(2*k))];  % Ntx1
    scl         = sqrt(scl);
    T_dif       = [x(1);  x(2:end) - alpha.^k .* x(1:(end-1))];
    Y           = scl .* T_dif;
    
    n_seg_st    = cumsum([0 n_seg]);
    X           = [M(1,:); M(2:end,:) - alpha.^k.* M(1:(end-1),:)];
    if strcmp(model_type,'decadal_var') || strcmp(model_type,'one_trend')
        temp    = [Ds(1,:); Ds(2:end,:) - alpha.^k.*Ds(1:(end-1),:)];
        X       = [X temp];
    end
    X           = scl .* X;
    
    % Solve the problem ---------------------------------------------------
    beta        = X \ Y;
    
    % Calculate error to be removed ---------------------------------------
    miss_fit    = Y - X*beta;
    err         = mean((miss_fit).^2);            % error of scaled data
    E           = err ./ scl.^2;                  % error of not scaled data
    
    % Calculate the minus 2 log-likelihood as the output ------------------
    Loss        = Nt * log(2*pi) + sum(log(E)) + ...
                                           sum((miss_fit./scl).^2 ./ E, 1);

    % Calculate the loss every X time steps -------------------------------
    seg_length  = 300;
    N_seg       = ceil(Nt / seg_length);
    for ct_seg  = 1:N_seg
        id      = (1:seg_length) + (ct_seg - 1)*seg_length;
        id(id > Nt) = []; 
        Loss_sta(ct_seg,1)   = numel(id) * log(2*pi) + sum(log(E(id))) + ...
                               sum((miss_fit(id)./scl(id)).^2 ./ E(id), 1);
        m_sta(ct_seg,1)      = sum(ita(id,1)~=0,1);
        if strcmp(model_type,'decadal_var')
            m_sta(ct_seg,2)  = sum(ita(id,2)~=0,1);
        end
    end
    
    % Add panelty terms ---------------------------------------------------
    if size(m_sta,2) == 1
        Penalty_sta = (2*m_sta(:,1)) .* log(Nt);
    else
        Penalty_sta = (2*m_sta(:,1) + 2*m_sta(:,2)) .* log(Nt);
    end
    Loss_sta        = Loss_sta + Penalty_sta(:,1);

    if strcmp(model_type,'one_trend')
        Penalty_all = (2*sum(m_sta)+4) .* log(Nt);
    elseif strcmp(model_type,'decadal_var')
        Penalty_all = (2*sum(m_sta(:,1))+2*sum(m_sta(:,2))+4) .* log(Nt);
    elseif strcmp(model_type,'no_slope')
        Penalty_all = (2*sum(m_sta)+3) .* log(Nt);
    end
    Loss            = Loss + Penalty_all;

    % Reconstruct fitted value for biases to be removed -------------------
    mu_bias         = M * beta(n_seg_st(1)+(1:n_seg(1)));
    
    if strcmp(model_type,'decadal_var') || strcmp(model_type,'one_trend')
        mu_common   = Ds * beta(n_seg_st(Ns+1)+(1:n_seg(Ns+1)));
        mu_hat      = mu_bias + mu_common;
    else
        mu_hat      = mu_bias;
    end

    % Calculate the magnitude and z-score of each detected breakpoint -----
    bpm             = zeros(Nt,Ns);
    beta_seg        = beta(n_seg_st(1)+(1:n_seg(1)));
    bpm(ita(:,1),1) = beta_seg(2:end); 
    zscore          = abs(bpm) ./ std(x - mu_hat,[],1,"omitnan");

    if strcmp(model_type,'decadal_var')
        beta_seg    = beta(n_seg_st(Ns+1)+(1:n_seg(Ns+1)));
        beta_mag    = beta_seg(2:end) .* diff([find(ita(:,end)); Nt],[],1) / 2;
        bpm(ita(:,end),Ns+1)    = beta_mag;
        zscore(ita(:,end),Ns+1) = abs(beta_mag') ./ ...
                            mean(std(x - mu_hat,[],1,"omitnan"),"omitnan");

        if 1
            sd   = mean(std(x - mu_hat,[],1,"omitnan"),"omitnan");
            Loss = Loss + sum((beta_seg(2:end) ./ sd * 240).^2);
    
            for ct_seg  = 1:N_seg
                id      = (1:seg_length) + (ct_seg - 1)*seg_length;
                id(id > Nt) = []; 
                Loss_sta(ct_seg,1)   = Loss_sta(ct_seg,1) + ...
                                        sum((zscore(id,2) ./ sd * 240).^2);
            end
        end
    end
end