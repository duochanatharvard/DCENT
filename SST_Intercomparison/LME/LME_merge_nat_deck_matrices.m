function M = LME_merge_nat_deck_matrices(M_nat,M_dck,L,P)

    % combine different matrices together
    M.X_in = [M_nat.X M_dck.X(:,~L.logic_r_dck)];

    if P.do_hierarchy_random == 1

        if M_nat.do_random
            M.Z_in = M_nat.Z_in;
            M.structure = M_nat.structure;
            ct = numel(M.Z_in);

            if P.do_region == 1
                ct = ct + 1;
                M.logic_region     = M_nat.logic_region;
                M.logic_region_dck = ~L.logic_r_dck_reg(:)' & M_dck.logic_region;
                M.structure{ct}    = 'Isotropic';
                M.Z_in{ct}         = M_dck.Z_region(:,M.logic_region_dck);
                M.reg_id           = M_nat.reg_id;
                M.reg_id_dck       = ct;
                M.region_info      = M_nat.region_info;
                M.region_info_dck  = M_dck.region_info;
            end

            if P.do_decade == 1
                ct = ct + 1;
                M.logic_decade     = M_nat.logic_decade;
                M.logic_decade_dck = ~L.logic_r_dck_dcd(:)' & M_dck.logic_decade;
                M.structure{ct}    = 'Isotropic';
                M.Z_in{ct}         = M_dck.Z_decade(:,M.logic_decade_dck);
                M.dcd_id           = M_nat.dcd_id;
                M.dcd_id_dck       = ct;
                M.decade_info      = M_nat.decade_info;
                M.decade_info_dck  = M_dck.decade_info;
            end

            if P.do_season == 1
                ct = ct + 1;
                M.logic_season     = M_nat.logic_season;
                M.logic_season_dck = ~L.logic_r_dck_sea(:)' & M_dck.logic_season;
                M.structure{ct}    = 'Isotropic';
                M.Z_in{ct}         = M_dck.Z_season(:,M.logic_season_dck);
                M.sea_id           = M_nat.sea_id;
                M.sea_id_dck       = ct;
                M.season_info      = M_nat.season_info;
                M.season_info_dck  = M_dck.season_info;
            end
        end
        
        M.Y = M_nat.Y;
        M.W = M_nat.W;
        M.do_random = M_nat.do_random;

        M.logic_fixed = ~L.logic_r_dck;

    else

        M.X_in = [M_nat.X M_dck.X(:,~L.logic_r_dck)];

        if M_dck.do_random
            M.Z_in = M_dck.Z_in;
            M.structure = M_dck.structure;

            if P.do_region == 1
                M.logic_region_dck = M_dck.logic_region;
                M.reg_id_dck       = M_nat.reg_id;
                M.region_info_dck  = M_dck.region_info;
            end

            if P.do_decade == 1
                M.logic_decade_dck = M_dck.logic_decade;
                M.dcd_id_dck       = M_dck.dcd_id;
                M.decade_info_dck  = M_dck.decade_info;
            end

            if P.do_season == 1
                M.logic_season_dck = M_dck.logic_season;
                M.sea_id_dck       = M_nat.sea_id;
                M.season_info_dck  = M_dck.season_info;
            end
        end

        M.Y = M_dck.Y;
        M.W = M_dck.W;
        M.do_random = M_dck.do_random;
        M.logic_fixed = ~L.logic_r_dck;
    end
end
