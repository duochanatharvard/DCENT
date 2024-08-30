% Output / Input managements

function output = ERRSTR_OI(input)

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
            output   = dirPaths(contains(dirPaths, 'ERRSTR'));
        elseif strcmp(input,'read_raw')
            output   = dirPaths(contains(dirPaths, 'ICOADS'));
        end
        output   = [output{1},'/'];

    elseif strcmp(input,'SST_Count')
        output = [ERRSTR_OI('home'),'SST_Count/'];

    elseif strcmp(input,'Infer_ab')
        output = [ERRSTR_OI('home'),'Infer_ab/'];

    elseif strcmp(input,'Covariance')
        output = [ERRSTR_OI('home'),'Covariance/'];

    elseif strcmp(input,'Uncertainty')
        output = [ERRSTR_OI('home'),'Uncertainty/'];

    elseif strcmp(input,'Uncertainty_nc')
        output = [ERRSTR_OI('home'),'Uncertainty_nc/'];        
    end

    if ~exist(output,'dir'), mkdir(output); end
end
