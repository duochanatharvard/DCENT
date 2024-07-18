%    m_proj_nml(kk,region)
%    region=[south,north,east,west,radio]
%
%    'Stereographic',...             % 1        'Orthographic',...              % 2     
%    'Azimuthal Equal-area',...      % 3        'Azimuthal Equidistant',...     % 4     
%    'Gnomonic',...                  % 5        'Satellite',...                 % 6
%    'Albers Equal-Area Conic',...   % 7        'Lambert Conformal Conic',...   % 8   
%    'Mercator',...                  % 9        'Miller Cylindrical',...        %10
%    'Equidistant Cylindrical',...   %11        'Oblique Mercator',...          %12
%    'Transverse Mercator',...       %13        'Sinusoidal',...                %14    
%    'Gall-Peters',...               %15        'Hammer-Aitoff',...             %16  
%    'Mollweide',...                 %17        'Robinson',...                  %18    
function m_proj_nml(kk,region)
% region=[south,north,east,west,radio]
 project={...    
    'Stereographic',...             % 1    
    'Orthographic',...              % 2     
    'Azimuthal Equal-area',...      % 3     
    'Azimuthal Equidistant',...     % 4     
    'Gnomonic',...                  % 5
    'Satellite',...                 % 6
    'Albers Equal-Area Conic',...   % 7     
    'Lambert Conformal Conic',...   % 8   
    'Mercator',...                  % 9 
    'Miller Cylindrical',...        %10
    'Equidistant Cylindrical',...   %11
    'Oblique Mercator',...          %12
    'Transverse Mercator',...       %13 
    'Sinusoidal',...                %14    
    'Gall-Peters',...               %15     
    'Hammer-Aitoff',...             %16  
    'Mollweide',...                 %17    
    'Robinson',...                  %18     
    'UTM'};                         %19 
 % ================set projection=======================================
 if kk<=5;         % 1-5 ????? rad??: <degree|????[lon,lat]>
  m_proj(project{kk},'lon',mean(region(3:4)),'lat',mean(region(1:2)),'rad',region(5));
 elseif kk==6       % 6 alt ???? ??
  m_proj(project{kk},'lon',mean(region(3:4)),'lat',mean(region(1:2)),...
      'rad',4.5,'alt',2) 
 elseif kk==7||kk==8  % 7-8 Conic Projection ???? ??
     m_proj(project{kk},'lon',[region(3),region(4)],'lat',[region(1),region(2)]);
 elseif (kk>=9 && kk<=15 && kk~=12) || kk==19 % 9-11 &13-15 &19 ??????
     m_proj(project{kk},'lon',[region(3),region(4)],'lat',[region(1),region(2)]);
 elseif kk==12        %12 ????
     m_proj(project{kk},'lon',[mean(region(3:4)), mean(region(3:4))],...    
         'lat',[region(2),region(1)],'dir','vertical');
 elseif kk>=16 && kk<= 18 % ????
     m_proj(project{kk});
 end