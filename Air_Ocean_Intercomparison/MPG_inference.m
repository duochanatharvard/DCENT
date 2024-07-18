function [field,field_rnd] = MPG_inference(temp,Sigma)

    Nx          = size(temp,1);
    Ny          = size(temp,2);
    l_i         = 1:(Nx * Ny);                % location of inference
    l_o         = (Nx * Ny +1):size(Sigma,1); % location of observations
    S11         = Sigma(l_i, l_i);
    S12         = Sigma(l_i, l_o);
    S21         = Sigma(l_o, l_i);
    S22         = Sigma(l_o, l_o);
    
    a           = temp(~isnan(temp));
    S22_inv     = inv(S22);
    mu          = S12 * S22_inv * a;
    sigma       = S11 - S12 * S22_inv * S21;
    
    clear('field','field_rnd')
    field       = reshape(mu,72,36);
    field_rnd   = reshape(mvnrnd(mu, sigma, 1)',72,36);
end