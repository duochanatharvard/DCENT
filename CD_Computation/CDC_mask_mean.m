% [out,out_std,out_num] = CDC_mask_mean(input,lat,mask,un)
% 
% CDC_mask_mean compute the domain average by a mask and weigh grid boxes
% by the cosine of their latitude
% 
% There is no special dimensionality requirement for lat
% but for mask, it should match the first two dimension of input
% 
% Last update: 2018-08-10

function [out,out_std,out_num] = CDC_mask_mean(input,lat,mask)

    size_temp = size(input);

    if(min(size(lat)) == 1)
        lat = repmat(reshape(lat,1,numel(lat)),size(input,1),1);
    end

    weigh = cos(lat*pi/180);

    WEIGH = repmat(weigh,[1 1 size_temp(3:end)]);
    MASK  = repmat(mask ,[1 1 size_temp(3:end)]);

    WEIGH(MASK == 0) = 0;
    input(MASK == 0) = NaN;
    WEIGH(isnan(input)) = 0;

    out = nansum(nansum(input.*WEIGH,1),2)./nansum(nansum(WEIGH,1),2);

    out = squeeze(out);
    out_std = 'not_used_but_kept_to_be_compatible_with_previous_codes';
    out_num = squeeze(nansum(nansum(isnan(input)==0,1),2));

end


% function [out,out_std,out_num] = CDC_mask_mean(input,lat,mask,un)
% 
%     if  nargin < 4
%         un_on = 0;
%     else
%         un_on = 1;
%     end
% 
%     size_temp = size(input);
% 
%     if(min(size(lat)) == 1)
%         lat = repmat(reshape(lat,1,numel(lat)),size(input,1),1);
%     end
% 
%     weigh = cos(lat*pi/180);
% 
%     WEIGH = repmat(weigh,[1 1 size_temp(3:end)]);
%     MASK  = repmat(mask ,[1 1 size_temp(3:end)]);
% 
%     if un_on,
%         weigh_2 = (1 ./ (real(un) + 1));
%         WEI     = MASK .* WEIGH .* weigh_2;
%         IN      = input .* WEIGH .* weigh_2;
%     else
%         WEI   = MASK .* WEIGH;
%         IN    = input .* WEIGH;
%     end
% 
%     IN(MASK == 0) = NaN;
%     WEI(isnan(IN)) = 0;
% 
%     out = nansum(nansum(IN,1),2)./nansum(nansum(WEI,1),2);
% 
%     if un_on,
%         un(isnan(IN)) = NaN;
%         out_std = squeeze(sqrt( nansum(nansum(un.^2 .* WEI.^2 ,1),2) ./ (nansum(nansum(WEI ,1),2).^2)));
%     else
%         clim = repmat(out,[size_temp(1:2) ones(1,size(size_temp,2)-2)]);
%         out_std = squeeze(sqrt( nansum(nansum((IN - clim).^2 .* WEI ,1),2) ./...
%             (nansum(nansum(WEI ,1),2) - nansum(nansum(WEI.^2 ,1),2)./nansum(nansum(WEI ,1),2))  ));
%     end
% 
%     out = squeeze(out);
%     out_num = squeeze(nansum(nansum(isnan(IN)==0,1),2));
% 
% end
