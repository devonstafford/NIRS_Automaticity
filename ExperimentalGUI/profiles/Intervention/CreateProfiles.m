%% Intervention Profile
velL = velL';
velR = velR';
save('TMBaselineSlow.mat','velL','velR')

%% adaptation 1 - baseline adaptation
velL = [0.75*ones(1,150),0.5*ones(1,150),0.75*ones(1,50)];
velR = [0.75*ones(1,150),1*ones(1,150),0.75*ones(1,50)];
save('Adaptation1_RightDominant.mat','velL','velR')

velR = [0.75*ones(1,150),0.5*ones(1,150),0.75*ones(1,50)];
velL = [0.75*ones(1,150),1*ones(1,150),0.75*ones(1,50)];
save('Adaptation1_LeftDominant.mat','velL','velR')

%% switching/adaptation 2 and 3
velL = [0.5*ones(1,150),0.75*ones(1,50),0.5*ones(1,150),0.75*ones(1,50)];
velR = [1*ones(1,150),0.75*ones(1,50),1*ones(1,150),0.75*ones(1,50)];
save('Adaptation23_RightDominant.mat','velL','velR')

vel=velR;
velR = velL;
velL = vel;
save('Adaptation23_LeftDominant.mat','velL','velR')

%% 
velL = [0.5*ones(1,150)];
velR = [1*ones(1,150)];
save('Adaptation4_RightDominant.mat','velL','velR')

vel=velR;
velR = velL;
velL = vel;
save('Adaptation4_LeftDominant.mat','velL','velR')

%% post-adapataion
velL = [0.75*ones(1,315)];
velR = [0.75*ones(1,315)];
save('OGPost.mat','velL','velR')

velL = [0.75*ones(1,150)];
velR = [0.75*ones(1,150)];
save('TMPost.mat','velL','velR')

%% plot full protocol - intervention
velDom = [0.75*ones(1,150),0.5*ones(1,150),1*ones(1,150),0.75*ones(1,150)];
% line([0,150],[0.75,0.75],'LindWidth',')
velNonDom = velDom;
for i = 1:4
    velDom = [velDom,1*ones(1,200),0.75*ones(1,50)];
    velNonDom = [velNonDom, 0.5*ones(1,200),0.75*ones(1,50)];
end
velDom = [velDom, 1*ones(1,200), 0.75*ones(1,600)];
velNonDom = [velNonDom, 0.5*ones(1,200), 0.75*ones(1,600)];

velDom = [velDom, 0.75*ones(1,50), 1*ones(1,30),0.75*ones(1,50),0.75*ones(1,50), 0.5*ones(1,30),0.75*ones(1,50)];
velNonDom = [velNonDom, 0.75*ones(1,50), 0.5*ones(1,30),0.75*ones(1,50),0.75*ones(1,50), 1*ones(1,30),0.75*ones(1,50)];

close all
figure;
% switching area
area([600,1800],[1,1],0.5,'FaceColor','#edebe4','EdgeColor','#edebe4');

hold on;
area([0,150],[1,1],0.5,'FaceColor','#e4f7f6','EdgeColor','#e4f7f6');
area([1800,2250],[1,1],0.5,'FaceColor','#e4f7f6','EdgeColor','#e4f7f6');
area([2400,2670],[1,1],0.5,'FaceColor','#B2A0A0','EdgeColor','#B2A0A0');

h(1) = plot(velDom, 'LineWidth',4,'Color','#0072BD');
h(2) = plot(velNonDom, 'LineWidth',3,'Color','#D95319');
ylabel('Speed (m/s)')
xlabel('Stride')

xticks([150,300,450,600,800,850,1050,1300,1550,1800,2250,2400,2660])
xlim([0,2660])
yticks([0.5,0.75,1])
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',15)

breakloc = [300,450,825,1075,1075+250,1075+500,1575+225,1575+225+300,1575+225+300+300];
for i = breakloc
    xline(i,'k--','LineWidth',2);
end
f= get(gca,'Children');
legend(f([1, 10, 11,12,13,end]),'Break (5mins)','Non-Dominant Leg','Dominant Leg','Short Perturbations','Overground','Switching');

delete(findall(gcf,'type','annotation'));
annotation('textbox', [.13,.001,.05,.05],'String','Overground','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
annotation('textbox', [.22,.001,.07,.05],'String','TM Baseline','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
annotation('textbox', [.45,.001,.09,.05],'String','Adaptation/Switching','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
annotation('textbox', [.78,.001,.05,.05],'String','Overground','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
annotation('textbox', [.85,.001,.07,.05],'String','TM Washout','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');

%% plot full protocol - pre and post intervention
velDom = [0.75*ones(1,150),0.5*ones(1,150),1*ones(1,150),0.75*ones(1,150)];
% line([0,150],[0.75,0.75],'LindWidth',')
velNonDom = velDom;
velDom = [velDom,1*ones(1,900),0.75*ones(1,600)];
velNonDom = [velNonDom,0.5*ones(1,900),0.75*ones(1,600)];
velDom = [velDom, 0.75*ones(1,50), 1*ones(1,30),0.75*ones(1,50),0.75*ones(1,50), 0.5*ones(1,30),0.75*ones(1,50)];
velNonDom = [velNonDom, 0.75*ones(1,50), 0.5*ones(1,30),0.75*ones(1,50),0.75*ones(1,50), 1*ones(1,30),0.75*ones(1,50)];

close all
figure;
% adaptation area
area([600,1500],[1,1],0.5,'FaceColor','#edebe4','EdgeColor','#edebe4');

hold on;
%OG area
area([0,150],[1,1],0.5,'FaceColor','#e4f7f6','EdgeColor','#e4f7f6');
area([1500,1950],[1,1],0.5,'FaceColor','#e4f7f6','EdgeColor','#e4f7f6');
area([2100,2370],[1,1],0.5,'FaceColor','#B2A0A0','EdgeColor','#B2A0A0'); %short perturb area

plot(velDom, 'LineWidth',4,'Color','#0072BD');
plot(velNonDom, 'LineWidth',3,'Color','#D95319');

xticks([150,300,450,600,1500,1950,2100,2370])
xlim([0,2370])
yticks([0.5,0.75,1])
ylabel('Speed (m/s)')
% xlabel('Stride')
a = get(gca,'XTickLabel');  
set(gca,'XTickLabel',a,'fontsize',15)

breakloc = [300,750,1050,1350,1800,2100];
for i = breakloc
    xline(i,'k--','LineWidth',2);
end
f= get(gca,'Children');
legend(f([1, length(breakloc)+1, length(breakloc)+2,length(breakloc)+3,length(breakloc)+4,end]),'Break (5mins)','Non-Dominant Leg','Dominant Leg','Short Perturbation','Overground','Adaptation');

delete(findall(gcf,'type','annotation'));
% annotation('textbox', [.13,.001,.05,.05],'String','Overground','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
% annotation('textbox', [.24,.001,.09,.05],'String','TM Baseline','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
% annotation('textbox', [.5,.001,.07,.05],'String','Adaptation','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
% annotation('textbox', [.73,.001,.07,.05],'String','Overground','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');
% annotation('textbox', [.85,.001,.09,.05],'String','TM Washout','EdgeColor', 'none' ,'FontSize', 16,'Color','k','fontweight', 'bold');


