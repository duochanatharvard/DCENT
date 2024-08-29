function ERRSTR_Step_01_count_numbers(yr_list,reso)
    for yr = yr_list
        parfor mon = 1:12
            disp(num2str([yr mon]))
            ERRSTR_Step_01_count_single(yr,mon,reso);
        end
    end
end

% -------------------------------------------------------------------------
function ERRSTR_Step_01_count_single(yr,mon,reso)

    % Load Data used in the SST computation
    [Ds, Dm, Dd] = ERRSTR_func_load_SST_data(yr,mon);

    % Count the number of all and trackable measurements
    [Ns, Ns_track, Ns_track_sub, Ni2s, Ni2s_sub] = count_N(Ds,reso);
    [Nm, Nm_track, Nm_track_sub, Ni2m, Ni2m_sub] = count_N(Dm,reso);
    [Nd, Nd_track, Nd_track_sub, Ni2d, Ni2d_sub] = count_N(Dd,reso);

    file_save = [ERRSTR_OI('SST_Count'),'SST_Count_reso_',num2str(reso),'_',num2str(yr),'_',CDF_num2str(mon,2),'.mat'];
    save(file_save,'Ns','Nm','Nd','Ns_track','Nm_track','Nd_track',...
        'Ns_track_sub','Nm_track_sub','Nd_track_sub',...
        'Ni2s','Ni2m','Ni2d','Ni2s_sub','Ni2m_sub','Ni2d_sub','-V7.3')

end

% -------------------------------------------------------------------------
function [N, N_track, N_track_sub, Ni2, Ni2_sub] = count_N(D,reso)

    N           = zeros(360/reso,180/reso);
    N_track     = zeros(360/reso,180/reso);
    N_track_sub = zeros(360/reso,180/reso);
    Ni2         = zeros(360/reso,180/reso);
    Ni2_sub     = zeros(360/reso,180/reso);

    for ct_x  = 1:(360/reso)
        for ct_y = 1:(180/reso)

            l = D.C0_LON >= (ct_x-1) * reso & D.C0_LON < ct_x * reso & ...
                D.C0_LAT >= (ct_y-1) * reso - 90 & D.C0_LAT < ct_y * reso - 90;
            
            if nnz(l) > 0

                N(ct_x,ct_y)       = nnz(l);

                N_track(ct_x,ct_y) = nnz(any(D.C0_ID(l,2:end) ~= 32,2));
                
                clear('d')
                d = ICOADS_subset(D,l);
                l = any(d.C0_ID(:,2:end) ~= 32,2);
                if nnz(l) > 0
                    d = ICOADS_subset(d,l);
                    if size(d.C0_ID,2) > 30
                        [~,~,J] = unique(d.C0_ID(:,2:end),'rows');
                    else
                        [~,~,J] = unique(d.C0_ID,'rows');
                    end
                    C         = accumarray(J, 1);
                    Ni2(ct_x,ct_y) = nansum(C.^2);
                    C(C>180)  = nan;
                    Ni2_sub(ct_x,ct_y) = nansum(C.^2);
                    N_track_sub(ct_x,ct_y) = nansum(C);
                end
            end
        end
    end
end