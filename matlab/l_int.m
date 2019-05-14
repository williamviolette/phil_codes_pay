function [out]=l_int(X,int_size)

%out     = interp1(  (1:size(X,1))'  ,X, (int_size:int_size*size(X,1))'./int_size );

out     = interp1(  (1:size(X,1))'  ,X, linspace(1,size(X,1),int_size.*size(X,1))' );


