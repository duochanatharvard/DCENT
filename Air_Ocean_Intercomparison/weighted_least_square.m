function  [beta, beta_sample, X,Y,W,Y_hat] = weighted_least_square(x,y,w,add_mu)

    if ~exist('add_mu','var'), add_mu = 1; end

    l = all(~isnan([x(:) y(:) w(:)]),2);

    if nnz(l) > 10

        clear('X','Y','W')
        if add_mu == 1
            X = [x(l) ones(nnz(l),1)];
        else
            X = x(l);
        end
        % X = [ones(nnz(l),1)];
        Y = y(l);
        W = diag(w(l));

        XWX_inv = inv(X' * W * X);

        beta    = XWX_inv * X' * W * Y;
        Y_hat   = X * beta;
        rsdul   = CDC_var(Y_hat - Y);

        beta_cov = XWX_inv * X' * W * W * X * XWX_inv * rsdul;
        beta_cov = (beta_cov + beta_cov') /2;

        clear('beta_sample')
        for ct2 = 1:300
            beta_sample(:,ct2) = mvnrnd(beta,beta_cov);
        end
    else
        beta = nan(2,1);
        beta_sample = nan(2,10);
        X    = [];
        Y    = [];
        W    = [];
        Y_hat= [];
    end
end
