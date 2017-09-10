function h2fig = computeCellDensity_plotSegmentationResults(ROIdata,stats)


h2fig = figure;
iP=1;
for iROI = 1:5
    DAPI = ROIdata(iROI).imData{1};
    GFP = ROIdata(iROI).imData{2};

    BW_GFP = stats(iROI).BW_GFP;
    BW_DAPI = stats(iROI).BW_DAPI;
    
    subplot(5,4,iP);iP=iP+1;
    imshowpair(GFP,DAPI)
    h1=gca;
 
    
    subplot(5,4,iP);iP=iP+1;
    imshowpair(DAPI,BW_DAPI);
    h2=gca;
    
    subplot(5,4,iP);iP=iP+1;
    imshowpair(GFP,BW_GFP);
    h3 = gca;
    
    subplot(5,4,iP);iP=iP+1;
    imshowpair(BW_GFP,BW_DAPI);
    h4 = gca;
    
    linkaxes([h1 h2 h3 h4])
    

end
