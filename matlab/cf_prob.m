function [u_op1, ]=cf_prob(prob_alt,given,controls,r_lend,visit_price,marginal_cost,p1,p2,s)


   
    
    [rev_goal]=cost_calc(controls,r_lend,visit_price,marginal_cost,p1,p2,s);

    

    [~,u_op1,sim_op1] =dc_obj_chow_pol_finitetest(res_op1,prob_op1,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain_op1,s,int_size,refinement);
    disp 'utility from prob change'
    (ucon-u_op1)/u_ch
    
    disp 'Pre: B loan (last DC)'
    sum(controls(controls(:,6)==384,3)==min(controls(controls(:,6)==384,3)))/sum(controls(:,6)==384)
    disp 'Post: B loan (last DC)'
    sum(sim_op1(sim_op1(:,6)==384,3)==min(sim_op1(sim_op1(:,6)==384,3)))/sum(sim_op1(:,6)==384)
    
    disp 'Pre: B loan average '
    mean(controls(controls(:,6)==384,3))
    disp 'Post: B loan average '
    mean(sim_op1(sim_op1(:,6)==384,3))
    
    lend_cost_op1        = mean(abs(sim_op1(:,3))).*r_lend;
    delinquency_cost_op1 = mean(abs(sim_op1(sim_op1(:,6)==s,3)))./s ;
    visit_cost_op1       = mean( visit_price.*(size(sim_op1([0 ;  sim_op1(1:(size(sim_op1,1)-1),3)]<0 & sim_op1(:,5)>2,1),1)/size(sim_op1,1)) ) ;
    wwr_op1              = mean((p1 - marginal_cost + p2.*sim_op1(:,1)).*sim_op1(:,1));
    
    disp 'Pre: Rev'
    rev_goale
    disp 'Post: Rev'
    rev_goal_op1 = wwr_op1 - (lend_cost_op1 + delinquency_cost_op1 + visit_cost_op1) 
    
    

    res_op = given;
    prob_caught_op =  prob_caught/2 ;
    prob_op = [(1-prob_caught_op).*ones(n_states,n_states/2) (prob_caught_op).*ones(n_states,n_states/2)]./(n_states./2); 
    [chain_op,~] = markov(prob_op,n,s0);
    
    Pgridop = (1:3)' ;
    Rop = zeros(size(Pgridop,1),1);
    rev_new_op = zeros(size(Pgridop,1),1);
    
    for i=1:size(Pgridop,1)
        p1op = p1+Pgridop(i);
        res_op_temp=given;
        res_op_temp(:,10) = p1op;
       
        [~,~,sim_nop]=dc_obj_chow_pol_finitetest(res_op_temp,prob_op,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain_op,s,int_size,refinement);

            lend_cost_op        = mean(abs(sim_nop(:,3))).*r_lend;
            delinquency_cost_op = mean(abs(sim_nop(sim_nop(:,6)==s,3)))./s ;
            visit_cost_op       = mean( visit_price.*(size(sim_nop([0 ;  sim_nop(1:(size(sim_nop,1)-1),3)]<0 & sim_nop(:,5)>2,1),1)/size(sim_nop,1)) ) ;
            wwr_op              = mean((p1op - marginal_cost + p2.*sim_nop(:,1)).*sim_nop(:,1));

            rev_op = wwr_op - (lend_cost_op + delinquency_cost_op + visit_cost_op ) ;
            
        Rop(i,1) = abs(rev_op - rev_goale);
        rev_new_op(i,1)=rev_op;
    end
    
    plot(Pgridop,Rop)
    [~,indop]=min(Rop);
    Pgridop(indop)
   
    rev_new_op(indop)
    
    resop = given;
    resop(:,10)=given(:,10)+Pgridop(indop);
    [~,u_op,sim_op] =dc_obj_chow_pol_finitetest(resop,prob_op,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain_op,s,int_size,refinement);
    
    (ucon-u_op)/u_ch

