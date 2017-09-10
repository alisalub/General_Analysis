iP=1
for sens =0.3:0.05:0.7
    prmts.DAPI_ThresholdSensitivity = sens;
    
    for iROI = 5
        DAPI = ROIdata(iROI).imData{1};
        GFP = ROIdata(iROI).imData{2};
        
        
        % imshowpair(GFP,DAPI)
        BW_DAPI = imbinarize(DAPI,'adaptive','Sensitivity',prmts.DAPI.ThresholdSensitivity);
        
        se = strel('Disk',5);
        BW_DAPI = imerode(BW_DAPI,se);
        
    end
    
    subplot(3,3,iP);iP=iP+1;
            imshowpair(DAPI,BW_DAPI);

    title(num2str(prmts.DAPI_ThresholdSensitivity))
    
end


%%
prmts.GFP.StrelSize = 10
MinAreaSizeInPixels=110
iP=1
for sens =linspace(0.6,0.7,9)
   
    
    for iROI = 5 
        DAPI = ROIdata(iROI).imData{1};
        GFP = ROIdata(iROI).imData{2};
        
        
        % imshowpair(GFP,DAPI)
        BW_GFP = imbinarize(GFP,'adaptive','Sensitivity',sens);
        
        se = strel('Disk',prmts.GFP.StrelSize);
        BW_GFP = imerode(BW_GFP,se);
        
    end
    
        %filter GFP segmented objects by their size
    roiprops = regionprops(BW_GFP,'Area','Centroid','PixelIdxList');
    keepIdx = find( [roiprops.Area] > MinAreaSizeInPixels);
    tmp  = zeros(size(BW_GFP),'uint8');
    for iK = 1 : numel(keepIdx)
        pixList =  roiprops(keepIdx(iK)).PixelIdxList;
        tmp(pixList) = 1;
    end
    BW_GFP=tmp;
    
    
    subplot(3,3,iP);iP=iP+1;
            imshowpair(GFP,BW_GFP);

    title(num2str(sens))
    
end

linkaxes