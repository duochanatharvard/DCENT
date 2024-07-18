function dir = GHCN_IO(input)

    % Home directory ------------------------------------------------------
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

        output   = dirPaths(contains(dirPaths, 'DCLAT'));
        dir      = [output{1},'/'];

    elseif strcmp(input,'code')
        dir = [pwd,'/'];

    elseif strcmp(input,'SATH')
        dir = [GHCN_IO('home'),'SATH_V3/'];

    elseif strcmp(input,'GHCN')
        dir = [GHCN_IO('home'),'GHCNmV4/'];

    elseif strcmp(input,'date')
        dir = '20240415';
    end

    if ~strcmp(input,'date')
        if ~exist(dir,'dir'), mkdir(dir); end
    end
end
