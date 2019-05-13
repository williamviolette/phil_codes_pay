function [out]=l_int_n(X,n)



out     = interp1(  (1:size(X,1))'  ,X, (1:n)'./int_size );