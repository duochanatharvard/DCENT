% Output / Input managements

function output = LME_OI(input)

    if strcmp(input,'home') || strcmp(input,'read_raw') || strcmp(input,'diurnal')

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

        if strcmp(input,'home')
            output   = dirPaths(contains(dirPaths, 'GWSST'));
        elseif strcmp(input,'read_raw')
            output   = dirPaths(contains(dirPaths, 'ICOADS'));
        end
        output   = [output{1},'/'];

    elseif strcmp(input,'diurnal')
        % home directory for diurnal signals
        load('LME_directories.mat','dir_home_diurnal')
        output = dir_home_diurnal;
        % output = '/Users/duochan/Data/DIURNAL_2019/';

    elseif strcmp(input,'ICOADS3')
        output = [LME_OI('read_raw'),'ICOADS_QCed/'];

    elseif strcmp(input,'kent_track')
        output = [LME_OI('read_raw'),'ICOADS_Tracks_Kent/'];

    elseif strcmp(input,'ship_diurnal')
        output = [LME_OI('diurnal'),'Step_04_Ship_Signal/'];

    elseif strcmp(input,'all_pairs')
        output = [LME_OI('home'),'Step_01_All_Pairs/'];

    elseif strcmp(input,'screen_pairs')
        output = [LME_OI('home'),'Step_02_Screen_Pairs/'];

    elseif strcmp(input,'bin_pairs')
        output = [LME_OI('home'),'Step_03_Binned_Pairs/'];

    elseif strcmp(input,'LME_output')
        output = [LME_OI('home'),'Step_04_LME_output/'];

    elseif strcmp(input,'idv_corr')
        output = [LME_OI('home'),'Step_05_Idv_Corr/'];

    elseif strcmp(input,'rnd_corr')
        output = [LME_OI('home'),'Step_06_Rnd_Corr/'];

    elseif strcmp(input,'Mis')
        output = [LME_OI('home'),'Miscellaneous/'];

    end

    if ~exist(output,'dir'), mkdir(output); end
end
