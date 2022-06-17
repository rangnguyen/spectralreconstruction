%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%-----------------------------------------------------

function run(fd_training_images, fd_testing_images, camera_name)
%   Usage:
%   This is a main file to run
%   To run this file, please set value for the following variables
%       fd_training_images: folder which contains the hyperspectral images for training
%       fd_testing_images:  folder which contains the hyperspectral images for testing
%       camera_name:        name of camera for synthetic
%
%-----------------------------------------------------

addpath('utilities');

if(~exist('fd_training_images', 'var')) 
    fd_training_images = 'data\training\kmean_400\';
end

if(~exist('fd_testing_images', 'var'))
    fd_testing_images = 'data\testing\sample_20000\';
end

if(~exist('camera_name', 'var'))
    camera_name = 'Canon_1D_Mark_III';
end

%% load camera sensitivity functions
wavelengths = 400:10:700;
load(['data\cameras_cmf\' camera_name]);
csf=(interp1(F.',CRF.',wavelengths))';

%% Training step
% check if models were already learned or not
if (exist(['models\' camera_name '_reflectance_model.mat'], 'file') && ...
    exist(['models\' camera_name '_illumination_model.mat'], 'file'))
    
    load(['models\' camera_name '_reflectance_model.mat']);
    load(['models\' camera_name '_illumination_model.mat']);
else
    [reflectance_model, illumination_model] = training(camera_name, csf, fd_training_images);
end

%% Recontruction and testing
fns = dir([fd_testing_images '*.mat']);
n = length(fns);

for i = 1:n
    [R_exact, L_exact, R_recon, L_recon, gfc_value, rmse_value] = ...
    reconstructSpectra(csf, reflectance_model, illumination_model, [fd_testing_images fns(i).name], 0);
    disp(['Image: ' num2str(i) ', GFC: ' num2str(gfc_value) ', RMSE: ' num2str(rmse_value)]);
end

