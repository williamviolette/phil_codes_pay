function h = deaton_print(sim,cd_dir)


g_range = 100;

g=(1:g_range)';

%%% adjust sim for current assets
sim1=sim;
%sim1(:,2:3) = [0 0 ; sim(1:end-1,2:3)];

gs = size(sim1,1) - 125;
gr=gs+g_range-1;

plot(g,sim1(gs:gr,1).*50, g,sim1(gs:gr,2))


plot(g,sim1(gs:gr,2) , g,sim1(gs:gr,3))

plot(g,sim1(gs:gr,4))

collect = (sim1(:,4)>=3);
c = collect.*NaN;
c(collect==1)=50;

y = 12.*(sim1(:,4)==2 | sim1(:,4)==4) + 16.*(sim1(:,4)==1 | sim1(:,4)==3);

hold on

yyaxis left
plot(g,sim1(gs:gr,2) , g,sim1(gs:gr,3))

yyaxis right
plot(g,sim1(gs:gr,1))
plot( g,c(gs:gr),'-s','MarkerSize',10,...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1 .6 .6])

scatter( g,y(gs:gr))

%'-s','MarkerSize',12,...
%    'MarkerEdgeColor','blue',...
%    'MarkerFaceColor',[1 .6 .6])
ylim([10 80])

hold off


h=1;