% Main script for gathering data from mat files and coordinating computation of microglia density.
%
% Data for each image is organized as a structure containing 5 ROIs corresponding to five location along the WM and a
% ROI marking the cyst location. Ch1 is DAPI and Ch2 is GFP (microglia).
clc
%% Define dataset location and anlysis parameters here below

ptr2dataDir = '/Volumes/Data/Alisa/Confocal_images/new_mat_count';
ptr2figDir = fullfile(ptr2dataDir,'Figures');
ptr2resDir = fullfile(ptr2dataDir,'Results');
groupIdentifiers = {'HET','KO'};


prmts.DAPI.ThresholdSensitivity = 0.65;
prmts.DAPI.StrelSize = 5;
prmts.GFP.ThresholdSensitivity = 0.675; %was 0.575
prmts.GFP.MinAreaSizeInPixels = 100; %used to filter out small  objects from segmentation  
prmts.GFP.StrelSize = 8;
prmts.DoPlot = 1;
prmts.DoSkip = 1;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% NO NEED TO EDIT BELOW THIS LINE %%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isdir(ptr2figDir);mkdir(ptr2figDir);end
if ~isdir(ptr2figDir);mkdir(ptr2resDir);end


%% browse dir, identify 'group' for each
dirContent = dir(fullfile([ptr2dataDir filesep '*.mat']));
nFiles = numel(dirContent);
T = table();
for iFILE = 1 : nFiles
    [~, thisFileName] =  fileparts(dirContent(iFILE).name);
    
    if isempty(strfind(thisFileName,groupIdentifiers{1}))
        %KO
        group = groupIdentifiers{2};
    else
        %HET
        group = groupIdentifiers{1};
    end
    
    thisFileContent = load(fullfile(ptr2dataDir,thisFileName));
    try
        stats = computeCellDensity_segment(thisFileContent.ROIdata,prmts);
        %append to original file and samve
        save(fullfile(ptr2dataDir,thisFileName),'stats','group','-append')
        
        if prmts.DoPlot
            h2fig = computeCellDensity_plotSegmentationResults(thisFileContent.ROIdata,stats);
            set(h2fig,'Name',thisFileName)
            thisFigName = fullfile(ptr2figDir,thisFileName);
            export_fig(h2fig,thisFigName,'-m2')
            close (h2fig)
        end
        
        %collect into table
        tmp = struct2table(stats);
        
        %collect ROI spacing
        [spacing,cyst2wmDist, h2fig]=computeCellDensity_ROIdistancesFromCyst(thisFileContent.ROIdata,thisFileContent.cystData,prmts); %notice that not all ROI are maked in the right order... the funciton sorts the spacing accordingly
        
        if prmts.DoPlot
            set(h2fig,'Name',[thisFileName '_ROI_labels'])
            thisFigName = fullfile(ptr2figDir,[thisFileName '_ROI_labels']);
            export_fig(h2fig,thisFigName,'-m2')
            close (h2fig)
        end
        
        T= [T;table(repmat({thisFileName},5,1),repmat({group},5,1),(1:5)',spacing,repmat(cyst2wmDist,5,1),...
            'VariableNames',{'FileName','Group','ROI','Spacing','Cyst2WMdist'})  tmp(:,'nGFPobjects') tmp(:,'AreaInPix') ...
            tmp(:,'coverageDAPI')  tmp(:,'coverageGFP')  tmp(:,'colocalizedFractionGFP')  tmp(:,'colocalizedFractionDAPI') ] ;
        
    catch ME1
        idSegLast = regexp(ME1.identifier, '(?<=:)\w+$', 'match');
        warning('Failed to complete segmentation for %s exit w/error "%s"',thisFileName, ME1.message)
    end
end%cycling files