% out = CDF_num2str(num,len)
% len: total length of output that would be filled with zeros...
function out = CDF_num2str(num,len)

    out = repmat('0',1,len);
    a = num2str(num);
    out(end-size(a,2)+1:end) = a;
end
