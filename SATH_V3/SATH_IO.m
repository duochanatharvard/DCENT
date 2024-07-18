function dir = SATH_IO(case_name,input_key,id,PHA_version,sub_id)

    if strcmp(input_key,'home')

        dirListFile1 = 'dir_list.txt';
        dirListFile2 = '../dir_list.txt';

        % Check which file exists
        if exist(dirListFile1, 'file') == 2
            % File exists in the current directory
            dirListFile = dirListFile1;
        elseif exist(dirListFile2, 'file') == 2
            % File exists in the parent directory
            dirListFile = dirListFile2;
        else
            error('Neither dir_list.txt nor ../dir_list.txt was found.');
        end

        fileID   = fopen(dirListFile, 'r');
        dirPaths = textscan(fileID, '%s', 'Delimiter', '\n');
        fclose(fileID);

        dirPaths = dirPaths{1};

        output   = dirPaths(contains(dirPaths, 'DCLAT'));
        dir      = [output{1},'/'];

        is_dir  = 1;

    % ---------------------------------------------------------------------
    elseif strcmp(input_key,'dir_member')
        dir     = [SATH_IO(case_name,'home',id),case_name,...
                            '/Member_',num2str(id),'/'];
        is_dir  = 1;

    elseif strcmp(input_key,'dir_initial')
        dir     = [SATH_IO(case_name,'home',id),case_name,'/Initial_BP/'];
        is_dir  = 1;

    elseif strcmp(input_key,'dir_raw_data')

        if ~strcmp(case_name,'GHCN')

            dir_syn = '/n/holyscratch01/huybers_lab/dchan/SATH_V2/Synthetic_data/';

            md_id   = str2double(case_name((find(case_name == '_')+1):end));
            if strcmp(case_name(1:4),'CMIP')
                dir = [dir_syn,'C',num2str(md_id),'S1/'];
            elseif strcmp(case_name(1:3),'MGP')
                dir = [dir_syn,'M',num2str(md_id),'S1/'];
            end
        else
            dir = [SATH_IO('GHCN','home'),'GHCNmV4/'];
        end
        is_dir  = 0;

    % ---------------------------------------------------------------------
    elseif strcmp(input_key,'raw_data')

        if ~strcmp(case_name,'GHCN') && ~strcmp(case_name,'debug')
            dir              = [SATH_IO(case_name,'dir_raw_data',id),'Data.mat'];
            disp(dir)
            load(dir,'D');
            Ns               = size(D.T,1);
            D.Lon(D.Lon>180) = D.Lon(D.Lon>180) - 360;
            D.yr             = 1970:2019;
            a                = num2str(D.Lon,'%6.2f');
            b                = num2str(D.Lat,'%6.2f');
            for ct = 1:Ns
                D.Lon(ct)    = str2double(a(ct,:));
                D.Lat(ct)    = str2double(b(ct,:));
            end
            dir              = D;

        elseif strcmp(case_name,'debug')
            %%
            clear('D')
            rng(1);
            Ns               = 20;
            Nt               = 600;
            D.T_t            = normrnd(0,5,1,Nt) + normrnd(0,1,Ns,Nt);
            [D.T, bp_mag]    = SATH_func_add_bias(D.T_t,0);
            D.yr             = 1969 + (1: (Nt/12));
            for ct = 1:Ns
                for ct2 = 1:600
                    D.T(ct,ct2) = str2double(num2str(D.T(ct,ct2),'%6.2f'));
                end
            end
            D.T              = reshape(D.T,Ns,12,Nt/12);
            D.Lon            = normrnd(-86.89,1,Ns,1);
            D.Lat            = normrnd(33.5,1,Ns,1);
            D.Lat(1:2)       = [34.26; 33.29];
            D.Lon(1:2)       = [-87.18; -86.34];
            D.Lon(D.Lon>180) = D.Lon(D.Lon>180) - 360;
            a                = num2str(D.Lon,'%6.2f');
            b                = num2str(D.Lat,'%6.2f');
            for ct = 1:Ns
                D.Lon(ct)    = str2double(a(ct,:));
                D.Lat(ct)    = str2double(b(ct,:));
            end
            D.Sta            = [repmat('S',Ns,1) num2str((1:Ns)') repmat(' ',Ns,8)];
            D.Sta(D.Sta==' ') = '0';
            D.UID            = (1:Ns)';
            dir              = D;

        elseif strcmp(case_name,'GHCN')

            dir              = [SATH_IO(case_name,'dir_raw_data',id),...
                               'ghcnm.tavg.v4.0.1.',GHCN_IO('date'),'.qcu.mat'];
            disp(dir)
            D                = load(dir);
            D.T              = permute(D.T,[3 1 2]);
            D.QC             = permute(D.QC,[3 1 2]);
            D.T(D.QC~=32)    = nan;
            Ns               = size(D.T,1);
            D.Lon(D.Lon>180) = D.Lon(D.Lon>180) - 360;
            D.yr             = 1699 + [1:Ns];
            a                = num2str(D.Lon,'%6.2f');
            b                = num2str(D.Lat,'%6.2f');
            for ct = 1:Ns
                D.Lon(ct)    = str2double(a(ct,:));
                D.Lat(ct)    = str2double(b(ct,:));
            end
            D.UID            = (1:Ns)';
            dir              = D;
            
        end

        is_dir  = 0;

    elseif strcmp(input_key,'net')
        dir     = [SATH_IO(case_name,'dir_member',id),'NET_',PHA_version,'.mat'];
        is_dir  = 0;

    elseif strcmp(input_key,'initial')
        dir     = [SATH_IO(case_name,'dir_initial',id),...
                            'BP_sub_',num2str(id),'_',PHA_version,'.mat'];   
        is_dir  = 0;

    elseif strcmp(input_key,'dir_initial_R2')
        dir     = [SATH_IO(case_name,'dir_member',id),'Round2/'];   
        is_dir  = 1;

    elseif strcmp(input_key,'initial_R2')
        dir     = [SATH_IO(case_name,'dir_initial_R2',id),...
                            'BP_sub_',num2str(sub_id),'_',PHA_version,'.mat'];   
        is_dir  = 0;

    elseif strcmp(input_key,'attribute')
        dir     = [SATH_IO(case_name,'dir_member',id),'Attributed_',PHA_version,'.mat'];
        is_dir  = 0;

    elseif strcmp(input_key,'combined')
        dir     = [SATH_IO(case_name,'dir_member',id),'Combined_',PHA_version,'.mat'];
        is_dir  = 0;

    elseif strcmp(input_key,'result')
        dir     = [SATH_IO(case_name,'dir_member',id),'Result_',PHA_version,'.mat'];
        is_dir  = 0;

    elseif strcmp(input_key,'result_R2')
        dir     = [SATH_IO(case_name,'dir_member',id),'Result_R2_',PHA_version,'.mat'];
        is_dir  = 0;

    elseif strcmp(input_key,'result_R3')
       dir     = [SATH_IO(case_name,'dir_member',id),'Result_R3_',PHA_version,'.mat'];
        is_dir  = 0;

    elseif strcmp(input_key,'result_itr')
        dir     = [SATH_IO(case_name,'dir_member',id),'Result_itr_',PHA_version,'.mat'];
        is_dir  = 0;

    elseif strcmp(input_key,'result_nc')
        dir     = [SATH_IO(case_name,'dir_member',id),'Result_',PHA_version,'.nc'];
        is_dir  = 0;

    end

    if is_dir == 1
        if ~exist(dir,'dir'), mkdir(dir);  end
    end

end
