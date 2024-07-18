% [WM,ST,NUM] = LME_function_gridding
%           (lon,lat,t,filed,id,rexo_x,reso_y,reso_t,mode,tname,is_w,is_un)
function [WM,ST,NUM] = LME_function_gridding(lon,lat,t,filed,id,...
                                     rexo_x,reso_y,reso_t,mode,tname,is_w,is_un)

      [var_grd,~] = LME_function_pnt2grd_3d(lon,lat,t,filed,...
                                           id,rexo_x,reso_y,reso_t,mode,tname);

      [WM,ST,NUM] = LME_function_grd_average(var_grd,is_w,is_un);
end
