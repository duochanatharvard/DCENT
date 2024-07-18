% This version has accounted for NaN values ===============================
% all inputs and outputs have the dimensionality of Nt x Ns
function [Loss, Loss_sta, bpm, zscore, mu_hat, mu_bias] = ...
          GA_fit_mu_given_other_para_MVN(x,tim,ita,numeric,dis,model_type)

    alpha       = numeric(1);
    dl          = numeric(2);
    sigma2      = numeric(3);

    if size(tim,1) == 1, tim = tim'; end

    Nt          = size(x,1);
    Ns          = size(x,2);

    % Find design matrix for biases ---------------------------------------
    for ct      = 1:Ns  
        temp    = GA_gen_design_mat(x(:,ct)',ita(:,ct)');
        M{ct}   = temp;
        n_seg(ct) = size(M{ct},2);
    end

    if strcmp(model_type,'one_trend')
        Ds      = GA_gen_design_mat_trend(tim,ita(:,end)*0);
        ct      = ct + 1;
        n_seg(ct) = size(Ds,2);
    end

    if strcmp(model_type,'decadal_var')
        Ds      = GA_gen_design_mat_trend(tim,ita(:,end));
        ct      = ct + 1;
        n_seg(ct) = size(Ds,2);
    end
    
    % Find covariance matrix ----------------------------------------------
    cov_mat     = sigma2 * exp(-dis / dl);
    cov_mat     = (cov_mat + cov_mat') / 2;
    
    % Difference the data -------------------------------------------------
    k           = tim(2:end)-tim(1:end-1);                           % Ntx1
    scl         = [(1 - alpha^2);  (1-alpha.^2)./(1-alpha.^(2*k))];  % Ntx1
    T_dif       = [x(1,:);  x(2:end,:) - alpha.^k .* x(1:(end-1),:)];
    Y           = scl .* T_dif;
    Y           = Y';
    Y           = Y(:);
    
    n_seg_st    = cumsum([0 n_seg]);
    X           = zeros(Ns*Nt,sum(n_seg));
    for ct      = 1:Ns
        l_loc   = ((1:Nt)-1)*Ns + ct;
        l_x     = n_seg_st(ct)+(1:n_seg(ct));
        temp    = [M{ct}(1,:); M{ct}(2:end,:) - alpha.^k.*M{ct}(1:(end-1),:)];
        temp    = scl .* temp;
        X(l_loc,l_x) = temp;
        if strcmp(model_type,'decadal_var') || strcmp(model_type,'one_trend')
            l_x     = n_seg_st(Ns+1)+(1:n_seg(Ns+1));
            temp    = [Ds(1,:); Ds(2:end,:) - alpha.^k.*Ds(1:(end-1),:)];
            temp    = scl .* temp;
            X(l_loc,l_x) = temp;
        end
    end
    
    % Normalize the data --------------------------------------------------
    clear('SY','SX')
    S           = chol(cov_mat, 'lower') \ eye(Ns);
    SY          = zeros(Ns*Nt,1);
    SX          = zeros(Ns*Nt,sum(n_seg));
    for ct      = 1:Nt
        l_loc   = (1:Ns) + Ns * (ct-1);
        temp    = S * Y(l_loc);
        SY(l_loc,1) = temp;
        temp    = S * X(l_loc,:);
        SX(l_loc,:) = temp;
    end
    
    beta        = SX \ SY;
    
    % Calculate error to be removed ---------------------------------------
    miss_fit    = SY - SX*beta;
    err         = mean((miss_fit).^2);              % error of Z
    E           = repmat(err./scl,1,Ns);
    
    % Calculate the minus 2 log-likelihood as the output ------------------
    Loss_sta    = Nt * log(2*pi) + sum(log(E),1) + ...
                            sum((reshape(miss_fit,Nt,Ns)./scl).^2 ./ E, 1);

    Loss        = sum(Loss_sta,2);
    
    % Add panelty terms ---------------------------------------------------
    m_sta       = nansum(ita~=0,1);
    if strcmp(model_type,'one_trend')
        Penalty_sta = (2*m_sta+4) .* log(Nt);
    elseif strcmp(model_type,'decadal_var')
        Penalty_sta = (2*m_sta(1,1:Ns)+m_sta(1,end)+2) .* log(Nt);
    elseif strcmp(model_type,'no_slope')
        Penalty_sta = (2*m_sta+3) .* log(Nt);
    end
    Loss_sta    = Loss_sta + Penalty_sta(1,1:Ns);
    Loss_sta    = Loss_sta(:);

    Loss        = Loss + sum(Penalty_sta,2);

    % Reconstruct fitted value for biases to be removed -------------------
    mu_bias     = zeros(Nt,Ns);
    for ct      = 1:Ns  
        mu_bias(:,ct) = M{ct} * beta(n_seg_st(ct)+(1:n_seg(ct)));
    end
    
    if strcmp(model_type,'decadal_var') || strcmp(model_type,'one_trend')
        mu_common = Ds * beta(n_seg_st(Ns+1)+(1:n_seg(Ns+1)));
        mu_hat    = mu_bias + mu_common;
    else
        mu_hat    = mu_bias;
    end

    % Calculate the magnitude and z-score of each detected breakpoint -----
    bpm         = zeros(Nt,Ns);
    for ct      = 1:Ns
        beta_seg  = beta(n_seg_st(ct)+(1:n_seg(ct)));
        bpm(ita(:,ct),ct) = beta_seg(2:end); 
    end
    zscore       = abs(bpm) ./ std(x - mu_hat,[],1,"omitnan");

    if strcmp(model_type,'decadal_var')
        beta_seg = beta(n_seg_st(Ns+1)+(1:n_seg(Ns+1)));
        beta_mag = beta_seg(2:end) .* diff([find(ita(:,end)); Nt],[] ,1) / 2;
        bpm(ita(:,end),Ns+1)    = beta_mag;
        zscore(ita(:,end),Ns+1) = abs(beta_mag') ./ ...
                            mean(std(x - mu_hat,[],1,"omitnan"),"omitnan");
    end
end