function [A,Aprime,B,Bprime,D,Dprime] = refine(A,Aprime,B,Bprime,D,Dprime)

% either save and NO water borrow, or borrow from both
% (A>0 & B==0) |  (A<=0 & B<=0)
% test = (A>0 & B<0 & D==0);
test = (A>0 & B<0);
test1=test==0;
arbitrage=find(max((test1)));

% either don't disconnect, or disconnect but have some
% water borrowing (evaluate on subsetted B,D only)
B_arb = B(arbitrage,arbitrage);
D_arb = D(arbitrage,arbitrage);
dc_with_no_bal=find(max( (B_arb~=0 & D_arb==1) | (D_arb==0) ) );

% combined index — apply once instead of twice
idx = arbitrage(dc_with_no_bal);

A = A(idx,idx);
Aprime = Aprime(idx,idx);

B = B(idx,idx);
Bprime = Bprime(idx,idx);

D = D(idx,idx);
Dprime = Dprime(idx,idx);


        %%% HERE IS A LITTLE MORE AMBITIOUS ! NO CASES WITH D==1 AND
        %%% A>1/2 min A AND B>1/2 min B
        
% test_a = ( (A>.5*A(1,1) | B>.5*B(1,1)) & D==1);
% test1_a=test_a==0;
% arbitrage_a=find(max((test1_a)));
% 
% A = A(arbitrage_a,arbitrage_a);
% Aprime = Aprime(arbitrage_a,arbitrage_a);
% 
% B = B(arbitrage_a,arbitrage_a);
% Bprime = Bprime(arbitrage_a,arbitrage_a);
% 
% D = D(arbitrage_a,arbitrage_a);
% Dprime = Dprime(arbitrage_a,arbitrage_a);

