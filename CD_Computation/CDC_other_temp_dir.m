function dir = CDC_other_temp_dir

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

    output   = dirPaths(contains(dirPaths, 'others'));
    output   = [output{1},'/'];

    dir      = output;
end

