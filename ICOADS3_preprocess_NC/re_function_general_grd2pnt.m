function out_pnts = re_function_general_grd2pnt(in_lon,in_lat,...
                                        in_dy,in_grd,reso_x,reso_y,reso_t)

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
end