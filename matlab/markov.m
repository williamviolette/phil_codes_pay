function [chain,state]=markov(T,n,s0,V);
%function [chain,state]=markov(T,n,s0,V);
%  chain generates a simulation from a Markov chain of dimension
%  the size of T
%
%  T is transition matrix
%  n is number of periods to simulate
%  s0 is initial state
%  V is the quantity corresponding to each state
%  state is a matrix recording the number of the realized state at time t
%
%
[r c]=size(T);
if nargin == 1;
  V=[1:r];
  s0=1;
  n=100;
end;
if nargin == 2;
  V=[1:r];
  s0=1;
end;
if nargin == 3;
  V=[1:r];
end;
%
if r ~= c;
  disp('error using markov function');
  disp('transition matrix must be square');
  return;
end;
%
% row normalization check removed (commented out, was empty loop)
[v1 v2]=size(V);
if v1 ~= 1 |v2 ~=r
  disp('error using markov function');
  disp(['state value vector V must be 1 x ',num2str(r),''])
  if v2 == 1 &v2 == r;
    disp('transposing state valuation vector');
    V=V';
  else;
    return;
  end;  
end
if s0 < 1 |s0 > r;
  disp(['initial state ',num2str(s0),' is out of range']);
  disp(['initial state defaulting to 1']);
  s0=1;
end;
%
%T
%rand('uniform');
X=rand(n-1,1);
cum=cumsum(T,2);  % cumulative transition probabilities (rxr)
state=zeros(r,n-1);  % preallocate
s_idx=s0;  % track state index directly
%
for k=1:length(X);
  state(s_idx,k)=1;
  ppi=[0 cum(s_idx,:)];  % direct row lookup instead of s'*cum
  s_idx=find((X(k)<=ppi(2:r+1)).*(X(k)>ppi(1:r)),1);
end;
chain=V*state;
