function h = deaton_print(sim,cd_dir)


[~,ind] = max(sim(:,4));

g_range = 100;

g=(1:g_range)';

%%% adjust sim for current assets
sim1=sim;
%sim1(:,2:3) = [0 0 ; sim(1:end-1,2:3)];

gs = ind- (g_range/2);
gr=gs+g_range-1;

plot(g,sim1(gs:gr,1).*100, g,sim1(gs:gr,2))

plot(g,sim1(gs:gr,2) , g,sim1(gs:gr,3))

plot(g,sim1(gs:gr,4))

collect = (sim1(:,5)>=3);
c = collect.*NaN;
c(collect==1)=50;

y = 12.*(sim1(:,4)==2 | sim1(:,4)==4) + 16.*(sim1(:,4)==1 | sim1(:,4)==3);







hold on

yyaxis left
fig=plot(g,sim1(gs:gr,2),'-mo',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[.49 1 .63],...
    'MarkerSize',7)

plot(g,sim1(gs:gr,3),'-mo',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',[.7 1 .2],...
    'MarkerSize',7)

yyaxis right
plot(g,sim1(gs:gr,1))
plot( g,c(gs:gr),'-s','MarkerSize',10,...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1 .6 .6])

scatter(g,y(gs:gr))

%'-s','MarkerSize',12,...
%    'MarkerEdgeColor','blue',...
%    'MarkerFaceColor',[1 .6 .6])
ylim([10 80])

title(strcat('Simulated ',num2str(g_range),' Months'))

hold off

saveas(fig,strcat(cd_dir,'deaton.png'))


h=1;