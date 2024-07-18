% Return spheric harmonics of Yx0 as a function of latitude
% for Cowtan et al (2018) fitting
function [pattern_1,pattern_2] = LME_funtion_SH(lat)

    theta = pi/2-lat/180*pi;
    pattern_1 = cos(theta);
    pattern_2 = 3.*cos(theta).^2 - 1;

end