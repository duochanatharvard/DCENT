% [region_mask_out,region_name] = CDF_region_mask(reso)
function [region_mask_out,region_name_out] = CDF_region_mask(reso,mode)

    % cd /Users/zen/Program/function/
    load weigh.dat
    for i = 1:25
        region_mask(:,:,i) = weigh((i-1)*36+1:i*36,:);
    end
    region_mask(:,:,2) = region_mask(:,:,1) + region_mask(:,:,2);

    % This is to seperate the Greenland from the Eastern Canada
    a = region_mask(:,:,10);
    a(34:36,:) = 0;
    a(:,61:end) = 0;
    region_mask(:,:,23) = a;
    
    a = region_mask(:,:,10);
    a(1:36,1:61) = 0;
    region_mask(:,:,24) = a;
    
    region_mask = region_mask(:,:,[2:9 23 24 11:22]);

    [land_mask,~] = CDF_land_mask(reso,2);
    [lon1,lat1] = meshgrid(reso/2:reso:360,-90+reso/2:reso:90);
    [lon0,lat0] = meshgrid(2.5:5:360,-87.5:5:90);
    
    for i = 1:size(region_mask,3)
        temp = interp2([lon0-360 lon0 lon0+360],[lat0 lat0 lat0],[region_mask(:,:,i) region_mask(:,:,i) region_mask(:,:,i)],lon1,lat1,'linear');
        region_mask_out(:,:,i) = (land_mask > 0 & temp > 0)';
    end
    
    region_name = {'AUS','NSA','SSA','MEX','WNA','CNA','ENA','ALK','ECA','GLD','MID',...
        'NEU','WAF','EAF','SAF','NAF','OCT','EAS','SAS','WAS','CAS','SIB'};
    
    for i = 1:22
        region_name_out(i,:) = region_name{i}; 
    end

    if mode == 2, % in mode 2, large ocean basin average
        region_mask_temp(:,:,1) = nansum(region_mask(:,:,[1]),3);
        region_mask_temp(:,:,2) = nansum(region_mask(:,:,[2 3]),3);
        region_mask_temp(:,:,3) = nansum(region_mask(:,:,[4:9]),3);
        region_mask_temp(:,:,4) = nansum(region_mask(:,:,[11:12]),3);
        region_mask_temp(:,:,5) = nansum(region_mask(:,:,[11 13:16]),3);
        region_mask_temp(:,:,6) = nansum(region_mask(:,:,[17:22]),3); 

        temp = region_mask_temp(:,:,4);
        temp([1:25],[1:72]) = 0;
        region_mask_temp(:,:,4) = temp;

        temp = region_mask_temp(:,:,5);
        temp(26:end,:) = 0;
        region_mask_temp(:,:,5) = temp;

        temp = region_mask_temp(:,:,6);
        temp([31:36],[10:20]) = 1;
        region_mask_temp(:,:,6) = temp;

        temp = region_mask_temp(:,:,3);
        temp([30:36],[39:60]) = 1;
        region_mask_temp(:,:,3) = temp;
        
        region_mask = region_mask_temp;

        [land_mask,~] = CDF_land_mask(reso,2,[],0);
        
        [lon1,lat1] = meshgrid(reso/2:reso:360,-90+reso/2:reso:90);
        [lon0,lat0] = meshgrid(2.5:5:360,-87.5:5:90);
        
        clear('region_mask_out')
        for i = 1:size(region_mask,3)
            temp = interp2([lon0-360 lon0 lon0+360],[lat0 lat0 lat0],...
                [region_mask(:,:,i) region_mask(:,:,i) region_mask(:,:,i)],lon1,lat1,'linear');
            region_mask_out(:,:,i) = (land_mask == 1 & temp > 0)';
        end
    end
end