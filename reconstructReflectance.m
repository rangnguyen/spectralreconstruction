%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%-----------------------------------------------------

function [R, WB] = reconstructReflectance(reflect_model, I, flag)
%   Usage:
%   This function is used to recontruct spectral reflectance from an RGB
%   image (I) with known reflectance model (reflect_model)
%
%   Input:
%       reflect_model:  the model for reconstructing reflectance
%       I:              RGB image
%       flag:           flag to show waiting bar or not
%
%   Output:
%       R:              spectral reflectance
%
%-----------------------------------------------------
addpath('utilities');

% set maximum number of RGB triplets reconstructed by RBF at the same time
maxNUM = 22000;

% compute the white point by using shades of grey(SoG) method [25] with 
% Minkowsky norm of order 5
WB=mean(I.^5,2).^(1/5);
WB=WB/max(WB);  
% apply white-balancing for RGB image
I = diag(1./WB)*I;    
% normalize    
I = I/max(max(I));

N = size(I,2);
R = zeros(31, N);
n = ceil(N / maxNUM);

if flag == 1
    h = waitbar(0,'Reconstructing Reflectance. Please wait...');
    for i = 1:n
        is = (i-1)* maxNUM + 1;
        ie = min(i*maxNUM, N);
        R(:, is:ie) = sim(reflect_model, I(:, is:ie));
        waitbar(i / n);
    end
    close(h);
else
   for i = 1:n
    is = (i-1)* maxNUM + 1;
    ie = min(i*maxNUM, N);
    R(:, is:ie) = sim(reflect_model, I(:, is:ie));
   end
end

