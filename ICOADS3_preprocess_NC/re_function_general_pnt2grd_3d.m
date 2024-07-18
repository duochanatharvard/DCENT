function [var_grd,id_grd] = re_function_general_pnt2grd_3d(in_lon,in_lat,...
                        in_day,in_var,in_id,reso_x,reso_y,reso_t,mode,tname)


    % Reshape longitude and latitude --------------------------------------
    in_lon = rem(in_lon + 360*5, 360);
    in_lat(in_lat>90) = 90;
    in_lat(in_lat<-90) = -90;

    if(isempty(in_day))
        dimension = '2D';
    else
        dimension = '3D';
    end

    % Determine length in z direction -------------------------------------
    if (strcmp(dimension,'2D'))
    	dim = 1;
    else
        if strcmp(tname,'pentad')
            dim = fix(30/reso_t);
        elseif strcmp(tname,'hourly')
            dim = fix(24/reso_t);
        elseif strcmp(tname,'monthly')
            dim = fix(12/reso_t);
        elseif strcmp(tname,'seasonal')
            dim = fix(4/reso_t);
        end
    end

    % Allocate Working space ----------------------------------------------
    clear('var_grd','id_grd')
    if (isempty(in_id))
        var_grd = cell(360/reso_x,180/reso_y,dim);
    else
        var_grd = cell(360/reso_x,180/reso_y,dim);
        id_grd  = cell(360/reso_x,180/reso_y,dim);
    end

    % Assign subscript ----------------------------------------------------
    x = fix((in_lon)/reso_x)+1;
    x (x>(360/reso_x)) = x (x>(360/reso_x)) - (360/reso_x);
    y = fix((in_lat+90)/reso_y)+1;
    y (y>(180/reso_y)) = 180/reso_y;
    if (strcmp(dimension,'2D'))
        z = ones(size(x));
    else
        z = min(fix((in_day-0.01)/reso_t)+1,dim);
    end

    % Put points into grids -----------------------------------------------
    if (mode == 1)
        for i = 1:size(in_var,2)
            clear('temp','temp_kind')
            var_grd{x(i),y(i),z(i)} = [var_grd{x(i),y(i),z(i)} in_var(i,:)];
            if (isempty(in_id) == 0)
               id_grd{x(i),y(i),z(i)} = [id_grd{x(i),y(i),z(i)} ; in_id(i,:)];
            end
        end
    else
        [in_uni,~,J] = unique([x y z],'rows');
        for i = 1:size(in_uni,1)
            clear('logic')
            logic = J == i;
            var_grd{in_uni(i,1),in_uni(i,2),in_uni(i,3)} = in_var(logic,:);
            if (isempty(in_id) == 0)
                id_grd{in_uni(i,1),in_uni(i,2),in_uni(i,3)} = in_id(logic,:);
            end
        end
    end

    if (isempty(in_id))
        id_grd = [];
    end
end