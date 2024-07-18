SATH_setup;

% -------------------------------------------------------------------------
% SUM all possible pairs and get the union of them
NET_pair        = zeros(0,2);
for ct_mem  = 1:N_rnd

    mem_id      = ct_mem - 1;

    fname       = SATH_IO(case_name,'net',mem_id,PHA_version);
    temp        = load(fname);
    net         = temp.NET_pair;
    l_rm        = net(:,2) == net(:,1) | ...
                  ismember(net(:,[2 1]),NET_pair,'rows') | ...
                  ismember(net(:,[1 2]),NET_pair,'rows');

    NET_pair    = [NET_pair; net(~l_rm,:)];
end

% -------------------------------------------------------------------------
% Calculate the list of stations to be processed 
N_pairs         = size(NET_pair,1);
N_pairs_sub     = ceil(N_pairs/N_sub);
pair_list       = (1:N_pairs_sub) + (sub_id-1) * N_pairs_sub;
pair_list(pair_list > N_pairs) = [];
disp(num2str(pair_list([1 end]),'Pair_list: %8.0f - %8.0f'))

% -------------------------------------------------------------------------
disp(repmat('#',1,100))
disp('2. SNHT and test for individual segment point')
fsave   = SATH_IO(case_name,'initial',sub_id,PHA_version);
D       = SATH_IO(case_name,'raw_data',0,PHA_version);
Para    = PHA_assign_parameters(PHA_version, 0, D);

if strcmp(PHA_version,'white') 
    BP_pair     = PHA_S2_initial_BP(D, NET_pair, pair_list, Para);
    save(fsave,'BP_pair','-v7.3');

elseif strcmp(PHA_version,'auto')

    Para.alpha_SNHT  = 0.05;
    Para             = PHA_func_set_para_SNHT_ts(Para);
    BP_pair_05  = PHA_S2_initial_BP(D, NET_pair, pair_list, Para);
    Para.alpha_SNHT  = 0.1;
    Para             = PHA_func_set_para_SNHT_ts(Para);
    BP_pair_10  = PHA_S2_initial_BP(D, NET_pair, pair_list, Para);
    Para.alpha_SNHT  = 0.2;
    Para             = PHA_func_set_para_SNHT_ts(Para);
    BP_pair_20  = PHA_S2_initial_BP(D, NET_pair, pair_list, Para);
    save(fsave,'BP_pair_05','BP_pair_10','BP_pair_20','-v7.3');
    
else
    [BP_pair,BP_pair_flt] = ...
                PHA_S2_initial_BP_GAPL(D,NET_pair,pair_list,Para);
    save(fsave,'BP_pair','BP_pair_flt','-v7.3');
end


