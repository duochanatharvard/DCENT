clearvars -except do_QC

switch do_QC
    case 0, P.app      = 'qcu';
    case 1, P.app      = 'qcf';
end

% *************************************************************************
% Read and parse temperature 
% *************************************************************************
file = [GHCN_IO('GHCN'),'ghcnm.tavg.v4.0.1.',GHCN_IO('date'),'.',P.app,'.dat'];

fid = fopen(file,'r');
ch = fscanf(fid,'%c',10000000000000);
fclose(fid);

DATA = reshape(ch,116,numel(ch)/116)';     DATA = DATA(:,1:end-1);
STA  = DATA(:,1:11);
YR   = str2num(DATA(:,12:15));
VAR  = DATA(:,16:19);

VALUE = nan(size(DATA,1),12);
QC    = nan(size(DATA,1),12);
for mon = 1:12
    temp         = DATA(:,[20:24]+(mon-1)*8);
    VALUE(:,mon) = str2num(temp)/100;
    QC0(:,mon)   = DATA(:,26+(mon-1)*8);
end
VALUE(VALUE == -99.99) = nan;

[uni_station,~,J] = unique(STA,'rows');

% *************************************************************************
% Read and parse metadata 
% *************************************************************************
file_inv = [GHCN_IO('GHCN'),'ghcnm.tavg.v4.0.1.',GHCN_IO('date'),'.',P.app,'.inv'];
fid = fopen(file_inv,'r');
ch = fscanf(fid,'%c',10000000000000);
fclose(fid);

clear('inv')
list = [0 find(ch == 10)];
for ct = 1:numel(list)-1
    temp = ch(list(ct)+1:list(ct+1));
    INV(ct,:) = temp(1:68);
end
INV_ID = INV(:,1:11);
LAT = str2num(INV(:,13:20));
LON = str2num(INV(:,22:30));
LEV = str2num(INV(:,32:37));
LEV(LEV > 9900) = nan;

% *************************************************************************
% save data
% *************************************************************************
yr_st = 1700;
vec   = datevec(date);
yr_ed = vec(1);
N_yr  = yr_ed - yr_st + 1;
N_sta = size(uni_station,1);

T     = nan(12,N_yr,N_sta);
QC    = nan(12,N_yr,N_sta);
Lon   = nan(N_sta,1);
Lat   = nan(N_sta,1);
Lev   = nan(N_sta,1);
Sta   = nan(N_sta,11);
for ct = 1:N_sta
    try
        l       = J == ct & YR >= yr_st;
        yr_temp = YR(l);
        T_temp  = VALUE(l,:)';
        qc_temp = QC0(l,:)';

        l       = find(ismember(INV_ID,uni_station(ct,:),'rows'));
        Lon(ct) = LON(l);
        Lat(ct) = LAT(l);
        Lev(ct) = LEV(l);

        l          = yr_temp - yr_st + 1;
        T(:,l,ct)  = T_temp;
        QC(:,l,ct) = qc_temp;
        Sta(ct,:)  = uni_station(ct,:);
    catch
        disp(['something is wrong for station ', uni_station(ct,:)])
    end
end
fsave = [GHCN_IO('GHCN'),'ghcnm.tavg.v4.0.1.',GHCN_IO('date'),'.',P.app,'.mat'];
save(fsave,'Lon','Lat','Lev','T','QC','Sta','-v7.3');


% *************************************************************************
% Read distance to the coast
% *************************************************************************
Table     = readtable([GHCN_IO('code'),'GHCN_Metadata_MicroSite.csv']);
names     = cell2mat(table2cell(Table(:,1)));
distance  = cell2mat(table2cell(Table(:,7)));
lon_meta  = cell2mat(table2cell(Table(:,3)));
lat_meta  = cell2mat(table2cell(Table(:,4)));
[~,place] = ismember(INV_ID,names,'rows');
dis = nan(size(place,1),1);
for ct = 1:size(place,1)
    if place(ct) > 0
        temp = distance(place(ct));
        if ~isempty(temp)
            dis(ct) = temp;
        end
    end
end
l_exclude           = abs(LAT) > 60 | (LON > 0 & LON < 52 & LAT > 28 & LAT < 90) | ...
                      dis <= -10 | isnan(dis);
ID_coastal_station  = INV_ID(~l_exclude,:);

file_save = [GHCN_IO('GHCN'),'Coastal_station_list_',P.app,'_',GHCN_IO('date'),'.mat'];
save(file_save,'ID_coastal_station','-v7.3')
