%

%% load and prepare data
% the variable "a" is a 1600 x 5 and contains all the traces (sampled at 100 points each and normalized between 0 and 1)
% The 5 (columns) comes from the scans "Baseline 1 7 21 28 days after".
% The first 800 entries are for KO and the remaining for the WT
load('/Users/pb/Google Drive/__PUBLICATIONS/MIlkyWay/03-Figures/02_Data/all_mice_tracts.mat')

%define paramteres
nKOSubjects = 8;
nWTSubjects = 8;
nSubjects = nKOSubjects+nWTSubjects;
timePoints = [0 1 14 21 28]; % corresponding to cols 1 to 5

nSamplesPerTrack = 100;
idxKO = 1:800;
idxWT = 801:1600;

%easier to have two separated matrices, 
nKORows = numel(idxKO);
nWTRows = numel(idxWT);
nTimePoints = numel(timePoints);

KO = a(idxKO,:);
WT = a(idxWT,:);



%% 3-way ANOVA w/repeated measures
% What we have here as factors (predictors) are:
% 1) Phenotype (KO/WT)
% 2) Time (0, 1 7 21 28 days)
% 3) Location along track (currently sampled w/100 point resolution)
% Then we have 8 subjects on each phenotype (KO and WT).
% the "Subject" has to be defined as "random" and it has to be nested within the Phenotype grouping variable.
% If we define the order of the grouping variables a [Phenotype Time Position Subject] then the nesting is between
% variable 1 and 4. In matrix notation this is M= [0 0 0 0;0 0 0 0; 0 0 0 0; 1 0 0 0].
% Then the model should be run as anovan(Y,GroupingVariables,'random',4,'Nested',M)

%reorganize data as single response (Y) vector, 
Y = a(:);
% build group variables
Phenotype = repmat( [repmat({'KO'},nKORows,1) ;repmat({'WT'},nWTRows,1)], nTimePoints,1);

Time =repmat([0 1 14 21 28],size(a,1),1);
Time = Time(:);
Position = repmat((1:100)',nSubjects*nTimePoints,1);
Subject  = repmat(1:nSubjects,nSamplesPerTrack,1);
Subject = repmat(Subject(:),nTimePoints,1);

%run 3-way anova w/repeated measure
M= [0 0 0 0;0 0 0 0; 0 0 0 0; 1 0 0 0];
[P,RATAB,STATS,TERM] = anovan(Y,{Phenotype Time Position Subject},'random',4,'Nested',M,'varnames',{'Phenotype','Time','Position','Subject'});