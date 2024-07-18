% out = CDC_pnt2glbmean(in,lon,lat,reso)
% The first dimension is a list of points
% This function handles NaN 

function out = CDC_pnt2glbmean(in,lon,lat,reso)

    if ~exist('reso','var'), reso = 5; end

    if size(in,2) ~= 1
        
        clear('out')
        sz  = size(in);
        if numel(sz) == 2
            out = nan(sz(2:end),1);
        else
            out = nan(sz(2:end));
        end
        
        if numel(size(in)) == 2 % -----------------------------------------
            for ct1 = 1:size(in,2)
                out(ct1) = CDC_pnt2glbmean(in(:,ct1),lon,lat,reso);
            end
        elseif numel(size(in)) == 3 % -------------------------------------
            for ct1 = 1:size(in,2)
                for ct2 = 1:size(in,3)
                    out(ct1,ct2) = CDC_pnt2glbmean...
                                              (in(:,ct1,ct2),lon,lat,reso);
                end
            end
            
        elseif numel(size(in)) == 4 % -------------------------------------
            for ct1 = 1:size(in,2)
                for ct2 = 1:size(in,3)
                    for ct3 = 1:size(in,4)
                        out(ct1,ct2,ct3) = CDC_pnt2glbmean...
                                          (in(:,ct1,ct2,ct3),lon,lat,reso);
                    end
                end
            end
            
        elseif numel(size(in)) == 5 % -------------------------------------
            for ct1 = 1:size(in,2)
                for ct2 = 1:size(in,3)
                    for ct3 = 1:size(in,4)
                        for ct4 = 1:size(in,5)
                            out(ct1,ct2,ct3,ct4) = CDC_pnt2glbmean...
                                      (in(:,ct1,ct2,ct3,ct4),lon,lat,reso);
                        end
                    end
                end
            end
        end
        
    else % ----------------------------------------------------------------

        lon(lon<0) = lon(lon<0) + 360;
        lon_id = discretize(lon,0:reso:360);
        lat_id = discretize(lat,-90:reso:90);
        [grid_uni,~,J] = unique([lon_id,lat_id],'rows');
        grid_lat = grid_uni(:,2)*reso-reso/2-90;

        JJ    = J;
        JJ(isnan(in)) = nan;
        w_lat = cos(grid_lat/180*pi);
        c     = hist(JJ,1:1:max(J));
        w_lat(c==0) = 0;
        w_lat = w_lat ./ nansum(w_lat);

        W = nan(size(JJ));
        for ct = 1:max(J)
            if nnz(JJ == ct) > 0
                W(J == ct) = w_lat(ct)./nnz(JJ == ct);
            else
                W(J == ct) = 0;
            end
        end
        W(isnan(in)) = 0;

        in(isnan(in)) = 0;
        if ~all(W == 0)
            out = W'*in;
        else
            out = nan;
        end
    end
    
    % W2 = zeros(size(grid_uni,1),size(in,1));
    % for ct = 1:max(J)
    %     if nnz(JJ == ct) > 0
    %         W2(ct,J == ct) = 1./nnz(JJ == ct);
    %     else
    %         W2(ct,J == ct) = 0;
    %     end
    % end
    % W2(repmat(isnan(in'),size(grid_uni,1),1)) = 0;
    % 
    % 
    %  out2 = W2*in;
    % 
    % A = zeros(72,36);
    % for ct = 1:size(out2,1)
    %     A(grid_uni(ct,1),grid_uni(ct,2)) = w_lat(ct);
    % end
    % 
    % A(A == 0) = nan;
    % CDC_mask_mean(A,-87.5:5:87.5,ones(size(A)))
    
end