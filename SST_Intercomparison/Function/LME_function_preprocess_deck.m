% kind_out = LME_function_preprocess_deck(kind,do_connect)
function kind_out = LME_function_preprocess_deck(kind,P)

    % ********************
    % Change DE into DD **
    % ********************
    % if ~isfield(P,'mute_read')
    %     disp('Combine east and west germany')
    % end
    % logic_1 = ismember(double(kind(:,1:2)),['DD'],'rows');
    % kind(logic_1,2) = 'E';

    % ********************
    % Change UK into GB **
    % ********************
    if ~isfield(P,'mute_read')
        disp('Combine UK and GB')
    end
    logic_1 = ismember(double(kind(:,1:2)),['UK'],'rows');
    kind(logic_1,1:2) = repmat('GB',nnz(logic_1),1);

    % *****************************************
    % Change no counrty into their deck name **
    % *****************************************
    if ~isfield(P,'mute_read')
        disp('Assign nations with deck information')
    end
    logic_1 = ismember(double(kind(:,1:2)),['  '],'rows');
    kind(logic_1,1:2) = [kind(logic_1,3) kind(logic_1,3)];

    % ****************
    % connect decks **
    % ****************
    if ~isfield(P,'mute_read')
        disp('Connect decks')
    end
    if isfield(P,'do_connect')
        if P.do_connect == 1
            kind = LME_function_connect_deck(double(kind),P);
        end
    end

    kind_out = kind;

    if 0   % Testing dataset
        kind = ['DE',128; 'DD',128; 'UK',122; 'UK',122;
                'GB',135; '  ',192; '  ',254; 'JP',118;
                'JP',762; 'UK',233];
    end
end
