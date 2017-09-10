%function ROImarker(varargin)
%function ROImarker can be used to mark and crop (into separate files) differnt image ROIs
%
%
%

%For each tif file, we expect to have a "thumbnail" in png format.

%% get pointer to file

% if nargin<1
%     ptr2selectedFIle = uigetfile();
% end



[fileName, path2file, filterindex] =   uigetfile({'*.png';'.tif';'*.mat'});

%% Prepare data base on file type
switch filterindex
    
    case 1 %png file - this should be the default behaviour
        
        ptr2png  = fullfile(path2file,fileName);
        [~,baseName] = fileparts(fileName);
        tifFileName = sprintf('%s.tif',baseName);
        %check that tif exists
        ptr2tif = fullfile(path2file,tifFileName);
        if~ exist(ptr2tif,'file')
            error('Missing tif file \n%s',ptr2tif);
        end
        
        %if we got here, check file info, mainly figure out scaling between tif and png ans we will mark ROIs in png but
        %extract data from tif
        
        pngInfo = imfinfo(ptr2png);
        pngSize = [pngInfo.Width pngInfo.Height];
        
        tifInfo = imfinfo(ptr2tif);
        tifSize = [tifInfo.Width tifInfo.Height];
        
        aspectRatio = tifSize./pngSize;
        
    case 2 %tif file, look for png file, if not existing, load tif, make png (for future reference)
        %not supported yet
        
    case 3 %mat file, call the display function
        %not supported yet
        
end




%% Load png and create 
close all
h2fig = figure('windowStyle','docked','name',baseName);

im = imread(ptr2png);
h2img = imshow(im);


%define callback funtion for menus
cmdROI = 'h2ROIs = getappdata(gcf,''h2ROIs'');';
cmdROI = [cmdROI 'h = imrect(gca);position=wait(h);';];
cmdROI = [cmdROI 'if isempty(h2ROIs);h2ROIs=h;else h2ROIs(end+1)=h;end;setappdata(gcf,''h2ROIs'',h2ROIs);'];

cmdCyst = 'h2cyst = getappdata(gcf,''h2cyst''); if ~isempty(h2cyst);delete(h2cyst);end ;';
cmdCyst = [cmdCyst '[~, cystXi cystYi] = roipoly;hold on;h2cyst = plot(cystXi,cystYi,''r-'');setappdata(gcf,''h2cyst'',h2cyst);'];

%add context menu
contextMenu = uicontextmenu;
h2img.UIContextMenu = contextMenu;
uimenu(contextMenu,'Label','MarkRoi','Callback',cmdROI)
uimenu(contextMenu,'Label','Mark Cyst','Callback',cmdCyst)
uimenu(contextMenu,'Label','Export ROIs','Callback','exportROIs2mat');


%store relevant data in figure appdata as we use this as input for the export function
setappdata(h2fig,'aspectRatio',aspectRatio);
setappdata(h2fig,'ptr2tif',ptr2tif);

