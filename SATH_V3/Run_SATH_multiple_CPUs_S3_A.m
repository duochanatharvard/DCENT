SATH_setup;

% *************************************************************************
% Load data 
% *************************************************************************
D           = SATH_IO(case_name,'raw_data',mem_id,PHA_version);
sta_list    = 1:size(D.T,1);   

Para        = PHA_assign_parameters(PHA_version, mem_id, D);

% *************************************************************************
% Load network
% *************************************************************************
fname       = SATH_IO(case_name,'net',mem_id,PHA_version);
load(fname,'NET_pair','NET_att','NET_adj');

% *************************************************************************
% Load initial BPs from individual subsets
% *************************************************************************
BP_pair     = zeros(0,11);
for sub_id  = 1:N_sub % ceil(size(NET_pair,1) / ceil(size(NET_pair,1) ./ N_sub))
    try
        if strcmp(PHA_version(1:4),'GAPL')
            fname   = SATH_IO(case_name,'initial',sub_id, 'GAPL');
        else
            fname   = SATH_IO(case_name,'initial',sub_id, PHA_version);
        end
        temp        = load(fname);
    
        if strcmp(PHA_version,'white')
            bp      = temp.BP_pair;
        elseif strcmp(PHA_version,'auto')
            switch Para.alpha_SNHT
                case 0.05, bp  = temp.BP_pair_05;
                case 0.1,  bp  = temp.BP_pair_10;
                case 0.2,  bp  = temp.BP_pair_20;
            end
        elseif strcmp(PHA_version,'GAPL')
            bp  = temp.BP_pair;
        elseif strcmp(PHA_version,'GAPL_filter')
            bp  = temp.BP_pair_flt;
        end
    
        l_use = ismember(bp(:,[1 2]),NET_pair,'rows') | ...
                ismember(bp(:,[2 1]),NET_pair,'rows');
        BP_pair = [BP_pair; bp(l_use,:)];
    catch
        disp('This file does not exist')
    end
end

% *************************************************************************
% Do later steps
% *************************************************************************
tic;
disp(repmat('#',1,100))
disp('3. Attribute breakpoints')
BP_att  = PHA_S3_attribution_all_fast(BP_pair, Para);
toc;

disp('save data...')
fsave  = SATH_IO(case_name,'attribute',mem_id, PHA_version);
disp(fsave)
save(fsave,'Para','BP_pair','BP_att','-v7.3');