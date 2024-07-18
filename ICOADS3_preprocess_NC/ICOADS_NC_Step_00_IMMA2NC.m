% sbatch --account=huybers_lab  -J ICOADS_nc_preprocess  -t 10080 -p huce_intel,huce_cascade -n 1  --mem-per-cpu=55000  --array=1-360  -o err --wrap='matlab -nosplash -nodesktop -nodisplay -r "num=$SLURM_ARRAY_TASK_ID; [yr_id,mon] = ind2sub([30,12],num); for yr = (1849+yr_id):30:2014,  ICOADS_NC_Step_00_IMMA2NC(yr,mon); end;quit;">>log'
% sbatch --account=huybers_lab  -J ICOADS_nc_preprocess  -t 10080 -p huce_intel,huce_cascade -n 1  --mem-per-cpu=55000  --array=[list]  -o err --wrap='matlab -nosplash -nodesktop -nodisplay -r "num=$SLURM_ARRAY_TASK_ID; [mon,yr_id] = ind2sub([12,165],num); yr = 1849+yr_id;  ICOADS_NC_Step_00_IMMA2NC(yr,mon);  quit;">>log'
% 
% ICOADS_NC_Step_00_IMMA2NC(yr,mon)
%
% This function ICOADS3.1.0 from IMMA to netcdf format.
%
% Output variables have the same name and format as
% Netcdf files for ICOADS3.0 as provided on RDA.
%
% Last update: 2021-08-01

function ICOADS_NC_Step_00_IMMA2NC(yr,mon)

    % Set direcotry and files  --------------------------------------------
    dir = '/n/home10/dchan/holy_peter/ICOADS3_total/';
    % dir = '/Users/duochan/Data/ICOADS3.1/';
    dir_load  = [dir,'ICOADS_00_IMMA/'];
    dir_save  = [dir,'ICOADS_01_nc_files/'];
    cmon      = '00';  cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    ICOADS_version = ICOADS_NC_version(yr);
    file_load      = [dir_load,'IMMA1_R',ICOADS_version,'T_',num2str(yr),'-',cmon];
    file_save_pqc  = [dir_save,'ICOADS_R',ICOADS_version,'T_',num2str(yr),'-',cmon,'.nc'];

    % Convert the files  --------------------------------------------------
    fid=fopen(file_load,'r');

    if fid > 0

        disp([file_load ,' is started!']);
        words=fscanf(fid,'%c',10000000000000);
        fclose(fid);
        num = [0 find(words == 10)];

        i = 0;
        for ct = 1:max(size(num))-1
            
            temp = words(num(ct)+1:num(ct+1)-1);
            yr_test = str2num(temp(1:4));
            
            if yr_test == yr
                
                i = i + 1;
                
                if(strcmp(temp(1:4),repmat(' ',1,4)))      C0_YR(i,1)  = NaN; else C0_YR(i,1)  = str2num(temp(1:4)); end
                if(strcmp(temp(5:6),repmat(' ',1,2)))      C0_MO(i,1)  = NaN; else C0_MO(i,1)  = str2num(temp(5:6)); end
                if(strcmp(temp(7:8),repmat(' ',1,2)))      C0_DY(i,1)  = NaN; else C0_DY(i,1)  = str2num(temp(7:8)); end
                if(strcmp(temp(9:12),repmat(' ',1,4)))     C0_HR(i,1)  = NaN; else C0_HR(i,1)  = str2num(temp(9:12))/100; end
                if(strcmp(temp(13:17),repmat(' ',1,5)))    C0_LAT(i,1) = NaN; else C0_LAT(i,1) = str2num(temp(13:17))/100; end
                if(strcmp(temp(18:23),repmat(' ',1,6)))    C0_LON(i,1) = NaN; else C0_LON(i,1) = str2num(temp(18:23))/100; end
                if(strcmp(temp(26),' '))  C0_ATTC(i,1) = NaN; elseif(any(temp(26)=='ABCDEFGHIJKLMNOPQRSTUVWXYZ')) C0_ATTC(i,1)  = temp(26)-55; else C0_ATTC(i) = str2num(temp(26)); end
                if(strcmp(temp(27),repmat(' ',1,1)))       C0_TI(i,1)  = NaN; else C0_TI(i,1)  = str2num(temp(27)); end
                if(strcmp(temp(28),repmat(' ',1,1)))       C0_LI(i,1)  = NaN; else C0_LI(i,1)  = str2num(temp(28)); end
                if(strcmp(temp(29),repmat(' ',1,1)))       C0_DS(i,1)  = NaN; else C0_DS(i,1)  = str2num(temp(29)); end
                if(strcmp(temp(30),repmat(' ',1,1)))       C0_VS(i,1)  = NaN; else C0_VS(i,1)  = str2num(temp(30)); end
                if(strcmp(temp(31:32),repmat(' ',1,2)))    C0_NID(i,1) = NaN; else C0_NID(i,1) = str2num(temp(31:32)); end
                if(strcmp(temp(33:34),repmat(' ',1,2)))    C0_II(i,1)  = NaN; else C0_II(i,1)  = str2num(temp(33:34)); end
                C0_ID(i,:) = temp(35:43);
                C0_C1(i,:) = temp(44:45);
                temp(1:45) = [];
                
                if(strcmp(temp(1),repmat(' ',1,1)))        C0_DI(i,1)  = NaN; else C0_DI(i,1)  = str2num(temp(1)); end
                if(strcmp(temp(2:4),repmat(' ',1,3)))      C0_D(i,1)   = NaN; else C0_D(i,1)   = str2num(temp(2:4)); end
                if(strcmp(temp(5),repmat(' ',1,1)))        C0_WI(i,1)  = NaN; else C0_WI(i,1)  = str2num(temp(5)); end
                if(strcmp(temp(6:8),repmat(' ',1,3)))      C0_W(i,1)   = NaN; else C0_W(i,1)   = str2num(temp(6:8))/10; end
                if(strcmp(temp(9),repmat(' ',1,1)))        C0_VI(i,1)  = NaN; else C0_VI(i,1)  = str2num(temp(9)); end
                if(strcmp(temp(10:11),repmat(' ',1,2)))    C0_VV(i,1)  = NaN; else C0_VV(i,1)  = str2num(temp(10:11)); end
                if(strcmp(temp(12:13),repmat(' ',1,2)))    C0_WW(i,1)  = NaN; else C0_WW(i,1)  = str2num(temp(12:13)); end
                if(strcmp(temp(14),repmat(' ',1,1)))       C0_W1(i,1)  = NaN; else C0_W1(i,1)  = str2num(temp(14)); end
                if(strcmp(temp(15:19),repmat(' ',1,5)))    C0_SLP(i,1) = NaN; else C0_SLP(i,1) = str2num(temp(15:19))/10; end
                if(strcmp(temp(20),repmat(' ',1,1)))       C0_A(i,1)   = NaN; else C0_A(i,1)   = str2num(temp(20)); end
                if(strcmp(temp(21:23),repmat(' ',1,3)))    C0_PPP(i,1) = NaN; else C0_PPP(i,1) = str2num(temp(21:23))/10; end
                if(strcmp(temp(24),repmat(' ',1,1)))       C0_IT(i,1)  = NaN; else C0_IT(i,1)  = str2num(temp(24)); end
                if(strcmp(temp(25:28),repmat(' ',1,4)))    C0_AT(i,1)  = NaN; else C0_AT(i,1)  = str2num(temp(25:28))/10; end
                if(strcmp(temp(29),repmat(' ',1,1)))       C0_WBTI(i,1)= NaN; else C0_WBTI(i,1)= str2num(temp(29)); end
                if(strcmp(temp(30:33),repmat(' ',1,4)))    C0_WBT(i,1) = NaN; else C0_WBT(i,1) = str2num(temp(30:33))/10; end
                if(strcmp(temp(34),repmat(' ',1,1)))       C0_DPTI(i,1)= NaN; else C0_DPTI(i,1)= str2num(temp(34)); end
                if(strcmp(temp(35:38),repmat(' ',1,4)))    C0_DPT(i,1) = NaN; else C0_DPT(i,1) = str2num(temp(35:38))/10; end
                if(strcmp(temp(39:40),repmat(' ',1,2)))    C0_SI(i,1)  = NaN; else C0_SI(i,1)  = str2num(temp(39:40)); end
                if(strcmp(temp(41:44),repmat(' ',1,4)))    C0_SST(i,1) = NaN; else C0_SST(i,1) = str2num(temp(41:44))/10; end
                if(strcmp(temp(45),repmat(' ',1,1)))       C0_N(i,1)   = NaN; else C0_N(i,1)   = str2num(temp(45)); end
                if(strcmp(temp(46),repmat(' ',1,1)))       C0_NH(i,1)  = NaN; else C0_NH(i,1)  = str2num(temp(46)); end
                if(strcmp(temp(47),' '))  C0_CL(i,1) = NaN; elseif(strcmp(temp(47),'A')) C0_CL(i,1) = 10; else C0_CL(i,1) = str2num(temp(47)); end
                if(strcmp(temp(48),repmat(' ',1,1)))       C0_HI(i,1)  = NaN; else C0_HI(i,1)  = str2num(temp(48)); end
                if(strcmp(temp(49),' '))  C0_H(i,1)  = NaN; elseif(strcmp(temp(49),'A')) C0_H(i,1)  = 10; else C0_H(i,1)  = str2num(temp(49)); end
                if(strcmp(temp(50),' '))  C0_CM(i,1) = NaN; elseif(strcmp(temp(50),'A')) C0_CM(i,1) = 10; else C0_CM(i,1) = str2num(temp(50)); end
                if(strcmp(temp(51),' '))  C0_CH(i,1) = NaN; elseif(strcmp(temp(51),'A')) C0_CH(i,1) = 10; else C0_CH(i,1) = str2num(temp(51)); end
                if(strcmp(temp(52:53),repmat(' ',1,2)))    C0_WD(i,1)  = NaN; else C0_WD(i,1)  = str2num(temp(52:53)); end
                if(strcmp(temp(54:55),repmat(' ',1,2)))    C0_WP(i,1)  = NaN; else C0_WP(i,1)  = str2num(temp(54:55)); end
                if(strcmp(temp(56:57),repmat(' ',1,2)))    C0_WH(i,1)  = NaN; else C0_WH(i,1)  = str2num(temp(56:57)); end
                if(strcmp(temp(58:59),repmat(' ',1,2)))    C0_SD(i,1)  = NaN; else C0_SD(i,1)  = str2num(temp(58:59)); end
                if(strcmp(temp(60:61),repmat(' ',1,2)))    C0_SP(i,1)  = NaN; else C0_SP(i,1)  = str2num(temp(60:61)); end
                if(strcmp(temp(62:63),repmat(' ',1,2)))    C0_SH(i,1)  = NaN; else C0_SH(i,1)  = str2num(temp(62:63)); end
                temp(1:63) = [];
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 1)
                        if(strcmp(temp(11:13),repmat(' ',1,3)))      C1_DCK(i,1)  = NaN; else C1_DCK(i,1)  = str2num(temp(11:13)); end
                        if(strcmp(temp(14:16),repmat(' ',1,3)))      C1_SID(i,1)  = NaN; else C1_SID(i,1)  = str2num(temp(14:16)); end
                        if(strcmp(temp(17:18),repmat(' ',1,2)))      C1_PT(i,1)   = NaN; else C1_PT(i,1)   = str2num(temp(17:18)); end
                        if(strcmp(temp(19:20),repmat(' ',1,2)))      C1_DUPS(i,1) = NaN; else C1_DUPS(i,1) = str2num(temp(19:20)); end
                        if(strcmp(temp(21),repmat(' ',1,1)))         C1_DUPC(i,1) = NaN; else C1_DUPC(i,1) = str2num(temp(21)); end
                        if(strcmp(temp(22),repmat(' ',1,1)))         C1_TC(i,1)   = NaN; else C1_TC(i,1)   = str2num(temp(22)); end
                        if(strcmp(temp(23),repmat(' ',1,1)))         C1_PB(i,1)   = NaN; else C1_PB(i,1)   = str2num(temp(23)); end
                        if(strcmp(temp(24),repmat(' ',1,1)))         C1_WX(i,1)   = NaN; else C1_WX(i,1)   = str2num(temp(24)); end
                        if(strcmp(temp(25),repmat(' ',1,1)))         C1_SX(i,1)   = NaN; else C1_SX(i,1)   = str2num(temp(25)); end
                        C1_C2(i,:) = temp(26:27);
                        if(strcmp(temp(40),repmat(' ',1,1)))         C1_ND(i,1)   = NaN; else C1_ND(i,1)   = str2num(temp(40)); end
                        if(strcmp(temp(41),' '))  C1_SF(i,1)  = NaN; elseif(any(temp(41) == 'ABCDEF')) C1_SF(i,1)  = temp(41)-55; else C1_SF(i,1)  = str2num(temp(41)); end
                        if(strcmp(temp(42),' '))  C1_AF(i,1)  = NaN; elseif(any(temp(42) == 'ABCDEF')) C1_AF(i,1)  = temp(42)-55; else C1_AF(i,1)  = str2num(temp(42)); end
                        if(strcmp(temp(43),' '))  C1_UF(i,1)  = NaN; elseif(any(temp(43) == 'ABCDEF')) C1_UF(i,1)  = temp(43)-55; else C1_UF(i,1)  = str2num(temp(43)); end
                        if(strcmp(temp(44),' '))  C1_VF(i,1)  = NaN; elseif(any(temp(44) == 'ABCDEF')) C1_VF(i,1)  = temp(44)-55; else C1_VF(i,1)  = str2num(temp(44)); end
                        if(strcmp(temp(45),' '))  C1_PF(i,1)  = NaN; elseif(any(temp(45) == 'ABCDEF')) C1_PF(i,1)  = temp(45)-55; else C1_PF(i,1)  = str2num(temp(45)); end
                        if(strcmp(temp(46),' '))  C1_RF(i,1)  = NaN; elseif(any(temp(46) == 'ABCDEF')) C1_RF(i,1)  = temp(46)-55; else C1_RF(i,1)  = str2num(temp(46)); end
                        if(strcmp(temp(47),' '))  C1_ZNC(i,1) = NaN; elseif(strcmp(temp(47),'A')) C1_ZNC(i,1) = 10; else C1_ZNC(i,1) = str2num(temp(47)); end
                        if(strcmp(temp(48),' '))  C1_WNC(i,1) = NaN; elseif(strcmp(temp(48),'A')) C1_WNC(i,1) = 10; else C1_WNC(i,1) = str2num(temp(48)); end
                        if(strcmp(temp(49),' '))  C1_BNC(i,1) = NaN; elseif(strcmp(temp(49),'A')) C1_BNC(i,1) = 10; else C1_BNC(i,1) = str2num(temp(49)); end
                        if(strcmp(temp(50),' '))  C1_XNC(i,1) = NaN; elseif(strcmp(temp(50),'A')) C1_XNC(i,1) = 10; else C1_XNC(i,1) = str2num(temp(50)); end
                        if(strcmp(temp(51),' '))  C1_YNC(i,1) = NaN; elseif(strcmp(temp(51),'A')) C1_YNC(i,1) = 10; else C1_YNC(i,1) = str2num(temp(51)); end
                        if(strcmp(temp(52),' '))  C1_PNC(i,1) = NaN; elseif(strcmp(temp(52),'A')) C1_PNC(i,1) = 10; else C1_PNC(i,1) = str2num(temp(52)); end
                        if(strcmp(temp(53),' '))  C1_ANC(i,1) = NaN; elseif(strcmp(temp(53),'A')) C1_ANC(i,1) = 10; else C1_ANC(i,1) = str2num(temp(53)); end
                        if(strcmp(temp(54),' '))  C1_GNC(i,1) = NaN; elseif(strcmp(temp(54),'A')) C1_GNC(i,1) = 10; else C1_GNC(i,1) = str2num(temp(54)); end
                        if(strcmp(temp(55),' '))  C1_DNC(i,1) = NaN; elseif(strcmp(temp(55),'A')) C1_DNC(i,1) = 10; else C1_DNC(i,1) = str2num(temp(55)); end
                        if(strcmp(temp(56),' '))  C1_SNC(i,1) = NaN; elseif(strcmp(temp(56),'A')) C1_SNC(i,1) = 10; else C1_SNC(i,1) = str2num(temp(56)); end
                        if(strcmp(temp(57),' '))  C1_CNC(i,1) = NaN; elseif(strcmp(temp(57),'A')) C1_CNC(i,1) = 10; else C1_CNC(i,1) = str2num(temp(57)); end
                        if(strcmp(temp(58),' '))  C1_ENC(i,1) = NaN; elseif(strcmp(temp(58),'A')) C1_ENC(i,1) = 10; else C1_ENC(i,1) = str2num(temp(58)); end
                        if(strcmp(temp(59),' '))  C1_FNC(i,1) = NaN; elseif(strcmp(temp(59),'A')) C1_FNC(i,1) = 10; else C1_FNC(i,1) = str2num(temp(59)); end
                        if(strcmp(temp(60),' '))  C1_TNC(i,1) = NaN; elseif(strcmp(temp(60),'A')) C1_TNC(i,1) = 10; else C1_TNC(i,1) = str2num(temp(60)); end
                        if(strcmp(temp(63),repmat(' ',1,1)))         C1_LZ(i,1)   = NaN; else C1_LZ(i,1)   = str2num(temp(63)); end
                        temp(1:65)=[];
                    else
                        C1_DCK(i,1)  = NaN;
                        C1_SID(i,1)  = NaN;
                        C1_PT(i,1)   = NaN;
                        C1_DUPS(i,1) = NaN;
                        C1_DUPC(i,1) = NaN;
                        C1_TC(i,1)   = NaN;
                        C1_PB(i,1)   = NaN;
                        C1_WX(i,1)   = NaN;
                        C1_SX(i,1)   = NaN;
                        C1_C2(i,1:2) = '  ';
                        C1_ND(i,1)   = NaN;
                        C1_SF(i,1)   = NaN;
                        C1_AF(i,1)   = NaN;
                        C1_UF(i,1)   = NaN;
                        C1_VF(i,1)   = NaN;
                        C1_PF(i,1)   = NaN;
                        C1_RF(i,1)   = NaN;
                        C1_ZNC(i,1)  = NaN;
                        C1_WNC(i,1)  = NaN;
                        C1_BNC(i,1)  = NaN;
                        C1_XNC(i,1)  = NaN;
                        C1_YNC(i,1)  = NaN;
                        C1_PNC(i,1)  = NaN;
                        C1_ANC(i,1)  = NaN;
                        C1_GNC(i,1)  = NaN;
                        C1_DNC(i,1)  = NaN;
                        C1_SNC(i,1)  = NaN;
                        C1_CNC(i,1)  = NaN;
                        C1_ENC(i,1)  = NaN;
                        C1_FNC(i,1)  = NaN;
                        C1_TNC(i,1)  = NaN;
                        C1_LZ(i,1)   = NaN;
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 5)
                        if(strcmp(temp(55:57),repmat(' ',1,3)))      C5_HDG(i,1)   = NaN; else C5_HDG(i,1)   = str2num(temp(55:57)); end
                        if(strcmp(temp(58:60),repmat(' ',1,3)))      C5_COG(i,1)   = NaN; else C5_COG(i,1)   = str2num(temp(58:60)); end
                        if(strcmp(temp(61:62),repmat(' ',1,2)))      C5_SOG(i,1)   = NaN; else C5_SOG(i,1)   = str2num(temp(61:62)); end
                        if(strcmp(temp(68:70),repmat(' ',1,3)))      C5_RWD(i,1)   = NaN; else C5_RWD(i,1)   = str2num(temp(68:70)); end
                        if(strcmp(temp(71:73),repmat(' ',1,3)))      C5_RWS(i,1)   = NaN; else C5_RWS(i,1)   = str2num(temp(71:73))/10; end
                        if(strcmp(temp(68:70),repmat(' ',1,3)))      C5_RWD(i,1)   = NaN; else C5_RWD(i,1)   = str2num(temp(68:70)); end
                        if(strcmp(temp(82:85),repmat(' ',1,4)))      C5_RH(i,1)    = NaN; else C5_RH(i,1)    = str2num(temp(82:85)); end
                        if(strcmp(temp(86),repmat(' ',1,1)))         C5_RHI(i,1)   = NaN; else C5_RHI(i,1)   = str2num(temp(86)); end
                        
                        temp(1:94)=[];
                    else
                        C5_HDG(i,1)   = NaN;
                        C5_COG(i,1)   = NaN;
                        C5_SOG(i,1)   = NaN;
                        C5_RWD(i,1)   = NaN;
                        C5_RWS(i,1)   = NaN;
                        C5_RH(i,1)    = NaN;
                        C5_RHI(i,1)   = NaN;
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 6)
                        temp(1:68)=[];
                    else
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 7)
                        C7_C1M(i,:) = temp(6:7);
                        if(strcmp(temp(8:9),repmat(' ',1,2)))        C7_OPM(i,1)   = NaN; else C7_OPM(i,1)   = str2num(temp(8:9)); end
                        C7_KOV(i,:) = temp(10:11);
                        C7_TOT(i,:) = temp(17:19);
                        C7_EOT(i,:) = temp(20:21);
                        C7_SIM(i,:) = temp(27:29);
                        if(strcmp(temp(30:32),repmat(' ',1,3)))      C7_LOV(i,1)   = NaN; else C7_LOV(i,1)   = str2num(temp(30:32)); end
                        if(strcmp(temp(33:34),repmat(' ',1,2)))      C7_DOS(i,1)   = NaN; else C7_DOS(i,1)   = str2num(temp(33:34)); end
                        if(strcmp(temp(35:37),repmat(' ',1,3)))      C7_HOP(i,1)   = NaN; else C7_HOP(i,1)   = str2num(temp(35:37)); end
                        if(strcmp(temp(38:40),repmat(' ',1,3)))      C7_HOT(i,1)   = NaN; else C7_HOT(i,1)   = str2num(temp(38:40)); end
                        if(strcmp(temp(41:43),repmat(' ',1,3)))      C7_HOB(i,1)   = NaN; else C7_HOB(i,1)   = str2num(temp(41:43)); end
                        if(strcmp(temp(44:46),repmat(' ',1,3)))      C7_HOA(i,1)   = NaN; else C7_HOA(i,1)   = str2num(temp(44:46)); end
                        temp(1:58)=[];
                    else
                        C7_C1M(i,:) = '  ';
                        C7_OPM(i,1)   = NaN;
                        C7_KOV(i,:) = '  ';
                        C7_TOT(i,:) = '   ';
                        C7_EOT(i,:) = '  ';
                        C7_SIM(i,:) = '   ';
                        C7_LOV(i,1)   = NaN;
                        C7_DOS(i,1)   = NaN;
                        C7_HOP(i,1)   = NaN;
                        C7_HOT(i,1)   = NaN;
                        C7_HOB(i,1)   = NaN;
                        C7_HOA(i,1)   = NaN;
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 8)
                        if(strcmp(temp(5:9),repmat(' ',1,5)))        C8_OTV(i,1)   = NaN; else C8_OTV(i,1)   = str2num(temp(5:9))/1000; end
                        if(strcmp(temp(10:13),repmat(' ',1,4)))      C8_OTZ(i,1)   = NaN; else C8_OTZ(i,1)   = str2num(temp(10:13))/100; end
                        if(strcmp(temp(14:18),repmat(' ',1,5)))      C8_OSV(i,1)   = NaN; else C8_OSV(i,1)   = str2num(temp(14:18))/1000; end
                        if(strcmp(temp(19:22),repmat(' ',1,4)))      C8_OSZ(i,1)   = NaN; else C8_OSZ(i,1)   = str2num(temp(19:22))/100; end
                        if(strcmp(temp(23:26),repmat(' ',1,4)))      C8_OOV(i,1)   = NaN; else C8_OOV(i,1)   = str2num(temp(23:26))/100; end
                        if(strcmp(temp(27:30),repmat(' ',1,4)))      C8_OOZ(i,1)   = NaN; else C8_OOZ(i,1)   = str2num(temp(27:30))/100; end
                        temp(1:102)=[];
                    else
                        C8_OTV(i,1)   = NaN;
                        C8_OTZ(i,1)   = NaN;
                        C8_OSV(i,1)   = NaN;
                        C8_OSZ(i,1)   = NaN;
                        C8_OOV(i,1)   = NaN;
                        C8_OOZ(i,1)   = NaN;
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 9)
                        if(strcmp(temp(8),repmat(' ',1,1)))         C9_Ne(i,1)   = NaN; else C9_Ne(i,1)   = str2num(temp(8)); end
                        if(strcmp(temp(9),repmat(' ',1,1)))         C9_NHe(i,1)  = NaN; else C9_NHe(i,1)  = str2num(temp(9)); end
                        if(strcmp(temp(16:18),repmat(' ',1,3)))     C9_AM(i,1)   = NaN; else C9_AM(i,1)   = str2num(temp(16:18)); end
                        if(strcmp(temp(19:21),repmat(' ',1,3)))     C9_AH(i,1)   = NaN; else C9_AH(i,1)   = str2num(temp(19:21)); end
                        if(strcmp(temp(29:32),repmat(' ',1,4)))     C9_RI(i,1)   = NaN; else C9_RI(i,1)   = str2num(temp(29:32)); end
                        temp(1:32)=[];
                    else
                        C9_Ne(i,1)   = NaN;
                        C9_NHe(i,1)  = NaN;
                        C9_AM(i,1)   = NaN;
                        C9_AH(i,1)   = NaN;
                        C9_RI(i,1)   = NaN;
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 95)
                        temp(1:61)=[];
                    else
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 96)
                        temp(1:53)=[];
                    else
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 97)
                        temp(1:32)=[];
                    else
                    end
                end
                
                if(isempty(temp) == 0)
                    temp_att = str2num(temp(1:2));
                    if(temp_att == 98)
                        clear('C98_temp')
                        C98_temp = temp(5:10);
                        C98_UID(i,:) = C98_temp;
                        if(strcmp(temp(15),repmat(' ',1,1)))      C98_IRF(i,1)   = NaN; else C98_IRF(i,1)   = str2num(temp(15)); end
                        temp(1:15)=[];
                    else
                        C98_UID(i,:) = '      ';
                        C98_IRF(i,1) = NaN;
                    end
                end
            end
        end

        clear('words','num','fid','i','ans','C98_temp','temp','temp_att','file_load');
        
        % Save NC files ---------------------------------------------------        
        disp(['Saving ', file_save_pqc,' ...'])
        disp('Saving data...')
        C0_DY(isnan(C0_DY)) = 99;
        if mon >= 10
            date = [num2str(C0_YR) num2str(C0_MO) num2str(C0_DY)];
        else
            date = [num2str(C0_YR) repmat('0',numel(C0_MO),1) num2str(C0_MO) num2str(C0_DY)];
        end
        date(date==' ') = '0';
        ICOADS_NC_function_ncsave_0(file_save_pqc,'date',date','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'HR',C0_HR,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'lon',C0_LON,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'lat',C0_LAT,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'TI',C0_TI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'LI',C0_LI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DS',C0_DS,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'VS',C0_VS,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'NID',C0_NID,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'II',C0_II,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'ID',C0_ID','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'C1',C0_C1','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DI',C0_DI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'D',C0_D,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WI',C0_WI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'W',C0_W,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'VI',C0_VI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'VV',C0_VV,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WW',C0_WW,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'W1',C0_W1,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'SLP',C0_SLP,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'IT',C0_IT,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'AT',C0_AT,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WBTI',C0_WBTI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WBT',C0_WBT,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DPTI',C0_DPTI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DPT',C0_DPT,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'SI',C0_SI,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'SST',C0_SST,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'N',C0_N,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'NH',C0_NH,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'CL',C0_CL,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'CM',C0_CM,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'CH',C0_CH,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WD',C0_WD,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WP',C0_WP,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WH',C0_WH,'int16');
        
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DCK',C1_DCK,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'SID',C1_SID,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'PT',C1_PT,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DUPS',C1_DUPS,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DIPC',C1_DUPC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'PB',C1_PB,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WX',C1_WX,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'C2',C1_C2,'char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'ND',C1_ND,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'SF',C1_SF,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'AF',C1_AF,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'UF',C1_UF,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'VF',C1_VF,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'PF',C1_PF,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'RF',C1_RF,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'ZNC',C1_ZNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'WNC',C1_WNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'BNC',C1_BNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'XNC',C1_XNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'YNC',C1_YNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'PNC',C1_PNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'ANC',C1_ANC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'GNC',C1_GNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DNC',C1_DNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'SNC',C1_SNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'CNC',C1_CNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'ENC',C1_ENC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'FNC',C1_FNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'TNC',C1_TNC,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'LZ',C1_LZ,'int16');
        
        ICOADS_NC_function_ncsave_0(file_save_pqc,'C1M',C7_C1M','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'OPM',C7_OPM,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'KOV',C7_KOV','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'TOT',C7_TOT','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'EOT',C7_EOT','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'SIM',C7_SIM','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'LOV',C7_LOV,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'DOS',C7_DOS,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'HOP',C7_HOP,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'HOT',C7_HOT,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'HOB',C7_HOB,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'HOA',C7_HOA,'int16');
        
        ICOADS_NC_function_ncsave_0(file_save_pqc,'OTV',C8_OTV,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'OTZ',C8_OTZ,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'OSV',C8_OSV,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'OSZ',C8_OSZ,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'OOV',C8_OOV,'single');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'OOZ',C8_OOZ,'single');

        ICOADS_NC_function_ncsave_0(file_save_pqc,'NE',C9_Ne,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'NHE',C9_NHe,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'AM',C9_AM,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'AH',C9_AH,'int16');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'RI',C9_RI,'single');
        
        ICOADS_NC_function_ncsave_0(file_save_pqc,'UID',C98_UID','char');
        ICOADS_NC_function_ncsave_0(file_save_pqc,'IRF',C98_IRF,'int16');
             
    else
        disp([file_load ,' does not exist!']);
    end
    disp(['Processing ',file_save_pqc ,' completes!']);
    disp([' ']);
end


function ICOADS_NC_function_ncsave_0(file_save,var_name,data,type)

    N_meas = max(size(data));
    
    if ~exist('type','var'),   type = 'double';    end
    if isempty(type),          type = 'double';    end
    if ismember(type,{'single','double'}), FillValue = -9999; end
    if strcmp(type,'int16'), FillValue = -99; end
    
    if size(data,2) == 1
        nccreate(file_save,var_name,'Dimensions', {'obs',N_meas},...
             'Datatype',type,'FillValue',FillValue,'Format','netcdf4');
    elseif size(data,1) == N_meas
        nccreate(file_save,var_name,'Dimensions', {'obs',N_meas,[var_name,'_len'],size(data,2)},...
             'Datatype',type,'FillValue','disable','Format','netcdf4');        
    else
        nccreate(file_save,var_name,'Dimensions', {[var_name,'_len'],size(data,1),'obs',N_meas},...
             'Datatype',type,'FillValue','disable','Format','netcdf4');
    end
    ncwrite(file_save,var_name,data);

end
