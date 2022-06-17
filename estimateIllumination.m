%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%-----------------------------------------------------

function L = estimateIllumination(illum_model, R, I, C, WP, flag)
%   Usage:
%   This function is used to estimate the spectral illumination when we
%   know the spectral reflectance (R), camera sensitivity functions (C), and
%   RGB image.
%
%   Input:
%       illum_model:    the basics for spectral illumination
%       R:              spectral reflectance
%       C:              camera sensitivity functions
%       I:              RGB image
%
%   Output:
%       L:              spectral illumination
%
%-----------------------------------------------------

global A B Illum Wf Cf
Wf = WP / (sum(WP .^ 2) .^ 0.5);
Cf = C;
Illum = illum_model;
maxIter = 3;

if flag == 1
    h = waitbar(0,'Reconstructing Illumination. Please wait...');
end
for k = 1:maxIter
    n = size(R, 1);

    S1 = R .* repmat(C(1,:), n, 1);
    S2 = R .* repmat(C(2,:), n, 1);
    S3 = R .* repmat(C(3,:), n, 1);

    St = [S1;S2;S3];
    It = reshape(I, [], 1);

    A = St * Illum.PC;
    B = It - St * Illum.M;


    x0 = zeros(size(Illum.PC, 2),1);

    options = optimset('Algorithm','active-set', 'Display', 'off', 'MaxIter', 100,...
                        'TolFun', 0, 'DiffMinChange', 1e-5, 'TolX', 0);

    warning('off','all');
    [X, ~] = fminunc(@myfun,x0, options);
    L = Illum.PC * X + Illum.M;

    % Remove oulier
    Ip = R*diag(L)*(C');
    E = sum((Ip - I).^2,2).^0.5;
    E = E - mean(E);
    stdE = std(E);
    idx = abs(E) < 3 * stdE;
    R = R(idx,:);
    I = I(idx,:);
    
    if flag == 1
        waitbar(k / maxIter);
    end
end

if flag == 1
    close(h);
end

function f = myfun(x)
global A B Illum Wf Cf
L = Illum.PC * x + Illum.M;
nWP = Cf * L;
n_nWP = nWP / (sum(nWP .^ 2) .^ 0.5);
alpha1 = 10^10;
alpha2 = 10^10;
beta1 = 0.02;
beta2 = 0.02;
f = norm(A*x - B)/size(A,1) +  alpha1*neg_fun(L)/size(L,1)+ alpha2*one_fun(L)/size(L,1)+ ... 
    beta1*norm(n_nWP - Wf)/3 + beta2*norm(diff(L))/30;

function f = neg_fun(x)
f = sum(x(x < 0) .^2);

function f = one_fun(x)
f = sum(x(x > 1) .^2);