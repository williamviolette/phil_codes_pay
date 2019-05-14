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
