SATH_setup;
D                   = SATH_IO(case_name,'raw_data',mem_id,PHA_version); 
Para                = PHA_assign_parameters(PHA_version, mem_id, D);  
sta_list            = 1:size(D.T,1); 
[NET_pair, NET_att, NET_adj] = PHA_S1_get_neighbors(D, sta_list, Para); 
fsave   = SATH_IO(case_name,'net',mem_id,PHA_version);
if ~isfile(fsave)
    save(fsave,'NET_pair','NET_att','NET_adj','Para','-v7.3');
end
