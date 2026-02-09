function [v,decis]=opt_loop(v,util1,util2,util3,util4,beta,prob,metric)

while metric > 1e-7

      [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,size(util1,1)));
      [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,size(util1,1)));
      [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,size(util1,1)));
      [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,size(util1,1)));
      tdecis=[ tdecis1' tdecis2' tdecis3' tdecis4' ];
      tv=[ tv1' tv2' tv3' tv4' ];

  metric=max(max(abs((tv-v)./tv)));
  v=tv;
  decis=tdecis;
end