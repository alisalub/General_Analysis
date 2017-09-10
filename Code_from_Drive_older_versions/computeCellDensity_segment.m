function stats = computeCellDensity_segment(ROIdata,prmts)
%Apply adaptive thresholding to each ROI, for GFP, filter by object size
%
%%
stats = struct('BW_DAPI',[],'BW_GFP',[],'coverageDAPI',[],'coverageGFP',[]);
for iROI = 1:5
    DAPI = ROIdata(iROI).imData{1};
    GFP = ROIdata(iROI).imData{2};

    %threshold and erode
    BW_DAPI = imbinarize(DAPI,'adaptive','Sensitivity',prmts.DAPI.ThresholdSensitivity);
    se = strel('Disk',prmts.DAPI.StrelSize);
    BW_DAPI = imerode(BW_DAPI,se);
    
    BW_GFP = imbinarize(GFP,'adaptive','Sensitivity',prmts.GFP.ThresholdSensitivity);
    se = strel('Disk',prmts.GFP.StrelSize);
    BW_GFP = imerode(BW_GFP,se);
    
    
    %filter GFP segmented objects by their size
    regprops = regionprops(BW_GFP,'Area','Centroid','PixelIdxList');
    keepIdx = find( [regprops.Area] > prmts.GFP.MinAreaSizeInPixels);
    tmp  = zeros(size(BW_GFP),'uint8');
    nObj = numel(keepIdx);
    for iK = 1 : nObj
        pixList =  regprops(keepIdx(iK)).PixelIdxList;
        tmp(pixList) = 1;
    end
    BW_GFP=tmp;
    
    %compute  stats
    stats(iROI).BW_DAPI = BW_DAPI;
    stats(iROI).BW_GFP = BW_GFP;
    stats(iROI).nPixelsInROI = numel(GFP);
    stats(iROI).nPixelsDAPI = sum(BW_DAPI(:));
    stats(iROI).nPixelsGFP = sum(BW_GFP(:));
    stats(iROI).nPixelsBOTH = sum(BW_GFP(:) & BW_DAPI(:));
    stats(iROI).coverageDAPI =      stats(iROI).nPixelsDAPI/    stats(iROI).nPixelsInROI;
    stats(iROI).coverageGFP =     stats(iROI).nPixelsGFP/    stats(iROI).nPixelsInROI;
    stats(iROI).colocalizedFractionDAPI = stats(iROI).nPixelsBOTH/stats(iROI).nPixelsDAPI;
    stats(iROI).colocalizedFractionGFP = stats(iROI).nPixelsBOTH/stats(iROI).nPixelsGFP;
    stats(iROI).AreaInPix = numel(BW_DAPI);
    stats(iROI).nGFPobjects = nObj;
    stats(iROI).regprops = regprops;
    stats(iROI).keepIdx = keepIdx;

    
end



