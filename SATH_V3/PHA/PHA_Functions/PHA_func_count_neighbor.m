function [N_nb, h] = PHA_func_count_neighbor(T_in, NET_adj)

    Ns              = size(T_in(:,:),1);
    Nt              = size(T_in(:,:),2);
    N_nb            = nan(Ns,Nt);
    sta_list = 1:Ns;
    for ct_sta      = sta_list
        if rem(ct_sta,5000) == 0,  disp(ct_sta); end
        l                               = NET_adj(ct_sta,:); l(isnan(l)) = [];
        if nnz(l)
            T                           = T_in(l,:,end);
            N_nb(ct_sta,:)              = sum(~isnan(T(2:end,:)),1);
            N_nb(ct_sta,isnan(T(1,:)))  = nan;
        end
    end

    for ct = 1:Nt
        temp = N_nb(:,ct);
        temp(isnan(temp)) = [];
        h(:,ct) = hist(temp,0:100);
    end
end