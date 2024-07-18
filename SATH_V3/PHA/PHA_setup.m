function PHA_setup

    dir = which('PHA_setup');
    dir = dir(1:find(dir == '/',1,'last'));
    
    addpath([dir,'CD_Computation/'])
    addpath([dir,'NaN_Computation/'])
    addpath([dir,'PHA_Functions/'])
    addpath([dir,'PHA_Evaluation/'])
    addpath([dir,'PHA_Development/'])
    addpath([dir,'GAPL_Functions/'])
end