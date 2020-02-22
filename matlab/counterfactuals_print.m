function h=counterfactuals_print(cd_dir,tag,vr,ucon,u_ch,ucon_u,ucon_uc,sim_u,sim_uc,rev_goal,rev_goal_u,lend_cost_u,delinquency_cost_u,visit_cost_u,wwr_u,s,given)

wnum(cd_dir,strcat('cv_',tag,'.tex'), (ucon-ucon_u)/u_ch,'%5.0f');
wnum(cd_dir,strcat('cv_comp_',tag,'.tex'), (ucon-ucon_uc)/u_ch,'%5.0f');
wnum(cd_dir,strcat('rev_goal_',tag,'.tex'), rev_goal_u,'%5.0f');
wnum(cd_dir,strcat('fee_',tag,'.tex'), (rev_goal-rev_goal_u) ,'%5.0f');
wnum(cd_dir,strcat('vrate_',tag,'.tex'), vr ,'%5.2f');

wnum(cd_dir,strcat('debt_end_',tag,'.tex'), mean(abs(sim_uc(sim_uc(:,6)==s,3))) ,'%5.0f');
wnum(cd_dir,strcat('debt_',tag,'.tex'), mean(abs(sim_uc(:,3))) ,'%5.0f');
wnum(cd_dir,strcat('cons_',tag,'.tex'), mean(sim_uc(:,1)) ,'%5.1f');

wnum(cd_dir,strcat('cons_val_',tag,'.tex'), mean(sim_uc(:,1).*(given(10)+given(11).*sim_uc(:,1))) ,'%5.0f');



wnum(cd_dir,strcat('lend_cost_',tag,'.tex'), (lend_cost_u) ,'%5.0f');
wnum(cd_dir,strcat('lend_cost_',tag,'.tex'), (delinquency_cost_u) ,'%5.0f');
wnum(cd_dir,strcat('visit_cost_',tag,'.tex'), (visit_cost_u) ,'%5.0f');
wnum(cd_dir,strcat('wwr_',tag,'.tex'), (wwr_u) ,'%5.0f');

h=0;