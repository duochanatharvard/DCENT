function Para = PHA_func_set_para_SNHT_ts(Para)

    file = ['SNHT_thresholds.mat'];

    load(file);
    Para.SNHT_N_list    = N_list;
    Para.SNHT_auto_list = auto_list;

    switch Para.alpha_SNHT
        case .001,   Para.SNHT_ts = ts999;
        case .01,    Para.SNHT_ts = ts990;
        case .05,    Para.SNHT_ts = ts950;
        case .1,     Para.SNHT_ts = ts900;
        case .15,    Para.SNHT_ts = ts850;
        case .2,     Para.SNHT_ts = ts800;
        case .25,    Para.SNHT_ts = ts750;
        case .3,     Para.SNHT_ts = ts700;
        case .35,    Para.SNHT_ts = ts650;
        case .4,     Para.SNHT_ts = ts600;
        case .5,     Para.SNHT_ts = ts500;
    end
    

end
