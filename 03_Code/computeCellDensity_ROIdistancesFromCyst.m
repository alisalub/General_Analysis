function [spacing, dmin,varargout]= computeCellDensity_ROIdistancesFromCyst(ROIdata,cystData,prmts)


%compute ROI centroids
rowRange = [ROIdata.rowRange];
colRange = [ROIdata.colRange];
Cy = mean(reshape(rowRange,2,5))';
Cx = mean(reshape(colRange,2,5))';


%there's no warranty that ROIs are sorted from left to rigth...
[Cx, Isort] = sort(Cx);
Cy = Cy(Isort);
ymax = max(Cy);
xmax = max(Cx);

%compute centroid of cyst
Cyst_x = mean(cystData.x);
Cyst_y = mean(cystData.y);

%% For each ROI, compute it's distance along the WM from the site of the occlusion.


%Find the distance from cyst centroid to line defined by centroids of first two ROIs
Q1 = [Cx(1);Cy(1)];
Q2 = [Cx(2);Cy(2)];
P = [Cyst_x;Cyst_y];
point2lineDist = abs(det([Q2-Q1,P-Q1]))/abs(Q2-Q1);
point2lineDist=point2lineDist(1);

%%
%define line between centroids of first and second, the use slope and intercep to compute tangent point with circle
%centered the centroid of the cyst
coefficients = polyfit([Cx(1), Cx(2)], [Cy(1), Cy(2)], 1);
slope = coefficients (1);
intercep = coefficients (2);
[xout,yout] = linecirc(slope,intercep,Cyst_x,Cyst_y,point2lineDist);
%rounding errors might cause the distance computed aboce to be incorrect(?) resulting in more than one point (i.e. not
%adjacent). Just take the mean as a projection of the cyst into the withe matter
WMx  = mean(xout);
WMy = mean(yout);

%now order compute distances between roi centroid with WM projection in between first and second ROIs

X = [Cx(1);WMx;Cx(2:end)];
Y = [Cy(1);WMy;Cy(2:end)];

dx = diff(X);
dy = diff(Y);

spacing = sqrt(dx.^2+dy.^2);
%now rearrange as follows: first roi has neg distnace, second is unchanged, then from the third an on it's cummulative
%distance
spacing = [-spacing(1);cumsum(spacing(2:end))];

%finally deal with returning spacing based on sorting
[~, IsortBack] = sort(Isort);
spacing = spacing(IsortBack);


%% last but not least compute distance between WM intersect and closest point in the cyst perimeter
 resampledPoints = resamplePath( [cystData.x cystData.y ones(size(cystData.x))], 50 );
dx = resampledPoints(:,1)-WMx;
dy = resampledPoints(:,2) - WMy;
d = sqrt(dx.^2+dy.^2);
[dmin, dminIdx]=min(d);

%% OK... not plot all this, if asked 
if prmts.DoPlot
    h2fig=figure;
    BW = poly2mask(cystData.x,cystData.y,round(ymax*1.125),round(xmax*1.125));
    imagesc(BW)
    hold on
    plot(Cyst_x,Cyst_y,'rx','MarkerSIze',12)
    axis image
    %plot roi centroids
    plot(Cx,Cy,'go','MarkerSize',14)
    text(Cx*0.99,Cy*0.99,num2str(Isort),'Color','g')
    colormap summer
    
    %plot line  between roi 1 and 2
    xi = Cx(1):100:Cx(2);
    yi = polyval(coefficients,xi);
    plot(xi,yi,'c--')
    plot(WMx,WMy,'rs','MarkerSize',12)
    
    %closest point to WM
    plot(resampledPoints(dminIdx,1),resampledPoints(dminIdx,2),'r.','MarkerSize',20)

    varargout{1} = h2fig;
    
end
