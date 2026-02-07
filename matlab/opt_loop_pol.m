function [v,decis]=opt_loop_pol(v,decis,util1,util2,util3,util4,beta,prob,metric)

prob_t = prob';  % precompute transpose once (4x4)

i = 0;
while metric > 1e-7
i = i + 1
      cont = beta .* (v * prob_t);  % Nx4: all continuation values at once

      [tv1,tdecis1]=max(util1 + cont(:,1));  % Nx1 broadcasts to NxN
      [tv2,tdecis2]=max(util2 + cont(:,2));
      [tv3,tdecis3]=max(util3 + cont(:,3));
      [tv4,tdecis4]=max(util4 + cont(:,4));
      tdecis=[ tdecis1' tdecis2' tdecis3' tdecis4' ];
      tv=[ tv1' tv2' tv3' tv4' ];

  metric=max(max(abs((decis-tdecis)./tdecis)));
  v=tv;
  decis=tdecis;
end