function C0_IDCTY = ICOADS_NC_function_callsign2nation(ID,C0_II)

    C0_IDCTY = nan(size(ID,1),2);

    l = ICOADS_NC_function_id2nat(ID,'A','A','L');
    C0_IDCTY(l,:) = repmat('US',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','M','O');
    C0_IDCTY(l,:) = repmat('ES',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','P','S');
    C0_IDCTY(l,:) = repmat('PK',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','T','W');
    C0_IDCTY(l,:) = repmat('IN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','X','X');
    C0_IDCTY(l,:) = repmat('AU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','Y','Z');
    C0_IDCTY(l,:) = repmat('AR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'B','A','Z');
    C0_IDCTY(l,:) = repmat('CN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','A','E');
    C0_IDCTY(l,:) = repmat('CL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','F','K');
    C0_IDCTY(l,:) = repmat('CA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','L','M');
    C0_IDCTY(l,:) = repmat('CU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','N','N');
    C0_IDCTY(l,:) = repmat('KM',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','O','O');
    C0_IDCTY(l,:) = repmat('CU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','P','P');
    C0_IDCTY(l,:) = repmat('BO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','Q','R');
    C0_IDCTY(l,:) = repmat('PT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','S','U');
    C0_IDCTY(l,:) = repmat('PT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','V','X');
    C0_IDCTY(l,:) = repmat('UY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','Y','Z');
    C0_IDCTY(l,:) = repmat('CA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'D','A','T');
    C0_IDCTY(l,:) = repmat('DE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'D','U','Z');
    C0_IDCTY(l,:) = repmat('PH',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','A','H');
    C0_IDCTY(l,:) = repmat('ES',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','I','J');
    C0_IDCTY(l,:) = repmat('IE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','K','K');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','L','L');
    C0_IDCTY(l,:) = repmat('LR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','M','O');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','P','Q');
    C0_IDCTY(l,:) = repmat('IR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','R','R');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','S','S');
    C0_IDCTY(l,:) = repmat('EE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','T','T');
    C0_IDCTY(l,:) = repmat('ET',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','U','W');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'E','X','Z');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'F','A','Z');
    C0_IDCTY(l,:) = repmat('FR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'G','A','Z');
    C0_IDCTY(l,:) = repmat('GB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','A','A');
    C0_IDCTY(l,:) = repmat('HU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','B','B');
    C0_IDCTY(l,:) = repmat('CH',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','C','D');
    C0_IDCTY(l,:) = repmat('EC',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','E','E');
    C0_IDCTY(l,:) = repmat('CH',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','F','F');
    C0_IDCTY(l,:) = repmat('PL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','G','G');
    C0_IDCTY(l,:) = repmat('HU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','H','H');
    C0_IDCTY(l,:) = repmat('HT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','I','I');
    C0_IDCTY(l,:) = repmat('DO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','J','K');
    C0_IDCTY(l,:) = repmat('CO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','L','M');
    C0_IDCTY(l,:) = repmat('KR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','N','N');
    C0_IDCTY(l,:) = repmat('IQ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','O','P');
    C0_IDCTY(l,:) = repmat('PA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','Q','R');
    C0_IDCTY(l,:) = repmat('HN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','S','S');
    C0_IDCTY(l,:) = repmat('TH',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','T','T');
    C0_IDCTY(l,:) = repmat('NI',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','U','U');
    C0_IDCTY(l,:) = repmat('SV',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','V','V');
    C0_IDCTY(l,:) = repmat('VA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','W','Y');
    C0_IDCTY(l,:) = repmat('FR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'H','Z','Z');
    C0_IDCTY(l,:) = repmat('SA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'I','A','Z');
    C0_IDCTY(l,:) = repmat('IT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'J','A','S');
    C0_IDCTY(l,:) = repmat('JP',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'J','T','V');
    C0_IDCTY(l,:) = repmat('MN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'J','W','X');
    C0_IDCTY(l,:) = repmat('NO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'J','Y','Y');
    C0_IDCTY(l,:) = repmat('JO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'J','Z','Z');
    C0_IDCTY(l,:) = repmat('GN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'K','A','Z');
    C0_IDCTY(l,:) = repmat('US',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'L','A','N');
    C0_IDCTY(l,:) = repmat('NO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'L','O','W');
    C0_IDCTY(l,:) = repmat('AR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'L','X','X');
    C0_IDCTY(l,:) = repmat('LU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'L','Y','Y');
    C0_IDCTY(l,:) = repmat('LT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'L','Z','Z');
    C0_IDCTY(l,:) = repmat('BG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'M','A','Z');
    C0_IDCTY(l,:) = repmat('GB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'N','A','Z');
    C0_IDCTY(l,:) = repmat('US',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'O','A','C');
    C0_IDCTY(l,:) = repmat('PE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'O','D','D');
    C0_IDCTY(l,:) = repmat('LB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'O','E','E');
    C0_IDCTY(l,:) = repmat('AT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'O','F','J');
    C0_IDCTY(l,:) = repmat('FI',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'O','K','M');
    C0_IDCTY(l,:) = repmat('CZ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'O','N','T');
    C0_IDCTY(l,:) = repmat('BE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'O','U','Z');
    C0_IDCTY(l,:) = repmat('DK',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'P','A','I');
    C0_IDCTY(l,:) = repmat('NL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'P','J','J');
    C0_IDCTY(l,:) = repmat('NL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'P','K','O');
    C0_IDCTY(l,:) = repmat('ID',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'P','P','Y');
    C0_IDCTY(l,:) = repmat('BR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'P','Z','Z');
    C0_IDCTY(l,:) = repmat('SR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'R','A','Z');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','A','M');
    C0_IDCTY(l,:) = repmat('SE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','N','R');
    C0_IDCTY(l,:) = repmat('PL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','S','S','A','M');
    C0_IDCTY(l,:) = repmat('AE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','S','S','N','Z');
    C0_IDCTY(l,:) = repmat('SD',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','T','T');
    C0_IDCTY(l,:) = repmat('SD',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','U','U');
    C0_IDCTY(l,:) = repmat('EG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','V','Z');
    C0_IDCTY(l,:) = repmat('GR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','A','C');
    C0_IDCTY(l,:) = repmat('TR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','D','D');
    C0_IDCTY(l,:) = repmat('GT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','E','E');
    C0_IDCTY(l,:) = repmat('CR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','F','F');
    C0_IDCTY(l,:) = repmat('IS',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','G','G');
    C0_IDCTY(l,:) = repmat('GT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','H','H');
    C0_IDCTY(l,:) = repmat('FR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','I','I');
    C0_IDCTY(l,:) = repmat('CR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','H','H');
    C0_IDCTY(l,:) = repmat('CM',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','K','K');
    C0_IDCTY(l,:) = repmat('FR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','L','L');
    C0_IDCTY(l,:) = repmat('CF',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','M','M');
    C0_IDCTY(l,:) = repmat('FR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','N','N');
    C0_IDCTY(l,:) = repmat('CG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','O','Q');
    C0_IDCTY(l,:) = repmat('FR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','R','R');
    C0_IDCTY(l,:) = repmat('GA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','S','S');
    C0_IDCTY(l,:) = repmat('TN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','T','T');
    C0_IDCTY(l,:) = repmat('TD',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','U','U');
    C0_IDCTY(l,:) = repmat('CI',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','V','X');
    C0_IDCTY(l,:) = repmat('FR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'T','Z','Z');
    C0_IDCTY(l,:) = repmat('ML',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'U','A','Q');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'U','R','T');
    C0_IDCTY(l,:) = repmat('UA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'U','U','Z');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'V','A','G');
    C0_IDCTY(l,:) = repmat('CA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'V','H','N');
    C0_IDCTY(l,:) = repmat('AU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'V','O','O');
    C0_IDCTY(l,:) = repmat('CA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'V','P','S');
    C0_IDCTY(l,:) = repmat('GB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'V','T','W');
    C0_IDCTY(l,:) = repmat('IN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'V','X','Y');
    C0_IDCTY(l,:) = repmat('CA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'V','Z','Z');
    C0_IDCTY(l,:) = repmat('AU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'W','A','Z');
    C0_IDCTY(l,:) = repmat('US',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','A','I');
    C0_IDCTY(l,:) = repmat('MX',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','J','O');
    C0_IDCTY(l,:) = repmat('CA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','P','P');
    C0_IDCTY(l,:) = repmat('DK',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','Q','R');
    C0_IDCTY(l,:) = repmat('CL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','S','S');
    C0_IDCTY(l,:) = repmat('CN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','V','V');
    C0_IDCTY(l,:) = repmat('VN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','W','W');
    C0_IDCTY(l,:) = repmat('LA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'X','X','X');
    C0_IDCTY(l,:) = repmat('PT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','A','A');
    C0_IDCTY(l,:) = repmat('AF',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','B','H');
    C0_IDCTY(l,:) = repmat('ID',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','I','I');
    C0_IDCTY(l,:) = repmat('IQ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','K','K');
    C0_IDCTY(l,:) = repmat('SY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','L','L');
    C0_IDCTY(l,:) = repmat('LV',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','M','M');
    C0_IDCTY(l,:) = repmat('TR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','N','N');
    C0_IDCTY(l,:) = repmat('NI',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','O','R');
    C0_IDCTY(l,:) = repmat('RO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','S','S');
    C0_IDCTY(l,:) = repmat('SV',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','T','U');
    C0_IDCTY(l,:) = repmat('MK',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','V','Y');
    C0_IDCTY(l,:) = repmat('VE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Y','Z','Z');
    C0_IDCTY(l,:) = repmat('MK',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Z','A','A');
    C0_IDCTY(l,:) = repmat('AL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Z','B','J');
    C0_IDCTY(l,:) = repmat('GB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Z','K','M');
    C0_IDCTY(l,:) = repmat('NZ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Z','N','P');
    C0_IDCTY(l,:) = repmat('PY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Z','Q','Q');
    C0_IDCTY(l,:) = repmat('GB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Z','R','U');
    C0_IDCTY(l,:) = repmat('ZA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'Z','V','Z');
    C0_IDCTY(l,:) = repmat('BR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'2','A','Z');
    C0_IDCTY(l,:) = repmat('GB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','A','A');
    C0_IDCTY(l,:) = repmat('MC',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','B','B');
    C0_IDCTY(l,:) = repmat('MU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','C','C');
    C0_IDCTY(l,:) = repmat('GQ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','D','D','A','M');
    C0_IDCTY(l,:) = repmat('SZ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','D','D','N','Z');
    C0_IDCTY(l,:) = repmat('FJ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','E','F');
    C0_IDCTY(l,:) = repmat('PA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','G','G');
    C0_IDCTY(l,:) = repmat('CL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','H','U');
    C0_IDCTY(l,:) = repmat('CN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','V','V');
    C0_IDCTY(l,:) = repmat('TN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','W','W');
    C0_IDCTY(l,:) = repmat('VN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','X','X');
    C0_IDCTY(l,:) = repmat('GN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','Y','Y');
    C0_IDCTY(l,:) = repmat('NO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'3','Z','Z');
    C0_IDCTY(l,:) = repmat('PL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','A','C');
    C0_IDCTY(l,:) = repmat('MX',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','D','I');
    C0_IDCTY(l,:) = repmat('PH',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','J','L');
    C0_IDCTY(l,:) = repmat('RU',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','M','M');
    C0_IDCTY(l,:) = repmat('VE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','N','O');
    C0_IDCTY(l,:) = repmat('MK',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','T','T');
    C0_IDCTY(l,:) = repmat('PE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','V','V');
    C0_IDCTY(l,:) = repmat('HT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','W','W');
    C0_IDCTY(l,:) = repmat('YE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','X','X');
    C0_IDCTY(l,:) = repmat('IL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'4','Z','Z');
    C0_IDCTY(l,:) = repmat('IL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','A','A');
    C0_IDCTY(l,:) = repmat('LY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','B','B');
    C0_IDCTY(l,:) = repmat('CY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','C','G');
    C0_IDCTY(l,:) = repmat('MA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','H','I');
    C0_IDCTY(l,:) = repmat('TZ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','J','K');
    C0_IDCTY(l,:) = repmat('CO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','L','M');
    C0_IDCTY(l,:) = repmat('LR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','N','O');
    C0_IDCTY(l,:) = repmat('NG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','R','S');
    C0_IDCTY(l,:) = repmat('MG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','T','T');
    C0_IDCTY(l,:) = repmat('MR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','U','U');
    C0_IDCTY(l,:) = repmat('NG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','V','V');
    C0_IDCTY(l,:) = repmat('TG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','W','W');
    C0_IDCTY(l,:) = repmat('WS',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','X','X');
    C0_IDCTY(l,:) = repmat('UG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'5','Y','Y');
    C0_IDCTY(l,:) = repmat('KE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','A','B');
    C0_IDCTY(l,:) = repmat('EG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','C','C');
    C0_IDCTY(l,:) = repmat('SY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','D','J');
    C0_IDCTY(l,:) = repmat('MX',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','K','N');
    C0_IDCTY(l,:) = repmat('KR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','O','O');
    C0_IDCTY(l,:) = repmat('SO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','P','S');
    C0_IDCTY(l,:) = repmat('PK',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','T','U');
    C0_IDCTY(l,:) = repmat('SD',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','V','W');
    C0_IDCTY(l,:) = repmat('SN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','X','X');
    C0_IDCTY(l,:) = repmat('MG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','Y','Y');
    C0_IDCTY(l,:) = repmat('JM',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'6','Z','Z');
    C0_IDCTY(l,:) = repmat('LR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','A','I');
    C0_IDCTY(l,:) = repmat('ID',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','J','N');
    C0_IDCTY(l,:) = repmat('JP',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','O','O');
    C0_IDCTY(l,:) = repmat('YE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','P','P');
    C0_IDCTY(l,:) = repmat('LS',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','Q','Q');
    C0_IDCTY(l,:) = repmat('MW',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','R','R');
    C0_IDCTY(l,:) = repmat('DZ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','S','S');
    C0_IDCTY(l,:) = repmat('SE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','T','Y');
    C0_IDCTY(l,:) = repmat('DZ',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'7','Z','Z');
    C0_IDCTY(l,:) = repmat('SA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','A','I');
    C0_IDCTY(l,:) = repmat('ID',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','J','N');
    C0_IDCTY(l,:) = repmat('JP',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','O','O');
    C0_IDCTY(l,:) = repmat('BW',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','P','P');
    C0_IDCTY(l,:) = repmat('BB',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','Q','Q');
    C0_IDCTY(l,:) = repmat('MV',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','R','R');
    C0_IDCTY(l,:) = repmat('GY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','S','S');
    C0_IDCTY(l,:) = repmat('SE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','T','Y');
    C0_IDCTY(l,:) = repmat('IN',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'8','Z','Z');
    C0_IDCTY(l,:) = repmat('SA',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','A','A');
    C0_IDCTY(l,:) = repmat('SM',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','B','D');
    C0_IDCTY(l,:) = repmat('IR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','E','F');
    C0_IDCTY(l,:) = repmat('ET',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','G','G');
    C0_IDCTY(l,:) = repmat('GH',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','H','H');
    C0_IDCTY(l,:) = repmat('MT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','I','J');
    C0_IDCTY(l,:) = repmat('ZM',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','K','K');
    C0_IDCTY(l,:) = repmat('KW',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','L','L');
    C0_IDCTY(l,:) = repmat('SL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','M','M');
    C0_IDCTY(l,:) = repmat('MY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','N','N');
    C0_IDCTY(l,:) = repmat('NP',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','O','T');
    C0_IDCTY(l,:) = repmat('CD',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','U','U');
    C0_IDCTY(l,:) = repmat('BI',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','V','V');
    C0_IDCTY(l,:) = repmat('SG',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','W','W');
    C0_IDCTY(l,:) = repmat('MY',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','X','X');
    C0_IDCTY(l,:) = repmat('RW',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'9','Y','Z');
    C0_IDCTY(l,:) = repmat('TT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','2','2');
    C0_IDCTY(l,:) = repmat('BW',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','3','3');
    C0_IDCTY(l,:) = repmat('TO',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','4','4');
    C0_IDCTY(l,:) = repmat('OM',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','5','5');
    C0_IDCTY(l,:) = repmat('BT',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'A','6','6');
    C0_IDCTY(l,:) = repmat('AE',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','2','2');
    C0_IDCTY(l,:) = repmat('NR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'C','3','3');
    C0_IDCTY(l,:) = repmat('AD',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'L','2','9');
    C0_IDCTY(l,:) = repmat('AR',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'P','4','4');
    C0_IDCTY(l,:) = repmat('NL',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'P','5','5');
    C0_IDCTY(l,:) = repmat('KP',nnz(l),1);

    l = ICOADS_NC_function_id2nat(ID,'S','2','3');
    C0_IDCTY(l,:) = repmat('BD',nnz(l),1);

    % ll_PT = ismember(C1_PT,[0 1 2 3 4 5 10 11 12 14 15 17]);
    ll_II = ismember(C0_II,[1]);
    C0_IDCTY(~ll_II,:) = nan;
    
    C0_IDCTY(isnan(C0_IDCTY)) = 32;
    C0_IDCTY = char(C0_IDCTY);
end
