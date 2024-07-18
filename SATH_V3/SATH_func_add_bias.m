function [T_obs, bp_mag] = SATH_func_add_bias(T_true, do_complex, lon)

    if ~exist('do_complex','var'), do_complex = 0; end
    if ~exist('lon','var'),        lon = [];       end

    N_sta    = size(T_true,1);

    T_true   = T_true(:,:);

    if do_complex == 0

        % case 1, random breaks
        bp_mag = generate_random_bps(T_true,3,1,1,size(T_true,2),-0.05,1,[0,0]);

    elseif do_complex == 1

        months = round(normrnd(lon*8-1800,18,size(lon)));
        months(months < 25) = 25;
        months(months > 600-24) = 600 - 24;

        bp_mags  = normrnd(-0.5, 1, size(T_true,1),1);
        bp_mag  = zeros(size(T_true));
        for ct = 1:size(T_true,1)
            bp_mag(ct,months(ct)) = bp_mags(ct);
        end
        bp_mag(isnan(T_true)) = 0;

    elseif do_complex == 2

        % case 2, clustering and sign bias
        [Y_st,Y_ed] = get_Y(1980,1987);
        bp_mag_1 = generate_random_bps(T_true,0.7,0.38,Y_st,Y_ed,0.35,0.7,[0,0]);

        [Y_st,Y_ed] = get_Y(1945,1975);
        bp_mag_2 = generate_random_bps(T_true,0.7,0.38,Y_st,Y_ed,-0.2,0.4,[0,0]);

        [Y_st,Y_ed] = get_Y(1950,2000);
        bp_mag_3 = generate_random_bps(T_true,1,0.3,Y_st,Y_ed,0.8,0.5,[0,1]);

        [Y_st,Y_ed] = get_Y(1901,2000);
        bp_mag_4 = generate_random_bps(T_true,1,0.3,Y_st,Y_ed,0,0.8,[1,1]);

        [Y_st,Y_ed] = get_Y(1901,1950);
        bp_mag_5 = generate_random_bps(T_true,2,0.6,Y_st,Y_ed,0,0.8,[1,0]);

        bp_mag = bp_mag_1 + bp_mag_2 + bp_mag_3 + bp_mag_4 + bp_mag_5;

        for ct = 1:N_sta
            a    = sort(find(bp_mag(ct,:)~=0));
            l    = diff(a,1,2) < 24;
            if nnz(l) > 0
                bp_mag(ct,a(l)) = 0;
            end
        end
    end

    bias    = SATH_func_adj2corr(bp_mag,'forward');
    T_obs   = T_true + bias;

end

% -------------------------------------------------------------------------
function bp_mag = generate_random_bps(T_true,N_mean,N_sd,Y_st,Y_ed,B_mean,B_sd,do_exclude)

    N_sta = size(T_true,1);

    % Find number of breaks in each station
    N_bp    = round(normrnd(N_mean,N_sd,N_sta,1));
    N_bp(N_bp < 0)  = 0;
    N_bp(N_bp > round(2*N_mean)) = round(2*N_mean);

    % Find the timing of break points
    bp_time = false(size(T_true));
    for ct = 1:N_sta

        temp = randperm(Y_ed-Y_st+1);

        if all(do_exclude == [0,0])
            temp(temp<6 | temp > (Y_ed-Y_st+1-5))   = [];
        elseif all(do_exclude == [1,0])
            temp(temp<25 | temp > (Y_ed-Y_st+1-5))  = [];
        elseif all(do_exclude == [0,1])
            temp(temp<6 | temp > (Y_ed-Y_st+1-24))  = [];
        elseif all(do_exclude == [1,1])
            temp(temp<25 | temp > (Y_ed-Y_st+1-24)) = [];
        end

        a    = sort(temp(1:N_bp(ct)));
        l    = diff(a,1,2) < 24;
        a(l) = [];
        bp_time(ct,a+Y_st-1) = true;
    end

    % Find the amplitude of breakpoints
    bp_mag  = normrnd(B_mean, B_sd, size(bp_time));
    bp_mag(bp_time == false) = 0;
    bp_mag(isnan(T_true)) = 0;

end

% -------------------------------------------------------------------------
function [Y_st,Y_ed] = get_Y(yr1,yr2)
    Y_st = (yr1-1901)*12+1;
    Y_ed = (yr2-1900)*12;
end

% -------------------------------------------------------------------------
function corr = SATH_func_adj2corr(adj, mode)
    if strcmp(mode,'forward') % jump -> bias
        adj(isnan(adj)) = 0;
        adj  = [zeros(size(adj,1),1) adj];
        corr = cumsum(adj,2);
        corr = corr(:,1:end-1);
    else                      % jump -> correction
        adj(isnan(adj)) = 0;
        corr = cumsum(fliplr(adj),2);
        corr = corr(:,end:-1:1);
    end
end
