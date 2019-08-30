function [A,Aprime,B,Bprime,D,Dprime] = refine(A,Aprime,B,Bprime,D,Dprime)

% either save and NO water borrow, or borrow from both
% (A>0 & B==0) |  (A<=0 & B<=0)                
% test = (A>0 & B<0 & D==0);
test = (A>0 & B<0);
test1=test==0;
arbitrage=find(max((test1)));

A = A(arbitrage,arbitrage);
Aprime = Aprime(arbitrage,arbitrage);

B = B(arbitrage,arbitrage);
Bprime = Bprime(arbitrage,arbitrage);

D = D(arbitrage,arbitrage);
Dprime = Dprime(arbitrage,arbitrage);

% either don't disconnect, or disconnect but have some
% water borrowing
dc_with_no_bal=find(max( (B~=0 & D==1) | (D==0) ) );

A = A(dc_with_no_bal,dc_with_no_bal);
Aprime = Aprime(dc_with_no_bal,dc_with_no_bal);

B = B(dc_with_no_bal,dc_with_no_bal);
Bprime = Bprime(dc_with_no_bal,dc_with_no_bal);

D = D(dc_with_no_bal,dc_with_no_bal);
Dprime = Dprime(dc_with_no_bal,dc_with_no_bal);


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

