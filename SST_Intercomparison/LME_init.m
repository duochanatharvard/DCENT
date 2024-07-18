% LME_init(dir_data)
% Input dir_data is the directory for storing data
%    default is under the code directory.

function LME_init(env)

    % ********************************************
    % Make directories
    % ********************************************
    dir_code = [pwd,'/'];
    % if ~exist('dir_data','var'), dir_data = [dir_code,'DATA/']; end
    % if dir_data(end)~= '/',  dir_data = [dir_data,'/']; end
    % mkdir(dir_data)
    % cd(dir_data)

    if env == 0,
        dir_data = '/n/home10/dchan/holy_kuang/';
    else
        dir_data = '/Volumes/Untitled/01_Research/03_DATA/';
    end

    cd(dir_code)
    dir_home_ICOADS3 = [dir_data,'ICOADS3/'];
    dir_home_LME = [dir_data,'LME_intercomparison/'];
    dir_home_diurnal = [dir_data,'DIURNAL_2019/'];
    save('LME_directories.mat','dir_home_ICOADS3',...
         'dir_home_diurnal','dir_home_LME','dir_data','dir_code','-v7.3');

end
