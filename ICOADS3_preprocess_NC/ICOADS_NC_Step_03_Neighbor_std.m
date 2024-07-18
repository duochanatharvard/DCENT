% ICOADS_NC_Step_03_Neighbor_std(id, redo)
%
%  For each month, the standard deviation of SST computed in
% "ICOADS_NC_Step_02_WM" are pulled and averaged across all available years
% to compute a neighbor-wise standard deviation of SST.
% The standard deviations are squared and weighed by number of samples in each pentad.
%
% requires m_map toolbox and "m_proj_nml" function
%
% Last update: 2024-04-10

function ICOADS_NC_Step_03_Neighbor_std(id,redo)

    if ~exist('id','var')
        varname = 'SST';
    elseif id == 1
        varname = 'SST';
    else
        varname = 'NMAT';
    end

    % Set direcotry of files  ---------------------------------------------
    dir_load  = ICOADS_NC_OI('WM');
    dir_save  = ICOADS_NC_OI('Mis');
    file_save = [dir_save,'Buddy_std_',varname,'.mat'];

    if ~isfile(file_save) || redo == 1
        % Target output file does not exist or redo the analysis
        % Merge files ---------------------------------------------------------
        clear('STD_save')
        for mon = 1:12
    
            clear('ST_sum','NUM_sum');
            disp(['Month ',num2str(mon),' started!']);
            clear('cmon')
            cmon = '00';
            cmon(end-size(num2str(mon),2)+1:end) = num2str(mon);
    
            for yr = 1850:2014
    
                file = ['ICOADS_R3.0.0_',num2str(yr),'-',cmon,'_WM_',varname,'.mat'];
                clear('ST','NUM');
                load([dir_load,file],'ST');
                load([dir_load,file],'NUM');
                ST_sum(:,:,(yr-1850)*6+[1:6]) = ST;
                NUM_sum(:,:,(yr-1850)*6+[1:6]) = NUM;
            end
    
            clear('ST','NUM');
            ST = ST_sum;
            NUM = NUM_sum;
            ST(NUM == 1) = NaN;
            NUM(isnan(ST))=0;
    
            % using a complecated method to smooth the field
            clear('ST_mean','temp_int','temp_ratio');
            ST_mean = sqrt(nansum(ST.^2 .* NUM,3) ./ nansum(NUM,3));
            temp_int = re_function_general_infilling(smooth2CD(ST_mean));
    
            % a section of amplifying variance estimates is removed...
    
            STD_save(:,:,mon) = temp_int;
    
            clear('NUM_sum','ST_sum','ST','NUM','yr')
        end
    
        save(file_save,'STD_save','-v7.3');

    else
        disp('Target File exist, skip...');
    end
end


% An infiller -------------------------------------------------------------
function [temp_int,MASK] = re_function_general_infilling(in_var)

    reso_x = 360 /size(in_var,1);
    reso_y = 180 /size(in_var,2);
    lon = reso_x/2:reso_x:360;
%     addpath('/n/home10/dchan/m_map/');
    m_proj_nml(1,[1 1 1 1 1 1]);
    [altitude,~,~] = m_elev([1 359 -90 90]);
    altitude = altitude';
    if reso_x ~= 1
        for i = 1:360/reso_x
            topo_temp(i,:) = nanmean(altitude((i-1)*reso_x+1:i*reso_x,:),1);
        end
    else
        topo_temp = altitude;
    end
    if reso_y ~= 1
        for j = 1:180/reso_y
            topo(:,j) = nanmean(topo_temp(:,(j-1)*reso_x+1:j*reso_x),2);
        end
    else
        topo = topo_temp;
    end
    MASK = topo < 10;
    clear('altitude','topo_temp','topo');

    clear('temp_int')
    temp_int = nan(size(in_var));
    for i = 1:size(in_var,2)
        temp = in_var(:,i)';
        logic = ~isnan(temp);
        if nnz(logic)
            temp_int(:,i) = interp1([lon(logic)-360 lon(logic) lon(logic)+360],...
                [temp(logic) temp(logic) temp(logic)],lon);
        end
    end

    temp_int(MASK == 0) = NaN;
    temp_int = smooth2CD(temp_int);
end

% A 2D smoother -----------------------------------------------------------
function output = smooth2CD(input,dim,do_longitude,iter)

    if ~exist('dim','var')
        dim = 3;
    end

    if isempty(dim)
        dim = 3;
    end

    if ~exist('do_longitude','var')
        do_longitude = 1;
    end

    if ~exist('iter','var')
        iter = 1;
    end

    if rem(dim,2)~=1
        error('smoother dimension must be odd');
    end

    x = ones(dim,dim);
    for ct = 1:iter
        x = conv2(x,x);
    end
    x = x / nansumCD(x(:));

    for ct = 1:size(input,3)

        clear('M','SM')
        if do_longitude == 1
            M = [input(:,:,ct); input(:,:,ct); input(:,:,ct)];
        else
            M = input(:,:,ct);
        end

        MM = ones(size(M));
        MM(isnan(M)) = NaN;
        SM = conv2CD(x,M) ./ conv2CD(x,MM);

        output(:,:,ct) = SM;
    end

    n = (length(x)-1)/2;
    output = output(n+1:end-n,n+1:end-n);

    if do_longitude == 1

        N = size(input,1);
        output = output(N+1:2*N,:);
    end

    output(isnan(input)) = NaN;
end

% summation igoring NaN ---------------------------------------------------
function output = nansumCD(input,dim)

    if  nargin == 1 && size(input,1) ~= 1
        dim = 1;
    elseif nargin == 1 && size(input,1) == 1
        dim = 2;
    end

    input_raw = input;
    input(isnan(input)) = 0;

    output = sum(input,dim);
    logic  = all(isnan(input_raw),dim);
    output(logic) = NaN;
end

% 2D convolution igoring NaN ----------------------------------------------
function output = conv2CD(input_x,input_y)

    input_x(isnan(input_x)) = 0;
    input_y(isnan(input_y)) = 0;

    output = conv2(input_x,input_y);
end
