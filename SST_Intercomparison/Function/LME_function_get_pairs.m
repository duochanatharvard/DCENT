% out_var = LME_function_get_pairs(in_var,index,lon_index,lat_index,time_index,reso_s,reso_t,x_lim,y_lim,t_lim,mode)
% This function find pairs of points that has a distance within a specific
% criteria. It break the points down into ifferent grid boxes, and than
% loops over grids to find the point that are close to each other
%
% ------------------------------- INPUT -----------------------------------
% Input data and indicators of groups longitude, latitude, universial time;
% 1. The spatial resolution of grids, you can also assign the temporal
% 2. resolution, but it will not make any difference in this version of code.
% 3. The distance you want in longitude, latitude, and universial time.
%
% ------------------------------- OUTPUT ----------------------------------
% The output is the pair of points or records that you want.
% And the information of index of that pair, the information can be:
% Different decks, countries, measurement methods, call signs, and any
% arbitrary combination of these variables.

function [out_var,out_index] = LME_function_get_pairs(in_var,index,lon_index,lat_index,time_index,reso_s,reso_t,c_lim,y_lim,t_lim,mode)

    in_lon = in_var(lon_index,:);
    in_lat = in_var(lat_index,:);

    [var_grd,id_grd] = LME_function_pnt2grd_3d (in_lon,in_lat,[],in_var,index,reso_s,reso_s,[],2,[]);

    count = 0;
    out_var = [];
    out_index = [];

    for i=1:size(var_grd,1)
        if rem(i,12)==0,
            disp(['processing lon: ',num2str(i*reso_s)]);
        end
        for j=1:size(var_grd,2)

            clear('temp_1','temp_2','temp_3','temp_4','temp_5')
            clear('temp_index_1','temp_index_2','temp_index_3','temp_index_4','temp_index_5')

            temp_1 = var_grd{i,j};
            temp_index_1 = id_grd{i,j};

            if(i == size(var_grd,1))
                temp_2 = var_grd{1,j};
                temp_index_2 = id_grd{1,j};
            else
                temp_2 = var_grd{i+1,j};
                temp_index_2 = id_grd{i+1,j};
            end

            if(j == size(var_grd,2))
                temp_3 = [];
                temp_index_3 = [];
                temp_4 = [];
                temp_index_4 = [];
                temp_5 = [];
                temp_index_5 = [];
            else
                temp_3 = var_grd{i,j+1};
                temp_index_3 = id_grd{i,j+1};

                if(i == size(var_grd,1))
                    temp_5 = var_grd{1,j+1};
                    temp_index_5 = id_grd{1,j+1};
                else
                    temp_5 = var_grd{i+1,j+1};
                    temp_index_5 = id_grd{i+1,j+1};
                end

                if(i == 1)
                    temp_4 = var_grd{size(var_grd,1),j+1};
                    temp_index_4 = id_grd{size(var_grd,1),j+1};
                else
                    temp_4 = var_grd{i-1,j+1};
                    temp_index_4 = id_grd{i-1,j+1};
                end
            end

            clear('temp','temp_index','temp_grd')
                % temp_grd is just to test if those records are from the target grid
            temp = [temp_1 temp_2 temp_3 temp_4 temp_5];
            temp_index = [temp_index_1;temp_index_2;temp_index_3;temp_index_4;temp_index_5];
            temp_grd = [ones(1,size(temp_1,2)) zeros(1,size([temp_2 temp_3 temp_4 temp_5],2))];
            clear('temp_1','temp_2','temp_3','temp_4','temp_5')
            clear('temp_index_1','temp_index_2','temp_index_3','temp_index_4','temp_index_5')

            index_uni = unique(temp_index,'rows');

            for ct1 = 1:size(index_uni,1)
                for ct2 = ct1+1:size(index_uni,1)

                    clear('logic1','logic2')
                    logic1 = all(temp_index == repmat(index_uni(ct1,:),size(temp_index,1),1),2);
                    logic2 = all(temp_index == repmat(index_uni(ct2,:),size(temp_index,1),1),2);

                    clear('temp_ct1','temp_ct2','temp_grd_ct1','temp_grd_ct2')
                    temp_ct1 = temp(:,logic1);
                    temp_ct2 = temp(:,logic2);
                    temp_grd_ct1 = temp_grd(:,logic1);
                    temp_grd_ct2 = temp_grd(:,logic2);

                    if mode == 1,
                        clear('dc','dy','dt','logic')
                        dc = distance(repmat(temp_ct1(lat_index,:) ,nnz(logic2),1),  repmat(temp_ct1(lon_index,:) ,nnz(logic2),1),...
                            repmat(temp_ct2(lat_index,:)',1,nnz(logic1)),  repmat(temp_ct2(lon_index,:)',1,nnz(logic1))).*111;
                        dy = abs(repmat(temp_ct1(lat_index,:),nnz(logic2),1)-repmat(temp_ct2(lat_index,:)',1,nnz(logic1)));
                        dt = abs(repmat(temp_ct1(time_index,:),nnz(logic2),1)-repmat(temp_ct2(time_index,:)',1,nnz(logic1)));
                        logic = dc <= c_lim & dy <= y_lim & dt <= t_lim;
                    else
                        clear('dx','dy','dt','logic');
                        dx = repmat(temp_ct1(lon_index,:),nnz(logic2),1)-repmat(temp_ct2(lon_index,:)',1,nnz(logic1));
                        dx = abs(rem(dx+900,360)-180);
                        dy = abs(repmat(temp_ct1(lat_index,:),nnz(logic2),1)-repmat(temp_ct2(lat_index,:)',1,nnz(logic1)));
                        dt = abs(repmat(temp_ct1(time_index,:),nnz(logic2),1)-repmat(temp_ct2(time_index,:)',1,nnz(logic1)));
                        logic = dx <= c_lim & dy <= y_lim & dt <= t_lim;
                    end

                    clear('logic_grd')
                    logic_grd =  repmat(temp_grd_ct1,nnz(logic2),1) + repmat(temp_grd_ct2',1,nnz(logic1)) ~= 0;

                    clear('ds','ds_list_2','ds_list_1')
                    [ds_list_2,ds_list_1] = find(logic & logic_grd);
                    % *************************************************************
                    if(isempty(ds_list_2)==0)
                        out_var = [out_var [temp_ct1(:,ds_list_1); temp_ct2(:,ds_list_2)]];
                        out_index = [out_index; repmat([index_uni(ct1,:) index_uni(ct2,:)],numel(ds_list_2),1)];
                    end
                end
            end
        end
    end

    [out_var,I] = unique(out_var','rows');
    out_var = out_var';
    out_index = out_index(I,:);
end
