% out_var = HM_function_mean_period(in_var,period)
% This function returns the mean value of a vector that has certain period
% For example: hours in a day, longitude on a sphere
% the input should be an m by n matrix, where n is the number of groups and
% m is the number of samples to be averaged in each group
% group1.sample1   group2.sample1   group3.sample1   group4.sample1
% group1.sample2   group2.sample2   group3.sample2   group4.sample2
% Note that this version only works for pairs that are close to each other
% when the difference are big, the algorithum fails because of it can not tell
% the difference between one or zero cicles.

function out_var = LME_function_mean_period(in_var,period)

    angles = in_var/period*360;

    last = angles(1,:);
    sum = angles(1,:);

    for i=2:size(angles,1)
        diff = mod(angles(i,:)-angles(i-1,:)+180*5,360)-180;
        last = last + diff;
        sum = sum + last;
    end

    avg = mod(sum/size(angles,1), 360);

    out_var = avg/360 * period;

end
