function [rev_goal,lend_cost,delinquency_cost,visit_cost,wwr]=cost_calc(controls,r_lend,visit_price,marginal_cost,p1,p2,s)

    lend_cost        = mean(abs(controls(:,3))).*r_lend;
    delinquency_cost = mean(abs(controls(controls(:,6)==s,3)))./s ;
    visit_cost       = mean( visit_price.*(size(controls([0 ;  controls(1:(size(controls,1)-1),3)]<0 & controls(:,5)>2,1),1)/size(controls,1)) ) ;
    wwr              = mean((p1 - marginal_cost + p2.*controls(:,1)).*controls(:,1));
    
    rev_goal = wwr - (lend_cost + delinquency_cost + visit_cost ) ;
    