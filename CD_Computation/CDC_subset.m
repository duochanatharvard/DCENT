% output = CDC_subset(field,dim,list)
% 
% CDC_subset subsets a field incertain dimensions using a list
% For practical useage, the function goes to 7 dimensions
% 
% Last update: 2018-08-09

function output = CDC_subset(field,dim,list)
        
    switch dim,
        case 1,
            output = field(list,:,:,:,:,:,:);
        case 2,
            output = field(:,list,:,:,:,:,:);
        case 3,
            output = field(:,:,list,:,:,:,:);
        case 4,
            output = field(:,:,:,list,:,:,:);
        case 5,
            output = field(:,:,:,:,list,:,:);            
        case 6,
            output = field(:,:,:,:,:,list,:);  
        case 7,
            output = field(:,:,:,:,:,:,list); 
    end
end