function LME_lme_bin_2021_pattern_sum(P)

    clear('BINNED')
    for ct = 1:100
        try
            P.bin_sub_id = ct;
            if P.do_combined_analysis == 1
                file_save  = LME_output_files('SST_Pairs_binned_pattern_dedup_sub',P);
            else
                file_save  = LME_output_files('SST_Pairs_binned_pattern_sub',P);
            end

            clear('data')
            data = load(file_save,'BINNED','W_X');
            if ct == 1
                grp    = data.BINNED.Group_uni;
                W_X    = data.W_X;
            end
            data.BINNED = rmfield(data.BINNED,'Group_uni');

            if ct == 1
                BINNED = data.BINNED;
            else
                BINNED = ICOADS_combine(BINNED,data.BINNED);
            end
        catch
            disp(['Sub ', num2str(ct),' does not exist...'])
        end
    end

    BINNED.Group_uni = grp;
    if P.do_combined_analysis == 1
        file_save  = LME_output_files('SST_Pairs_binned_pattern_dedup',P);
    else
        file_save  = LME_output_files('SST_Pairs_binned_pattern',P);
    end
    save(file_save,'BINNED','W_X','-v7.3')
end
