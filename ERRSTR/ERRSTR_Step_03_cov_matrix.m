function ERRSTR_Step_03_cov_matrix(yr_list,reso)
    for yr = yr_list
        for mon = 1:12
            disp(num2str([yr mon]))
            ERRSTR_Step_03_cov_matrix_single(yr,mon,reso);
        end
    end
end

% -------------------------------------------------------------------------
function ERRSTR_Step_03_cov_matrix_single(yr,mon,reso)

    % Load Data used in the SST computation
    [Ds, Dm, Dd] = ERRSTR_func_load_SST_data(yr,mon);

    [~,Cs2,~] = get_cov_pq(Ds,reso);
    [~,Cm2,~] = get_cov_pq(Dm,reso);
    [~,Cd2,~] = get_cov_pq(Dd,reso);

    file_save = [ERRSTR_OI('Covariance'),'Covariance_reso_',num2str(reso),'_',num2str(yr),'_',CDF_num2str(mon,2),'.mat'];
    save(file_save,'Cs2','Cm2','Cd2','-v7.3');

end

% -------------------------------------------------------------------------
function [C,C2,N] = get_cov_pq(D,reso)

    D.x   = discretize(D.C0_LON,0:reso:360);
    D.y   = discretize(D.C0_LAT,-90:reso:90);
    D.ind = sub2ind([360/reso, 180/reso], D.x, D.y);

    if size(D.C0_ID,2) > 30
        [uni,~,J] = unique(D.C0_ID(:,2:end),'rows');
    else
        [uni,~,J] = unique(D.C0_ID,'rows');
    end

    % Accumulate each tracked ship/buoy -----------------------------------
    C = sparse(360/reso*180/reso,360/reso*180/reso);

    for ct = 1:size(uni,1)
        if rem(ct,300) == 0, disp(num2str(ct));  end
        if any(uni(ct,2:end) ~= 32)
            l = J == ct;
            d = ICOADS_subset(D,l);
            [uni_id,~,J_id] = unique(d.ind);
            n               = accumarray(J_id, 1);
            temp            = n.*n';
            C_ind           = sub2ind([360/reso*180/reso  360/reso*180/reso], ...
                               repmat(uni_id,1,numel(uni_id)), repmat(uni_id,1,numel(uni_id))');
            C(C_ind)        = C(C_ind) + temp;
        end
    end

    % Divide by the number of measurements in corresponding grid boxes ----
    [uni_id,~,J] = unique(D.ind);
    temp = accumarray(J, 1);
    N    = zeros(360/reso, 180/reso);
    N(uni_id) = temp;

    [row_ind, col_ind, val] = find(C);
    Np = N(row_ind);
    Nq = N(col_ind);
    val2 = val ./ Np ./ Nq;

    C2 = sparse(row_ind,col_ind,val2,360/reso*180/reso,360/reso*180/reso);

end