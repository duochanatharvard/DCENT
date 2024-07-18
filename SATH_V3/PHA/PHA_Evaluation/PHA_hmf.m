function [hist_hmf, BP_dmn, l_hit, l_hit2] = PHA_hmf(BP_true,ADJ,Data,epoch)

    Nt              = size(Data,2);

    % if pairwise comparison, perform extra pretreatment to input ---------
    if size(BP_true,2) > 3
        [uni, ~,J]      = unique([ADJ(:,1) ADJ(:,2); ...
                                  BP_true(:,1) BP_true(:,2)],'rows');
        ADJ(:,1)        = J(1:size(ADJ,1));
        ADJ(:,2)        = ADJ(:,3);
        BP_true(:,1)    = J((size(ADJ,1)+1):end);
        BP_true(:,2)    = BP_true(:,3);
        Data            = ones(max(J),Nt);
        l_rm            = ADJ(:,9) == 1 | ADJ(:,4) == 2;
        I               = sub2ind([max(J) Nt], ADJ(l_rm,1), ADJ(l_rm,2));
        Data(I)         = nan;
        ADJ             = ADJ(~l_rm,:);
    end

    % Start the analysis --------------------------------------------------
    Ns              = size(Data,1);
    uid             = 1:size(ADJ,1);
    BP_dmn          = zeros(Ns,Nt);

    % Find the first time step --------------------------------------------
    I               = sub2ind([Ns Nt],ADJ(:,1),ADJ(:,2));
    BP_dmn(I)       = uid;
    
    % Do later time steps -------------------------------------------------
    ct              = 0;
    flag            = 1;
    l_track         = true(size(ADJ,1),1);
    tim_ed          = ADJ(:,2);
    while flag
        ct              = ct + 1;
        t_tg            = ADJ(:,2)+ct;
        t_tg(t_tg > Nt) = Nt;
        I               = sub2ind([Ns Nt],ADJ(:,1),t_tg);
        l_nan           = isnan(Data(I)) & l_track;
        l_track(~l_nan) = false;
        if nnz(l_nan)
            BP_dmn(I(l_nan)) = uid(l_nan);
            tim_ed(l_nan)       = t_tg(l_nan);
        else
            flag = 0;
        end
    end
    
    % expands on two sides ------------------------------------------------
    lst1                    = 1:epoch;
    lst2                    = -lst1;
    lst(1:2:numel(lst1)*2)  = lst1;
    lst(2:2:numel(lst2)*2)  = lst2;
    for ct = lst
        if ct > 0
            t_tg            = tim_ed + ct;
        else
            t_tg            = ADJ(:,2) + ct;
        end
        t_tg(t_tg > Nt)     = Nt;
        t_tg(t_tg < 1)      = 1;
        I                   = sub2ind([Ns Nt],ADJ(:,1),t_tg);
        l_nocp              = BP_dmn(I) == 0;
        BP_dmn(I(l_nocp))   = uid(l_nocp);
    end
    
    % Determine hit miss or false alarm -----------------------------------
    I       = sub2ind([Ns Nt],BP_true(:,1),BP_true(:,2));
    hit     = BP_dmn(I);
    l_hit   = hit > 0;
    l_hit2  = ismember(uid,hit(l_hit));

    % Calculate histogram -------------------------------------------------
    if size(BP_true,2) == 3
        if size(ADJ,2) >= 10    % Adjustment
            hist_hmf = [hist(BP_true(l_hit,3),-4.95:0.1:4.95)' ...
                        hist(BP_true(~l_hit,3),-4.95:0.1:4.95)' ...
                        hist(ADJ(~l_hit2,10),-4.95:0.1:4.95)'];
        elseif size(ADJ,2) == 9 % Combined BP
            hist_hmf = [hist(BP_true(l_hit,3),-4.95:0.1:4.95)' ...
                        hist(BP_true(~l_hit,3),-4.95:0.1:4.95)' ...
                        hist(ADJ(~l_hit2,6),-4.95:0.1:4.95)'];
        else                    % Key
            hist_hmf = [hist(BP_true(l_hit,3),-4.95:0.1:4.95)' ...
                        hist(BP_true(~l_hit,3),-4.95:0.1:4.95)' ...
                        hist(ADJ(~l_hit2,3),-4.95:0.1:4.95)'];
        end
    else                        % Pairwise
        hist_hmf = [hist(BP_true(l_hit,4),-4.95:0.1:4.95)' ...
                    hist(BP_true(~l_hit,4),-4.95:0.1:4.95)' ...
                    hist(ADJ(~l_hit2,5),-4.95:0.1:4.95)'];
    end
end