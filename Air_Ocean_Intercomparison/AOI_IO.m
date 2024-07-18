function dir = AOI_IO(input,P)
        
    if strcmp(input,'LME_SST')  
        dir = [find_home('GWSST'),'/Step_06_Rnd_Corr/'];

    elseif strcmp(input,'data')
        dir = SATH_IO('GHCN','dir_member',P.mem_id);

    elseif strcmp(input,'ChanT')
        dir = [find_home('DCENT'),'/'];
    end
    % if ~exist(dir,'dir'),       mkdir(dir);   end
end

function output = find_home(name)

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

    output   = dirPaths(contains(dirPaths, name));
    if strcmp(name,'DCENT')
        output = output{4};
    else
        output = output{1};
    end
end
