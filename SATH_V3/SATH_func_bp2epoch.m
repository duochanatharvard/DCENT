function bp_domain = SATH_func_bp2epoch(bp_detect,data)

    % mask all non breakpoints
    bp_detect(bp_detect == 0) = nan;

    % generate epoch for individual stations
    data_exist = ~isnan(data);
    bp_domain  = nan(size(bp_detect));
    for ct = 1:size(bp_detect,1)
        bp_domain(ct,:) = bp2epoch(bp_detect(ct,:), data_exist(ct,:));
    end
end

function bp_domain = bp2epoch(bp_detect, data_exist)

    N_yrm     = numel(bp_detect);

    bp_domain = nan(size(bp_detect));
    clear('bp_list','yrs')
    if any(isnan(bp_detect))
       bp_list = find(~isnan(bp_detect));
    else
       bp_list = find(bp_detect ~= 0);
    end

    if ~isempty(bp_list)
        ci = ones(size(bp_list)) * 12;

        % Find the starting and ending year of c.i. for each BP
        yrs = bp_list + [-1; 1] * ci;

        % If crossing happens, assign to the closer BP
        if yrs(1,1) < 1, yrs(1,1) = 1; end
        for ct = 1:numel(bp_list)-1
            if yrs(2,ct) > yrs(1,ct+1)
                mid         = round((yrs(2,ct) + yrs(1,ct+1))/2);
                yrs(2,ct)   = mid;
                yrs(1,ct+1) = mid+1;
            end
        end

        % Things cannot go beyond 1 and the length of data
        yrs(2,yrs(2,:)>N_yrm) = N_yrm;
        yrs(1,yrs(1,:)<1) = 1;

        % Generate the hitting zone for each BP
        for ct = 1:numel(bp_list)
            bp_domain(1,yrs(1,ct):yrs(2,ct)) = ct;
        end
    end
    bp_domain(data_exist == 0) = nan;
end
