function combined = AOI_func_combine_two_fields(field1,field2,w1,w2)

    l_isnan1 = isnan(field1);
    l_isnan2 = isnan(field2);

    field1(l_isnan1) = 0;
    field2(l_isnan2) = 0;

    w1(l_isnan1) = 0;
    w1(l_isnan2) = 1;

    w2(l_isnan1) = 1;
    w2(l_isnan2) = 0;

    combined = (field1.* w1 + field2 .* w2) ./ (w1 + w2);
    l_isnan = l_isnan1 & l_isnan2;
    combined(l_isnan) = nan;
end
