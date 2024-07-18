function [U_out,D,V] = CDC_EOF(field,lat,interval)

    dim = 3;
    siz = size(field);

    lat = repmat(reshape(lat,1,siz(2)),siz(1),1,siz(3));
    field_deseason = CDC_detrend(field,dim,interval);

    lat = reshape(lat,siz(1)*siz(2),siz(3));
    field_deseason = reshape(field_deseason,siz(1)*siz(2),siz(3));

    field_weigh = field_deseason .* sqrt(cos(lat/180*pi));
    
    field_weigh(isnan(field_weigh)) = 0;

    [U,D,V] = svd(field_weigh);
    
    for ct = 1:size(V,1)
        U_out(:,:,ct) = reshape(U(:,ct),siz(1),siz(2));
    end
end

