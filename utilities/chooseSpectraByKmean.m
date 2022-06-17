%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%-----------------------------------------------------

function chooseSpectraByKmean(sfd, tfd)
%   Usage:
%   This function is used to choose good spectra from a hyperspectral image
%   by using K-mean clustering
%
%   Input:
%       sfd:  source folder contains hyperspectral images
%       tfd:  target folder contains data afer doing K-mean clustering
%
%
%-----------------------------------------------------

% sfd = '..\..\database_upload\training\mat_norm\';
% tfd = '..\code_upload\training\kmean_400\';

% select all  mat files 
files = dir([sfd '*.mat']);
n = length(files);

options = statset('Display', 'iter', 'MaxIter', 100);
for k = 1:n

    load([sfd files(k).name]);
    [~,~,b] = size(tensor);
    % downsampling
    tensor = tensor(1:5:end, 1:5:end, :);    
    tensor = reshape(tensor, [], b);
    
    % K-means clustering to colect 400 reflectances
    [~,C] = kmeans(tensor, 400, 'options', options);
    clear tensor;
    tensor = C;
    save([tfd files(k).name], 'tensor', 'illumination');
    disp(['Finish to process image: ', num2str(k)]);
    disp('-------------');
end