% =========================================================================
% Para = PHA_assign_parameters(PHA_version, do_random)
% 
% -------------------------------------------------------------------------
% [Input]
% PHA_version : 'white','auto','GAPL'
% do_random   : 0. default   1-X. randomly preturbed
% =========================================================================
function Para = PHA_assign_parameters(PHA_version, do_random, D)
    
    if do_random == 0
        Para = Parameter_default(PHA_version);
    else
        if strcmp(PHA_version(1:4),'auto') && do_random < 50
            rnd_list = [ 138    14    83    64    68    52   178    98   264 ...
                       118   106    54    31    35    50   166   218   134   143 ...
                       207   257    65    34   149     2   139    97   157   248 ...
                       293   153   114    49   223    88   291   137   192   241 ...
                        29   287   121   247   258    69   244    72   125    99] - 1;
        elseif strcmp(PHA_version,'GAPL') && do_random < 50
            rnd_list = [ 205   134    40   144    81   173   114   223   275 ...
                        83   128    56   107    84    14   262   282    31   290 ...
                        94    47    72   138   254   227   131   243   286   217 ...
                       209   291   263    80   300   229   284   158    85    59 ...
                       111    37   193   298    38   236   159   233    64   149] - 1;  
        else
            rnd_list = 1:do_random;
        end
        seed = rnd_list(do_random);
        % seed = do_random;
        Para = Parameter_random(PHA_version, seed);
    end

    % Assign test related lookup tables ...................................
    switch PHA_version
        case 'white'
            Para.SNHT_auto_list = -0.95:0.1:0.95;
            Para.SNHT_N_list = [5, 10, 20, 30, 40, 50, 60, 70, 80, 90, ...
                                                       100, 150, 200, 250];
            Para.SNHT_ts     = repmat([4.54, 5.70,6.95,7.65,8.10,8.45,...
                          8.65,8.80,8.95,9.05, 9.15,9.35,9.55,9.70]',1,20);
        case 'auto'
            Para             = PHA_func_set_para_SNHT_ts(Para);
    end

    % Other fixed parameters ..............................................
    Para.N_rnd              = 10;               % # of random realizations
    Para.reproduce_NOAA     = 0;                % use the same code as NOAA
    Para.N_itr              = 2;                % Number of iterations

    % Parameters based on data information ................................
    if exist('D','var')
        Para.Ns             = size(D.T(:,:),1);   % Number of stations
        Para.Nt             = size(D.T(:,:),2);   % Number of time steps
        Para.Fixed_para_yr_st = D.yr(1);          % The first year of data
    end

    % Parameter used for parallel computing ...............................
    Para.sub_siz = 3000;                          % Subset in each subjobs

end 

% *************************************************************************
function Para = Parameter_default(PHA_version)

    % Parameters about pickout neighbours ---------------------------------
    Para.NEIGH_CLOSE = 100;           % Number of neighbors in the initial pick out
                                      %     80/ 100/ 150/ 200
    Para.NEIGH_CORR  = '1 diff';      % How to evaluate correlation
                                      %     'near','corr','1 diff'
                                      %     when using near, CORR_LIM is not used
    Para.CORR_LIM    = 0.1;           % Threshold of correlation for neighbors
                                      %     0.1/ 0.5/ 0.7
    Para.MIN_STNS    = 7;             % Mimumum number with coincident data
                                      %     5/ 7/ 9
    Para.NEIGH_FINAL = 40;            % Numer of beighbors final
                                      %     20/ 40/ 60/ 80
    Para.NUM4COV     = 60;            % minimum overlap as neighbors
                                      %     60/ 120/ 180

    % Parameters about identifying BPs  -----------------------------------
    if strcmp(PHA_version,'white')
        Para.alpha_SNHT  = 0.05;      % threshold of SNHT test  0.05/ 0.1/ 0.2
    elseif strcmp(PHA_version,'auto')
        Para.alpha_SNHT  = 0.1;       % threshold of SNHT test
    end

    if strcmp(PHA_version(1:4),'GAPL')
        Para.try_trend  = 1;
    end

    % Parameters about attributing and confirming BPs  --------------------
    Para.AMPLOC_PCT  = 0.075;         % confladed c.i.
                                      %     0.05/ 0.075/ 0.1

    % Parameters about correction  ----------------------------------------
    Para.ADJ_MINLEN  = 18;            % Combination of BP after BIC
                                      %     18 / 24 / 36/ 48
    Para.ADJ_MINPAIR = 2;             % Number of stations required to estimate biases
                                      %     2/ 3/ 4/ 5
    Para.ADJ_MIN_SIDE = 18;           % Minimum number of homo data around a bp to estimate adjustment
                                      %     24/ 36/ 60/ 120
    Para.ADJ_EST     = 'median';      % Use which variable to calculate correction
                                      %     median/ mean/ Qavg
    Para.ADJ_CONS    = 24;            % correct the combined effect of X months

    Para.do_rnd      = 0;             % do not preturb adj estimate
end

% *************************************************************************
function Para = Parameter_random(PHA_version,do_random)

    rng(do_random*100);
    
    % Parameters about pickout neighbours .................................
    list = [120 100 150 200]; temp = randperm(numel(list)); 
    Para.NEIGH_CLOSE = list(temp(1));              % Number of neighbors in the initial pick out
                       
    temp = randperm(3);
    switch temp(1)
        case 1, Para.NEIGH_CORR  = '1 diff';       % How to evaluate correlation
        case 2, Para.NEIGH_CORR  = 'corr';
        case 3, Para.NEIGH_CORR  = 'near';         % when using near, CORR_LIM is not used
    end
           
    list = [0.1 0.3 0.5];  temp = randperm(numel(list)); 
    Para.CORR_LIM    = list(temp(1));              % Threshold of correlation for neighbors

    list = [5 7 9];        temp = randperm(numel(list));                          
    Para.MIN_STNS    = list(temp(1));              % Mimumum number with coincident data

    list = [40 40 60 80];  temp = randperm(numel(list)); 
    Para.NEIGH_FINAL = list(temp(1));              % Numer of beighbors final
    
    list = [60 120 180];   temp = randperm(numel(list)); 
    Para.NUM4COV     = list(temp(1));              % minimum overlap as neighbors

    % Parameters about identifying BPs ....................................
    if strcmp(PHA_version,'white') || strcmp(PHA_version,'auto')
        list = [0.05 0.1 0.2];   temp = randperm(numel(list)); 
        Para.alpha_SNHT  = list(temp(1));          % threshold of SNHT test
    end
        
    if strcmp(PHA_version(1:4),'GAPL')
        Para.try_trend  = 1;
    end

    % Parameters about attributing and confirming BPs .....................
    list = [0.05 0.075 0.1]; temp = randperm(numel(list)); 
    Para.AMPLOC_PCT  = list(temp(1));              % confladed c.i.
    
    % Parameters about correction .........................................
    list = [18 24 36 48];   temp = randperm(numel(list)); 
    Para.ADJ_MINLEN = list(temp(1));               % Number of stations required to estimate biases

    list = [2 3 4 5];   temp = randperm(numel(list)); 
    Para.ADJ_MINPAIR = list(temp(1));              % Number of stations required to estimate biases
                                                   % to make a correction estimate
    
    % list = [24 36 60 120];   temp = randperm(numel(list)); 
    Para.ADJ_MIN_SIDE = Para.ADJ_MINLEN;           % Minimum number of homo data around a bp to estimate adjustment

    list = [18 24];   temp = randperm(numel(list)); 
    Para.ADJ_CONS = list(temp(1));                 % Minimum number of homo data around a bp to estimate adjustment

    temp = randperm(3);
    switch temp(1)
        case 1, Para.ADJ_EST  = 'median';          % Use which variable to calculate correction
        case 2, Para.ADJ_EST  = 'mean';
        case 3, Para.ADJ_EST  = 'Qavg';
    end

    list = 1:10;   temp = randperm(numel(list)); 
    Para.do_rnd  = list(temp(1));                  % preturb adj estimate
end