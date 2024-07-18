% Input / Output management
function output = ICOADS_NC_OI(input)

    if strcmp(input,'home')

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
        output   = dirPaths(contains(dirPaths, 'ICOADS'));
        output   = [output{1},'/'];

    elseif  strcmp(input,'nc_files')
        output = [ICOADS_NC_OI('home'),'ICOADS_01_nc_files/'];

    elseif  strcmp(input,'pre_QC')
        output = [ICOADS_NC_OI('home'),'ICOADS_02_pre_QC/'];

    elseif  strcmp(input,'WM')
        output = [ICOADS_NC_OI('home'),'ICOADS_03_WM/'];

    elseif  strcmp(input,'QCed')
        output = [ICOADS_NC_OI('home'),'ICOADS_QCed/'];

    elseif  strcmp(input,'Kent_load')
        output = [ICOADS_NC_OI('home'),'Ship_track_from_Liz/'];
        
    elseif  strcmp(input,'Kent_save')
        output = [ICOADS_NC_OI('home'),'ICOADS_Tracks_Kent/'];

    elseif  strcmp(input,'Mis')
        output = [ICOADS_NC_OI('home'),'ICOADS_Mis/'];
    end
 
    if ~exist(output,'dir'), mkdir(output); end
end
