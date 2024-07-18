% [WM,NUM] = CDC_pnt2grd(lon,lat,day,data,reso_x,reso_y,reso_t)
% input size insensitive

function [WM,NUM] = CDC_pnt2grd(lon,lat,day,data,reso_x,reso_y,reso_t)

    if size(lon,1) == 1, lon = lon'; end
    if size(lat,1) == 1, lat = lat'; end
    if size(data,1) ~= size(lat,1), data = data'; end

    lon = rem(lon + 360*5, 360);
    x = fix(lon/reso_x)+1;
    num_x = 360/reso_x;
    x(x>num_x) = x(x>num_x) - num_x;

    lat(lat>90) = 90;
    lat(lat<-90) = -90;
    y = fix((lat+90)/reso_y) +1;
    num_y = 180/reso_y;
    y(y>num_y) = num_y;

    if isempty(day)
        z = ones(size(x));
    else
        if size(day,1) == 1, day = day'; end
        z = fix((day-0.01)./reso_t)+1; 
    end
    
    WM  = nan(num_x, num_y, max(z), size(data,2));
    NUM = nan(num_x, num_y, max(z));
    [in_uni,~,J] = unique([x y z],'rows');
    
    % Gridding ------------------------------------------------------------
    for ct = 1:size(in_uni,1)
        
        clear('l')
        l           = J == ct;
        temp        = data(l,:);
        
        i           = in_uni(ct,1);
        j           = in_uni(ct,2);
        k           = in_uni(ct,3);
        
        NUM(i,j,k)  = nnz(l);
        
        % Averaging can be substituted into more advanced algorithms 
        WM(i,j,k,:) = nanmean(temp,1);
        
    end
    
    WM  = squeeze(WM);
    NUM = squeeze(NUM);

end