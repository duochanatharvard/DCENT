function logic_out = ICOADS_NC_function_id2nat(ID,F,S1,S2,T1,T2)

    if nargin == 4
        digit_2 = 1;
    else
        digit_2 = 0;
    end

    ID = double(ID);
    F = double(F);
    S1 = double(S1);
    S2 = double(S2);
    ref = S1:S2;
    N = numel(ref);
    if digit_2 == 0
        T1 = double(T1);
        T2 = double(T2);
        ref3 = T1:T2;
        N3 = numel(ref3);
    end

    logic_1 = ID(:,1) == double(F);
    temp_1  = repmat(ID(:,2),1,N);
    temp_2  = repmat(ref,size(ID,1),1);
    logic_2 = any(temp_1 == temp_2,2);
    if digit_2 == 0
        temp_1  = repmat(ID(:,3),1,N3);
        temp_2  = repmat(ref3,size(ID,1),1);
        logic_3 = any(temp_1 == temp_2,2);
    end

    if digit_2 == 1
        logic_out = logic_1 & logic_2;
    else
        logic_out = logic_1 & logic_2 & logic_3;
    end
end
