% ICOADS_NC_function_SI_from_indicators_and_inference
% SI: raw SI
% SI_1: infer early buckets, assign buoy and CMAN
% SI_2: merge with and priortize WMO47
%       (analysis that does not infer anything should use SI_2)
% SI_3: infer US ships and Deck 245 to be ERI
% SI_4: infer measurement method from deck information
% [2021-06-14] SI_3 and SI_4 are based on Kennedy et el. (2011b), 
%  we no longer use these schemes in the LME analyses, 
% but we keep these options for comparisons with previous studies.

function [C0_SI,C0_SI_1,C0_SI_2,C0_SI_3,C0_SI_4] = ...
          ICOADS_NC_function_SI_from_indicators_and_inference ...
                (C0_SI,C0_YR,C1_DCK,C1_SID,C0_II,C7_WMOMM,C0_CTY_CRT,C1_PT)

    % disp('Assigning SST measurement methods ...');

    % 0 Pretreatment: Assign -1 -------------------------------------------
    C0_SI(isnan(C0_SI)) = -1;

    % 1. Assign C-MAN -----------------------------------------------------
    logic_cman = (C1_DCK == 795 | C1_DCK == 995) | C0_II == 5 | C1_PT  == 13;

    % 2 Assign Buoy Measurement -------------------------------------------
    kind_buoy_list = [3 4 11]';
    source_buoy_list = [24 55 50 61 62 63 66 86 87 117 118 120 121 122 139 147 169 170]';
    deck_buoy_list = [143 144 146 714 734 793 794 876 877 878 879 880 881 882 883 893 894 993 994 235]';
    plt_buoy_list  = [6 7 8];

    clear('logic_kind_buoy','logic_deck_buoy','logic_source_buoy','logic_plt_buoy')
    logic_kind_buoy   = ismember(C0_II,kind_buoy_list);
    logic_source_buoy = ismember(C1_SID,source_buoy_list);
    logic_deck_buoy   = ismember(C1_DCK,deck_buoy_list);
    logic_plt_buoy    = ismember(C1_PT,plt_buoy_list);
    logic_buoy = logic_kind_buoy | logic_source_buoy | logic_deck_buoy | logic_plt_buoy;

    % 3. Old inferred buckets are buckets ---------------------------------
    logic_ship = ismember(C0_II,[1 2 8 9 10]) | ismember(C1_PT,[0 1 2 3 4 5]) | isnan(C0_II);
    % logic_bucket = logic_ship & ((C0_YR < 1941 & C0_SI == -1) | C0_SI == 10);
    logic_bucket = logic_ship & C0_SI == 10;

    C0_SI_1 = C0_SI;
    C0_SI_1(logic_bucket) = 0;
    C0_SI_1(logic_buoy & ~logic_cman) = -2;
    C0_SI_1(logic_cman)   = -3;

    % 4. From 1956, using WMO No 47. Meta-data by ship tracks -------------
    C0_SI_2 = C0_SI_1;
    C7_WMOMM(isnan(C7_WMOMM)) = -1;
    % 2020-04-13: reveiwer suggested WMO47 data is more reliable
    % as a result, WMO47 data is used prior to ICOADS metadata
    if 0 
        logic_wmo = logic_ship & (C0_SI_1 == -1 | C0_SI_1 == 7 | C0_SI_1 == 9) & ...
                    ~(C7_WMOMM == -1 | C7_WMOMM == 7 | C7_WMOMM == 9);
    else
        logic_wmo = logic_ship & ~(C7_WMOMM == -1 | C7_WMOMM == 7 | C7_WMOMM == 9);
    end
    C0_SI_2(logic_wmo) = C7_WMOMM(logic_wmo);

    % 5. Before 1941, All ships were bucket unless specified --------------
    %    US ships after 1944 and GB royal are ERI -------------------------
    C0_SI_3 = C0_SI_2;
    
    logic_bucket = logic_ship & ((C0_YR < 1941 & C0_SI_2 == -1) | C0_SI_2 == 10);
    C0_SI_3(logic_bucket) = 0;
    
    logic_US = logic_ship & C0_SI_2 == -1 & C0_CTY_CRT(:,1) == 'U' & C0_CTY_CRT(:,2) == 'S' & C0_YR > 1944;
    logic_royal = logic_ship & C1_DCK == 245 & (C0_SI_2 == -1 | C0_YR > 1941);
    C0_SI_3 (logic_US | logic_royal) = 1;

    % 5. Assign Ships Based on nations ------------------------------------
    if (C0_YR(1) > 1940)
        percent = [ 0.9619    0.0225    0.9953    1.0000    1.0000    0.9848
                    0.9728    0.0257    0.9923    0.9862    1.0000    0.9687
                    0.9821    0.0268    0.9783    0.9536    1.0000    0.9546
                    0.9877    0.0190    0.9647    0.9214    1.0000    0.9405
                    0.9936    0.0170    0.9523    0.8862    1.0000    0.9258
                    0.9901    0.0189    0.9435    0.8561    1.0000    0.9169
                    0.9871    0.0181    0.9309    0.8121    1.0000    0.9057
                    0.9844    0.0153    0.9352    0.7727    1.0000    0.9035
                    0.9834    0.0120    0.9393    0.7474    1.0000    0.9063
                    0.9753    0.0083    0.9368    0.7188    1.0000    0.9038
                    0.9627    0.0058    0.9262    0.6770    1.0000    0.8971
                    0.9516    0.0043    0.9176    0.6412    1.0000    0.8871
                    0.9422    0.0041    0.9073    0.5824    1.0000    0.8688
                    0.9194    0.0046    0.8914    0.5062    1.0000    0.8399
                    0.9084    0.0059    0.8747    0.4357    1.0000    0.8210
                    0.9136    0.0121    0.8831    0.3674    1.0000    0.8377
                    0.9150    0.0185    0.8890    0.3052    1.0000    0.8623
                    0.9107    0.0192    0.8921    0.2583    1.0000    0.8791
                    0.9232    0.0141    0.9024    0.2320    1.0000    0.9150
                    0.9247    0.0120    0.9177    0.1893    1.0000    0.9420
                    0.9037    0.0116    0.9092    0.1486    1.0000    0.9413
                    0.8845    0.0130    0.9035    0.1227    0.7437    0.9373
                    0.8629    0.0149    0.9033    0.1066    0.3612    0.9454
                    0.8348    0.0168    0.8980    0.0789    0.1006    0.9418
                    0.8089    0.0166    0.8950    0.0732    0.0931    0.9458
                    0.7892    0.0162    0.8956    0.0725    0.0626    0.9485
                    0.7606    0.0160    0.8993    0.0667    0.0247    0.9527
                    0.7327    0.0161    0.9008    0.0569         0    0.9582
                    0.6987    0.0170    0.9025    0.0504         0    0.9634
                    0.6662    0.0200    0.9009    0.0393         0    0.9661
                    0.6380    0.0227    0.8996    0.0304         0    0.9691
                    0.6648    0.0227    0.8950    0.0250    0.0407    0.9699
                    0.6971    0.0221    0.8878    0.0269    0.1079    0.9181
                    0.7399    0.0255    0.8813    0.0261    0.1585    0.8817
                    0.7788    0.0304    0.8717    0.0320    0.1656    0.8395
                    0.8154    0.0334    0.8520    0.0334    0.1677    0.7989
                    0.8058    0.0356    0.8324    0.0426    0.1680    0.7588
                    0.7033    0.0404    0.8093    0.0465    0.1600    0.7799
                    0.5909    0.0453    0.7885    0.0510    0.1416    0.7870
                    0.4862    0.0475    0.7691    0.0535    0.1252    0.8000
                    0.3842    0.0475    0.7601    0.0573    0.1187    0.8113
                    0.2840    0.0475    0.7395    0.0550    0.1187    0.8225
                    0.2778    0.0465    0.7209    0.0501    0.1187    0.8239
                    0.2834    0.0445    0.6956    0.0519    0.1187    0.8239
                    0.2860    0.0428    0.6650    0.0506    0.1187    0.8239
                    0.2869    0.0423    0.6228    0.0505    0.1187    0.8138
                    0.2813    0.0424    0.5772    0.0487    0.0994    0.7789
                    0.2689    0.0424    0.5283    0.0463    0.0642    0.7153
                    0.2470    0.0365    0.4777    0.0417    0.0354    0.6305
                    0.2266    0.0269    0.4305    0.0365    0.0290    0.5314
                    0.2026    0.0170    0.3874    0.0313    0.0289    0.4114
                    0.1915    0.0075    0.3554    0.0242    0.0289    0.3284];

        if (C0_YR(1) > 1940 && C0_YR(1) < 1957)
            percent = 1 - percent(1,:);
        elseif(C0_YR(1) > 1956)
            percent = 1 - percent(min(C0_YR(1)-1955,size(percent,1)),:);
        end
        percent(7) = percent(6);
        C0_SI_4 = C0_SI_3;
        cty_list = {'NL','US','UK','JP','RU','DD','DE'};
        for i = 1:size(cty_list,2)
            logic = C0_CTY_CRT(:,1) == cty_list{i}(1) & C0_CTY_CRT(:,2) == ...
                                cty_list{i}(2) & logic_ship & C0_SI_3 == -1;
            C0_SI_4(logic) = percent(i);
        end
    else
        C0_SI_4 = C0_SI_3;
    end

    % disp('Assigning SST measurement methods Compeletes!');
    % disp(' ');
end