% do_debug :: debug flag
% -1: suppress all debuging outputs
% 0: only show lists at the end of steps
% 1: only show things in step 1
% 2: only show things in step 2
% 3: only show things in step 3
% 4: only show things in step 4
% 5: only show things in step 5
% 6: only show things in step 6
% 9: output everything

% do_debug_more_detail
% whether to output more detailed things, such as figures

if isfield(Para,'do_debug')
    do_debug  = Para.do_debug;
else
    do_debug  = -1;
end

if isfield(Para,'do_debug_more_detail')
    do_debug_more_detail  = Para.do_debug_more_detail;
else
    do_debug_more_detail  = 0;
end

if isfield(Para,'reproduce_NOAA')
    reproduce_NOAA  = Para.reproduce_NOAA;
else
    reproduce_NOAA  = 0;
end
