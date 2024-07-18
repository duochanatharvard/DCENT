function C0_CTY_CRT = ICOADS_NC_function_CTY_from_deck(C0_CTY,C1_DCK)

    % disp('Assgining Nation Names using DCK ...');

    C0_CTY_CRT = C0_CTY;
    logic0 = (C0_CTY(:,1) == ' ' & C0_CTY(:,2) == ' ');

    % 1. Netherlands ------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[150;189;193]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('NL',nnz(logic),1);
    % 2. US ---------------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[110 116 117 195 218 281 666 667 701 703 704 709 710]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('US',nnz(logic),1);
    % 3. UK ---------------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[152 184 194 902 204 205 211 216 229 239 245 248 249]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('GB',nnz(logic),1);
    % 4. Japan ------------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[118 119 187 761 762 898]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('JP',nnz(logic),1);
    % 5. Russia -----------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[185 186 732 731 733 735]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('RU',nnz(logic),1);
    % 6. German ------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[151 192 196 215 715 720 721 772 850]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('DE',nnz(logic),1);
    % 7. Norway -----------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[188 702 225]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('NO',nnz(logic),1);
    % 8. Canada -----------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[714]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('CA',nnz(logic),1);
    % 9. South Africa -----------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[899]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('ZA',nnz(logic),1);
    % 10. Australia -------------------------------------------------------
    clear('logic')
    logic = ismember(C1_DCK,[900 750]) & logic0;
    C0_CTY_CRT(logic,:) = repmat('AU',nnz(logic),1);

    % disp('Assgining Nation Names using DCK Completes!');
    disp(' ')
end