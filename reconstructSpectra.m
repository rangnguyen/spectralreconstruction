%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%-----------------------------------------------------
function [R_exact, L_exact, R_recon, L_recon, gfc_value, rmse_value] = ...
          reconstructSpectra(csf, reflect_model,illum_model, I_fn, flag)
%
%   Usage:
%   This function is used to recontruct spectral reflectance (R_recon) and 
%   spectral illumination (L_recon) from an RGB image with known 
%   reflectance model (reflect_model) and illumination model (illum_model)
%
%   Input:
%       csf:            camera sensitivity functions
%       reflect_model:  the model for reconstructing spectral reflectance
%       illum_model:    the model for estimating spectral illumination
%       I_fn:           the file name of image need to reconstruct
%       flag:           to show the waiting bar
%
%   Output:
%       R_recon:        reconstructed spectral reflectance
%       L_recon:        reconstructed spectral illumination
%       gfc_value:      GFC similarity metric
%       rmse_value:     RMSE metric
%
%-----------------------------------------------------
addpath('utilities');

load(I_fn);
[sw, sh, sb] = size(tensor);

% check tensor variable is 2 or 3 dimensions
if(sb == 1) 
    tensor = tensor';
else
    tensor = reshape(tensor, [], sb)';
end

% compute the RGB image based on the hyperspectral image S and the camera
% sensitivity functions C and normalize
RGB = csf * tensor;
RGB = RGB/max(max(RGB));


% reconstruct spectral reflectance and illumination
[R_recon, WB] = reconstructReflectance(reflect_model, RGB, flag);     
L_recon = estimateIllumination(illum_model, R_recon', RGB', csf, WB, flag);

% compute the ground truth reflectance (for measure the error only)
R_exact = diag(1./illumination) * tensor;
R_exact = R_exact / max(R_exact(:));
L_exact = illumination;

% compute the GFC similarity metric
gfc_value = gfc(R_exact, R_recon);
rmse_value = my_rmse(R_exact, R_recon);
% convert to original shape
R_exact = reshape(R_exact', sw, sh, sb);
R_recon = reshape(R_recon', sw, sh, sb);



