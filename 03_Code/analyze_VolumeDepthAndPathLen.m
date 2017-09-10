% Analysis/plot of path length with cyst volume and depth.
% Script will read data from an excel file with the following column:
% cyct_vol, cyst_depth, path_len, group. First row is textual->column labels. Labels can anything (no spaces) but we
% assume, col 1 to 4 are Volume, Depth, Lenght, Group. One can add more columns to the data 
% Pablo


ptr2file = '/Volumes/Data/Alisa/Milky way paper/time_points_trail_length_vol/Analysis/try.xlsx';
scaleBubbleSize = 1;
%% load data from Excel and convert to table
[~,~,allData] = xlsread(ptr2file);

varNames = allData(1,:);
allData = allData(2:end,:);

T = cell2table(allData,'variableNames',varNames);

%% generate scatter plot

%figure out how many groups

[GroupNames,~,gi] = unique(T.Group);
nGroups = numel(GroupNames);

%scatter plot, color by group
figure('Color','White')
map = parula(3);
bubbleSize = T.(varNames{3});
bubbleSize(bubbleSize==0)=eps;
h=scatter(T.(varNames{1}),T.(varNames{2}),bubbleSize*scaleBubbleSize,gi,'filled');
set(h,'MarkerFaceAlpha',0.7,'MarkerEdgeColor','k','LineWidth',1)
box off

xlabel(varNames{1})
ylabel(varNames{2})

%set lims from 0 to 10% above max val
xlim([0 max(T.(varNames{1})) *1.1])
ylim([0 max(T.(varNames{2})) *1.1])
axis square
set(gca,'FontName','Arial','LineWidth',2,'FontSize',14)


%% Fit a linear model
modelStr = sprintf('%s~%s+%s+%s',varNames{[3 1 2 4]});
T.(varNames{4}) = categorical(T.(varNames{4}));
lm = fitlm(T,modelStr);
disp(lm)

%
figure('Name','Diagnostics and Residuals')
subplot(2,2,1)
plotDiagnostics(lm,'cookd')
subplot(2,2,2)
plotResiduals(lm,'probability')

%
subplot(2,2,3)
plotEffects(lm)

subplot(2,2,4)
plotInteraction(lm,varNames{4},varNames{1},'effects')



%% Fit again after removing outliers
[~,larg] = max(lm.Diagnostics.CooksDistance);
lm2 = fitlm(T,modelStr, 'Exclude',larg);
disp(lm2)


figure('Name','Diagnostics and Residuals')
subplot(2,2,1)
plotDiagnostics(lm2,'cookd')
subplot(2,2,2)
plotResiduals(lm2,'probability')

%
subplot(2,2,3)
plotEffects(lm2)

subplot(2,2,4)
plotInteraction(lm2,varNames{4},varNames{1},'effects')

%% stepwise regression
step(lm)
figure('Name','Diagnostics and Residuals')
subplot(2,2,1)
plotDiagnostics(lm3,'cookd')
subplot(2,2,2)
plotResiduals(lm3,'probability')

%
subplot(2,2,3)
plotEffects(lm3)

subplot(2,2,4)
plotInteraction(lm3,varNames{4},varNames{1},'effects')

