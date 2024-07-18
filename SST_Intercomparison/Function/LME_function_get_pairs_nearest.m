% out_var = LME_function_get_pairs_nearest(in_var,index,lon_index,lat_index,time_index,reso_s,reso_t,x_lim,y_lim,t_lim,mode)
% 
% This function find closest neibour within a specific criteria. 
% It returns pairs being identified and measurements that have neighbour
% but are not yet paired, which can be called interiatively until no pair
% is left.
% 
% The pairing function break points down into ifferent grid boxes, and then
% loops over grids to find the closest point within each grid.
%
% This function is developed because previous algorithum identifies too
% many pairs for ship level analysis, which does not make sense from both
% running and storage perspectives
% 
% Last update: 2021-06-25

function [in_var,index,pair_temp] = LME_function_get_pairs_nearest...
           (in_var,index,lon_index,lat_index,time_index,reso_s,c_lim,t_lim)

    in_uid = in_var(1,:);
    uid_close = nan(size(in_uid));
    in_lon = in_var(lon_index,:);
    in_lat = in_var(lat_index,:);

    % The code below is to find the nearest neighbor from different agents
    % that also lies within the criteria of pairins
    [var_grd,id_grd] = LME_function_pnt2grd_3d (in_lon,in_lat,[],in_var,index,reso_s,reso_s,[],2,[]);

    
    for i=1:size(var_grd,1)
        if rem(i,12)==0,
            disp(['processing lon: ',num2str(i*reso_s)]);
        end
        for j=1:size(var_grd,2)

            clear('temp_1','temp_2','temp_3','temp_4','temp_5')
            clear('temp_index_1','temp_index_2','temp_index_3','temp_index_4','temp_index_5')

            ct_i = [i-1 i i+1]; 
            ct_i(ct_i < 1) = ct_i(ct_i < 1) + 360/reso_s;
            ct_i(ct_i > 360/reso_s) = ct_i(ct_i > 360/reso_s) - 360/reso_s;
            
            ct_j = [j-1 j j+1]; ct_j(ct_j>180/reso_s) = []; ct_j(ct_j<1)=[];

            clear('var_center','id_center','var_neighbor','id_neighbor')
            var_center = var_grd{i,j};
            id_center  = id_grd{i,j};
            
            if ~isempty(var_center)
            
                var_temp = var_grd(ct_i,ct_j);
                id_temp  = id_grd(ct_i,ct_j);
                var_neighbor = [];
                id_neighbor  = [];
                for ct = 1:numel(var_temp)
                    var_neighbor = [var_neighbor var_temp{ct}];
                    id_neighbor  = [id_neighbor; id_temp{ct}];
                end
                clear('var_temp','id_temp')

                for ct = 1:size(var_center,2)

                    clear('dc','dt','ds','var_neighbor_temp')
                    dc = distance(var_center(lat_index,ct),var_center(lon_index,ct),...
                         var_neighbor(lat_index,:),var_neighbor(lon_index,:)).*111;
                    dt = abs(var_center(time_index,ct)-var_neighbor(time_index,:));
                    ds = dc./111 + dt/12;
                    ds(dc > c_lim | dt > t_lim) = 999;
                    l = ismember(id_neighbor,id_center(ct,:),'rows')';
                    ds(l) = 999;

                    var_neighbor_temp = var_neighbor(:,ds<999);
                    ds = ds(ds<999);

                    if ~isempty(ds)
                        temp = var_neighbor_temp(1,find(ds == min(ds),1));
                        uid_target = var_center(1,ct);
                        uid_close(in_uid == uid_target) = temp;
                    end
                end
            end
        end
    end
    
    % Throw away points that do not have neighbors
    l_remove = isnan(uid_close);
    in_var(:,l_remove)  = [];
    index(l_remove,:)   = [];
    uid_close(l_remove) = [];
    uid_start = in_var(1,:);
    
    [l,pst]     = ismember(uid_close,uid_start);
    uid_over    = uid_close(pst);
    index_close = index(pst,:);
    
    l_pair = uid_start == uid_over;

    % get rid of half of the pairs that are redundent
    [~,~,J] = unique([index(l_pair,:); index_close(l_pair,:)],'rows');
    index_pair = [J(1:nnz(l_pair)) J(nnz(l_pair)+1:2*nnz(l_pair))];
    l_take = index_pair(:,1) < index_pair(:,2);
    
    pair_temp = [uid_start(l_pair); uid_close(l_pair)];
    pair_temp(:,~l_take) = [];
    
    % subset data for another round
    in_var(:,l_pair) = [];
    index(l_pair,:)  = [];
    
end
