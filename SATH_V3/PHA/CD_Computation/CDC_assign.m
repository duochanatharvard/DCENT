% output = CDC_assign(input,field,dim,list)
% 
% CDC_assign assign value of field to input matrix in incertain dimensions
%           according to a list
% For practical useage, the function goes to 7 dimensions
% 
% Last update: 2018-08-09

function target = CDC_assign(target,field,dim,list)
    
    switch dim,
        case 1,
            target(list,:,:,:,:,:,:) = field;
        case 2,
            target(:,list,:,:,:,:,:) = field;
        case 3,
            target(:,:,list,:,:,:,:) = field;
        case 4,
            target(:,:,:,list,:,:,:) = field;
        case 5,
            target(:,:,:,:,list,:,:) = field;            
        case 6,
            target(:,:,:,:,:,list,:) = field;  
        case 7,
            target(:,:,:,:,:,:,list) = field; 
    end
end