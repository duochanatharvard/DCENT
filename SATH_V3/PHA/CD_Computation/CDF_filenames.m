% file_name = CDF_filenames(dir_load,file_type,keyword)

function file_name = CDF_filenames(dir_load,file_type,keyword)
    
    dir = pwd;
    cd(dir_load);

    command = 'ls -1';
    
    if exist('file_type','var') && ~exist('keyword','var')
        command = [command,' *.',file_type];
    elseif exist('keyword','var') && isempty(file_type)
        command = [command,' *',keyword,'*'];
    elseif exist('keyword','var') && exist('file_type','var')
        command = [command,' *',keyword,'*.',file_type];
    end
    
    [~,a] = system(command);
    file_list = [0 find(a == 10)];
    for i = 1:numel(file_list)-1
        file_name{i} = a(file_list(i)+1:file_list(i+1)-1);
    end
    
    cd(dir)
end
    