% [mask,topo,coast] = CDF_land_mask(reso_x,method,reso_y,threshold)
% reso: resolution
% method: 1. average  2. interpolation
% when the reso is not a integer, method can only be 2.
% threshold: below this number is considered as ocean ...
function [mask,topo,coast] = CDF_land_mask(reso_x,method,reso_y,threshold)

    if exist('reso_y','var') == 0 || isempty(reso_y);
        reso_y = reso_x;
    end

    if exist('threshold','var') == 0 || isempty(threshold);
        threshold = 0;
    end

    m_proj_nml(11,[0.5 359.5 -90 90]);
    [altitude,lon0,lat0] = m_elev([0.5 359.5 -90 90]);

    [lon1,lat1] = meshgrid(reso_x/2:reso_x:360,-90+reso_y/2:reso_y:90);
    if strcmp(method,'interp') || method == 2,
      topo = interp2([lon0-360 lon0 lon0+360],[lat0 lat0 lat0],...
                     [altitude altitude altitude],lon1,lat1,'linear');
    else
        for i = 1:round(180/reso_y)
            for j = 1:round(360/reso_x)
                topo(i,j) = nanmean(nanmean(altitude((i-1)*reso_y+1:i*reso_y,(j-1)*reso_x+1:j*reso_x),1),2);
            end
        end
    end
    mask = topo > threshold;

    logic = (mask(3:end,:) == 0 | mask(1:end-2,:) == 0 | mask(2:end-1,[3:end 1 2]) == 0 |...
        mask(2:end-1,[end-1:end 1:end-2]) == 0) & mask(2:end-1,:) == 1;

    coast = false(size(mask));
    coast(2:end-1,:) = logic;
end
