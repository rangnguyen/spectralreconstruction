%-----------------------------------------------------
%   Author : Rang Nguyen
%   Date : 2014. 08. 18.
%   School of Computing
%   National University of Singapore
%
%-----------------------------------------------------
function rmse_value = my_rmse(A, B)
%   Usage:
%   This function is used to measure the error (RMSE)
%   between two signals
%
%   Input:
%       X:  first signal
%       Y:  second signal
%
%   Output:
%       rmse_value:  RMSE value 
%
%-----------------------------------------------------
B = adjust_and_normalize(A, B);
C = (A - B) .^ 2;
rmse_value = mean(C(:)).^0.5;

function B = adjust_and_normalize(A, B)
B(B < 0) = 0;
C = mean(A, 1); 
D = mean(B, 1) + 0.00001; %avoid divided by zero

B = B .* repmat(C./D, size(A,1), 1);
