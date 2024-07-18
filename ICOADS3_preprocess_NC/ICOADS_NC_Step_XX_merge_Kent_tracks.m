% sbatch --account=huybers_lab  -J ICOADS_nc_preprocess  -t 10080 -p huce_intel,huce_cascade -n 1  --mem-per-cpu=20000  --array=1-172  -o err --wrap='matlab -nosplash -nodesktop -nodisplay -r "yr=$SLURM_ARRAY_TASK_ID+1849;  for mon = 1:12,  ICOADS_NC_Step_XX_merge_Kent_tracks(yr,mon); end;quit;">>log'

function ICOADS_NC_Step_XX_merge_Kent_tracks(yr,mon)

    % ************************************************************************
    % Load file from Chan
    % *************************************************************************
    disp('Reading processed ICOADS3.0/1 Data ...')
    Chan.C98_UID     = ICOADS_NC_function_read(yr,mon,'UID');
    Chan.C0_HR       = ICOADS_NC_function_read(yr,mon,'HR');
    Chan.C0_DY       = ICOADS_NC_function_read(yr,mon,'DY');
    Chan.C1_DCK      = ICOADS_NC_function_read(yr,mon,'DCK');
    Chan.C1_SID      = ICOADS_NC_function_read(yr,mon,'SID');
    Chan.C0_ID       = ICOADS_NC_function_read(yr,mon,'ID');

    % Chan = load(file_load_Chan,'C0_DY','C0_HR','C98_UID','C1_DCK','C1_SID','C0_ID');

    % ************************************************************************
    % Load file from Kent
    % *************************************************************************
    disp('Reading Kent Data ...')
    
    dir_load_Kent = ICOADS_NC_OI('Kent_load');
    file_load_Kent = [dir_load_Kent,num2str(yr),'.',num2str(mon),'.txt'];
    fid=fopen(file_load_Kent,'r');
    disp([file_load_Kent ,' is started!']);
    words=fscanf(fid,'%c',10000000000000);
    fclose(fid);

    num = [0 find(words == 10)];
    clear('items')
    for i = 1:max(size(num))-1
        items{i} = words(num(i)+1:num(i+1)-1);
    end
    clear('words')

    % ************************************************************************
    % Convert Kent into Chan format
    % *************************************************************************
    disp('Converting Kent Data ...')
    clear('Kent')
    for ct = 2:numel(items)

        temp = items{ct};
        input = temp(1:6);
        input = input - '0';
   	    input(input>9) = input(input>9)-7;
        Kent.C98_UID(ct-1,1) = input(1)*36^5 + input(2)*36^4 + input(3)*36^3 + ...
        input(4)*36^2 + input(5)*36 + input(6);
        clear('list','id_temp')
        list              = find(temp == ';');
        Kent.C0_YR(ct-1,1)  = str2num( temp( list(1)+1 : list(2)-1 ) );
        Kent.C0_MO(ct-1,1)  = str2num( temp( list(2)+1 : list(3)-1 ) );
        Kent.C0_DY(ct-1,1)  = str2num( temp( list(3)+1 : list(4)-1 ) );
        Kent.C0_HR(ct-1,1)  = str2num( temp( list(4)+1 : list(5)-1 ) );   
        Kent.C1_DCK(ct-1,1) = str2num( temp( list(5)+1 : list(6)-1 ) );   
        Kent.C1_SID(ct-1,1) = str2num( temp( list(6)+1 : list(7)-1 ) ); 
        id_temp           = repmat(' ',1,30);
        n                 = list(8) - list(7) - 2;
        id_temp(1:n)      = temp( list(7)+2 : list(8)-1 );
        Kent.C0_ID(ct-1,1:30) = id_temp;
        Kent.C0_ID_F(ct-1,1)    = str2num(temp(list(8)+1 : end));
    end

    % ************************************************************************
    % Merging two data sources
    % *************************************************************************
    disp('Merging Kent Data ...')
    [~,pst_Kent] = ismember(Chan.C98_UID,Kent.C98_UID);
    pst_Chan = find(pst_Kent ~= 0);
    pst_Kent(pst_Kent == 0) = [];
    clear('C0_YR','C0_MO','C0_DY','C0_HR','C1_DCK',...
          'C1_SID','C0_ID','C0_ID_F','C98_UID')
%     C0_YR   = nan(numel(Chan.C0_DY),1);
%     C0_MO   = nan(numel(Chan.C0_DY),1);
    C0_DY   = nan(numel(Chan.C0_DY),1);
    C0_HR   = nan(numel(Chan.C0_HR),1);
    C1_SID  = nan(numel(Chan.C1_SID),1);
    C1_DCK  = nan(numel(Chan.C1_DCK),1);
    C0_ID_K = char(ones(size(Chan.C0_ID,1),30)*32);
    C0_ID_F = nan(numel(Chan.C0_DY),1);
    C98_UID = nan(numel(Chan.C98_UID),1);
    
%     C0_YR(pst_Chan)     = Kent.C0_YR(pst_Kent);
%     C0_MO(pst_Chan)     = Kent.C0_MO(pst_Kent);
    C0_DY(pst_Chan)     = Kent.C0_DY(pst_Kent);
    C0_HR(pst_Chan)     = Kent.C0_HR(pst_Kent);
    C1_DCK(pst_Chan)    = Kent.C1_DCK(pst_Kent);
    C1_SID(pst_Chan)    = Kent.C1_SID(pst_Kent);
    C0_ID_K(pst_Chan,:) = Kent.C0_ID(pst_Kent,:);
    C0_ID_F(pst_Chan)   = Kent.C0_ID_F(pst_Kent);
    C98_UID(pst_Chan)   = Kent.C98_UID(pst_Kent);

    % ************************************************************************
    % Check if data from the two sources match up
    % *************************************************************************
    disp('Checking Merged Data ...')
    clear('logic_check')
    logic_check(1) = nnz(C0_DY   == Chan.C0_DY)  == numel(Kent.C0_YR);
    temp = Chan.C0_HR; temp(isnan(temp)) = 0;
    logic_check(2) = nnz(C0_HR   == temp) == numel(Kent.C0_YR);
    logic_check(3) = nnz(C1_DCK  == Chan.C1_DCK)  == numel(Kent.C0_YR);
    logic_check(4) = nnz(C1_SID  == Chan.C1_SID)  == numel(Kent.C0_YR);
    logic_check(5) = nnz(C98_UID == Chan.C98_UID) == numel(Kent.C98_UID);

    % ************************************************************************
    % Save files
    % *************************************************************************
    disp('Saving Data ...')
    ICOADS_version = ICOADS_NC_version(yr);
    cmon = '00';  cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    dir_save = ICOADS_NC_OI('Kent_save');
    file_save = [dir_save,'ICOADS_R',ICOADS_version,'_',num2str(yr),'-',cmon,'_Tracks_Kent.nc'];
    ICOADS_NC_function_ncsave(file_save,'UID_Kent',C98_UID,'double');
    ICOADS_NC_function_ncsave(file_save,'ID_Kent',C0_ID_K,'char');
    ICOADS_NC_function_ncsave(file_save,'ID_Kent_flag',C0_ID_F,'single');
    
    % save(file_save,'C98_UID','C0_ID_K','C0_ID_F','logic_check','-v7.3')
end