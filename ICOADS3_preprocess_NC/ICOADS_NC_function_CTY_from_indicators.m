function C0_CTY = ICOADS_NC_function_CTY_from_indicators(C0_C1,C1_C2,C7_C1M)

    % disp('Preprocessing Nation Names ...');

    % Assgin name list of nations -----------------------------------------
    num_list = {'00','01','02','03','04','05','06','07','08','09',...
        ' 0',' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9'};
    for i = 10:40
        num_list{11+i} = num2str(i);
    end
    country_list = {'NL','NO','US','GB','FR','DK','IT','IN','HK','NZ',...
        'NL','NO','US','GB','FR','DK','IT','IN','HK','NZ',...
        'IE','PH','EG','CA','BE','ZA','AU','JP','PK','AR',...
        'SE','DE','IS','IL','MY','RU','FI','KR','NC','PT',...
        'ES','TH','MK','PL','BR','SG','KE','TZ','UG','MX','DD'};

    % Convert Nation Number into Abbreviations ----------------------------
    for i=1:numel(num_list)
        logic = C0_C1(:,1) == num_list{i}(1) & C0_C1(:,2) == num_list{i}(2);
        C0_C1(logic,:) = repmat(country_list{i},nnz(logic),1);

        logic = C1_C2(:,1) == num_list{i}(1) & C1_C2(:,2) == num_list{i}(2);
        C1_C2(logic,:) = repmat(country_list{i},nnz(logic),1);

        logic = C7_C1M(:,1) == num_list{i}(1) & C7_C1M(:,2) == num_list{i}(2);
        C7_C1M(logic,:) = repmat(country_list{i},nnz(logic),1);
    end

    % Assign Recruiting Nation from difference sources --------------------
    logic_1 = (C0_C1(:,1)  == ' ' & C0_C1(:,2) == ' ')  == 0;
    logic_2 = (C1_C2(:,1)  == ' ' & C1_C2(:,2) == ' ')  == 0;
    logic_3 = (C7_C1M(:,1) == ' ' & C7_C1M(:,2) == ' ') == 0;
    C0_CTY = repmat('  ',size(C0_C1,1),1);
    C0_CTY(logic_1,:) = C0_C1(logic_1,:);
    C0_CTY(logic_1 == 0 & logic_3,:) = C1_C2(logic_1 == 0 & logic_3,:);
    C0_CTY(logic_1 == 0 & logic_3 == 0 & logic_2,:) = C7_C1M(logic_1 == 0 & logic_3 == 0 & logic_2,:);

    % disp('Preprocessing Nation Names Completes!');
    % disp(' ')
end