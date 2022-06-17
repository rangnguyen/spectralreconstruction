%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%----------------------------------------------------- 
function [reflectance_model, illumination_model] = training(camera_name, csf, fd)
%
%   Usage:
%   This function is used to train the model for spectral reflectance and
%   spectral illumination
%
%   Input:
%       camera_name:    name of the camera
%       csf:            camera sensitivity functions
%       fd:             the folder of training images
%
%   Output:
%       reflectance_model:  the model for spectral reflectance
%       illumination_model: the model for spectral illumination
%
%-----------------------------------------------------
addpath('utilities');

fns = dir([fd '*.mat']);
n = length(fns);

% if the k-mean_400 folder empty then do K-means clustering
if n == 0
    tfd = fd;
    sfd = '..\database_upload\training\mat_norm\';
    chooseSpectraByKmean(sfd, tfd);
    fns = dir([fd '*.mat']);
    n = length(fns);
end

RGB_array=[];
RGB_WB_array=[];
Reflect_array=[];
Illums=[];
WP_array=[];

for ii=1:n
    disp(['Image number: ' num2str(ii)]);
    
    % load a hyperspectral image from .mat file. After loading, we have two
    % variables:
    %   S: contains a hyperspectral image M x N x 31 where M, N is the size
    %   of the image and 31 is the number of bands (400-700 nm)
    %   WP: contains a spectra of illumination which illuminate the scene
    load([fd fns(ii).name]);
    B = tensor';
    
    % compute the RGB image based on the hyperspectral image S and the camera
    % sensitivity functions C
    RGB= csf * B;

    % compute the white point by using shades of grey(SoG) method [25] with 
    % Minkowsky norm of order 5
    WB=mean(RGB.^5,2).^(1/5);WB=WB/max(WB);
    % apply white-balancing for RGB image
    RGB_WB=diag(1./WB)*RGB;  
    
    % compute reflectance
    Reflect=diag(1./illumination)*B;
    
    % normalize RGB
    RGB = RGB/max(RGB(:));
    RGB_array=[RGB_array RGB];
    
    % Normalize RGB_WB
    RGB_WB=RGB_WB/max(RGB_WB(:));
    RGB_WB_array=[RGB_WB_array RGB_WB];   
    
    % normalize white point
    illumination = illumination / max(illumination);
    Illums = [Illums illumination'];
    
    % normalize reflectance
    Reflect = Reflect / max(Reflect(:));
    Reflect_array=[Reflect_array Reflect];
    
    WP_array=[WP_array WB];
end


%Model White-balance RBF
disp('================================================');
disp('RBF - White-balancing reflectance model');
disp('------------------------------------------------');
reflectance_model = newrb(RGB_WB_array, Reflect_array, 0, 1, 50, 1);
save(['models\' camera_name '_reflectance_model'],'reflectance_model');
%}

% Model-Illum PCA
disp('================================================');
disp('PCA illumination model');
disp('------------------------------------------------');
[Y,~,~,Psi] = mypca(Illums,4);
illumination_model.M = Psi;
illumination_model.PC = Y;
save(['models\' camera_name '_illumination_model'],'illumination_model');



