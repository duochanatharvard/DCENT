% out_pnts = LME_function_grd2pnt(in_lon,in_lat,in_dy,in_grd,reso_x,reso_y,reso_t)
% This function returns value from grids given the spatial and temporal
% postion of samples.
% *
% 20180512: Note that if you are to take value from say 1-12 months, the input
% of reso_t should be 1:13 rather than 1:12, if matlab function discretize is used.

function out_pnts = LME_function_grd2pnt(in_lon,in_lat,in_dy,in_grd,reso_x,reso_y,reso_t)

    if numel(reso_x) == 1,

        in_lon = rem(in_lon + 360*5, 360);
        x = fix(in_lon/reso_x)+1;
        num_x = 360/reso_x;
        x(x>num_x) = x(x>num_x) - num_x;

        in_lat(in_lat>90) = 90;
        in_lat(in_lat<-90) = -90;
        y = fix((in_lat+90)/reso_y) +1;
        num_y = 180/reso_y;
        y(y>num_y) = num_y;

        if(isempty(in_dy))
            index = sub2ind(size(in_grd),x,y);
        else
            z = min(fix((in_dy-0.01)./reso_t)+1,size(in_grd,3));
            index = sub2ind(size(in_grd),x,y,z);
        end

        out_pnts = in_grd (index);
        out_pnts(abs(out_pnts)>1e8) = NaN;

   else

        x = discretize(in_lon,reso_x);
        y = discretize(in_lat,reso_y);

        if(isempty(in_dy))
            index = sub2ind(size(in_grd),x,y);
        else
            z = discretize(in_dy,reso_t);
            index = sub2ind(size(in_grd),x,y,z);
        end

        out_pnts = in_grd (index);
        out_pnts(abs(out_pnts)>1e8) = NaN;
    end

end
