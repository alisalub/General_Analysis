function exportROIs2mat


%% get relevant data from current figure

%store relevant data in figure appdata as we use this as input for the export function
aspectRatio=getappdata(gcf,'aspectRatio');
ptr2tif=getappdata(gcf,'ptr2tif');
ROIdata = struct('imData',[],'rowRange',[],'colRange',[],'width',[],'height',[]);

%% figure out how many channels of data for current tif
[path2mat, fileName] = fileparts(ptr2tif);
nameWithOutCh = fileName(1:strfind(fileName,'Ch')+1);
tifFileNames = dir(fullfile(path2mat,[nameWithOutCh '*.tif']))
nChannels= numel(tifFileNames);

%% cut data for tif file
h2ROIs  = getappdata(gcf,'h2ROIs');
nROIs = numel(h2ROIs);
for iROI = 1 : nROIs
    for iCH = 1 : nChannels
        thisChTifName = tifFileNames(iCH).name;
        ptr2thisChTif = fullfile(path2mat,thisChTifName);
        ChDelim =  regexp(thisChTifName,'[0-9]+.tif');
        chNum = str2double(thisChTifName(ChDelim:ChDelim+1));
        fprintf('\nExtracting data for Ch %d/%d ROI %d/%d',iCH,nChannels,iROI,nROIs);
        pos = h2ROIs(iROI).getPosition; %[col row width height]
        
        %read specific portion of original tif image, specify as cell array, first element is row range, second is column
        %range
        
        rowRange = round([pos(2) pos(2)+pos(4)] * aspectRatio(2));
        colRange =  round([pos(1) pos(1)+pos(3)] * aspectRatio(1));
        
        ROIdata(iROI).imData{chNum} = imread(ptr2thisChTif,'PixelRegion',{rowRange,colRange});
        ROIdata(iROI).rowRange = rowRange;
        ROIdata(iROI).colRange = colRange;
        ROIdata(iROI).width = diff(colRange);
        ROIdata(iROI).height = diff(rowRange);
    end%cycling channels
end%cycling ROIs

%% extract cyst coordinates
fprintf('\nExtracting Cyst data');
h2cyst = getappdata(gcf,'h2cyst');
cystData = struct('x',[],'y',[]);
cystData.x = get(h2cyst,'XData')'* aspectRatio(2);
cystData.y = get(h2cyst,'YData')'* aspectRatio(1);

%% save
matFileName = [nameWithOutCh(1:end-3),'.mat'];
fprintf('\nSaving to %s file',matFileName);

save(fullfile(path2mat,matFileName),'ROIdata','aspectRatio','ptr2tif','cystData');

fprintf('\nDone!');


%% display
figure
channelHasData = find(cellfun(@numel,ROIdata(iROI).imData));
nChannelsWithData = numel(channelHasData);

for iCH = 1 : nChannelsWithData 
    subplot(nChannelsWithData,1,iCH);
    for iROI = 1 : numel(ROIdata)

        imagesc(ROIdata(iROI).colRange(1),ROIdata(iROI).rowRange(1),ROIdata(iROI).imData{iCH});
        hold on;
    end
    axis image
    plot(cystData.x,cystData.y,'r-')
end
colormap gray
linkaxes
