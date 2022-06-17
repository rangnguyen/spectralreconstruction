%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%-----------------------------------------------------
function gfc_value = gfc(X,Y)
%   Usage:
%   This function is used to measure the similarity (goodness-of-fit coefficient)
%   between two signals
%
%   Input:
%       X:  first signal
%       Y:  second signal
%
%   Output:
%       gfc_value:  similarity value (gfc_value)
%
%-----------------------------------------------------
gfc_value = mean(sum(abs(X.*Y),1) ./ (sum(X.^2,1).^0.5 .* sum(Y.^2,1) .^0.5));
