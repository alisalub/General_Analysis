function resampledPoints = resamplePath( originalPoints, newSpacing )
% program takes a path (series of 3D points in a column), and resamples so
% that the distance between each point is newSpacing.  The result is
% another series of 3D points in a column spaced by exactly newSpacing

% the algorithm works as follows:
% 
%   given the last point in the re-sampled data (pi), find the next
%   resampled point (pf), so that it lies between two known points in the
%   original data, pa and pb
%
%   this can be expressed by two equations: 
%
%   * pf must lie along a line defined by pa and pb:
%   
%      pf = pa + (pb-pa)*t
%
%   * the distance between pi and pf must be newSpacing (s in the equation)
%
%      s = norm(pf - pi)
%
%   note that unequal x,y, or z spacing in the set of original points can
%   be accounted for by modifying the distance equation, above
%
%   in general, the simultaneous equations result in a quadratic equation, 
%   with two roots for the value t; as long as point pb is after point pa,
%   the correct root will be the one with the largest value

%     tic;
    
    nOriginalPoints = size(originalPoints,1);    
    s = newSpacing;

    lastResampledPoint = originalPoints(1,:);
    
    resampledPoints = lastResampledPoint;    % holds the points, after they are resampled

    paI = 1;                 % index of pa (in originalPoints), initial guess
                             % index of pb is always pa+1
 
    while true
        % check to see if at the end of the original points
        if paI+1 > nOriginalPoints
            break
        end
        
        pa = originalPoints(paI,:);
        pb = originalPoints(paI+1,:);
        
        distToPa = norm(lastResampledPoint - pa);
        distToPb = norm(lastResampledPoint - pb);
        
        if distToPb >= s
            % the next resampled point (pf) lies between pa and pb
            
            % find it ...
            lastResampledPoint = findPf( lastResampledPoint, pa, pb, s );
            
            % and add it to the list
            resampledPoints = [resampledPoints; lastResampledPoint];
        else
            % in general, the next point could lie along the same interval,
            % so only increment if the next point was NOT found
            paI = paI+1;
        end
    end
    
%     disp(['time to resample points: ' num2str(toc)])
    
    % points have been found ... make graphs to show the result?
    check = 0;
    if check
        originalPointsDiff = diff(originalPoints);
        originalPointsDs = sqrt(originalPointsDiff(:,1).^2 ... 
                                + originalPointsDiff(:,2).^2 ...
                                + originalPointsDiff(:,3).^2);

        resampledPointsDiff = diff(resampledPoints);
        resampledPointsDs = sqrt(resampledPointsDiff(:,1).^2 ... 
                                + resampledPointsDiff(:,2).^2 ...
                                + resampledPointsDiff(:,3).^2);
                            
        subplot(2,1,1)
        plot( originalPointsDs );
        title 'distance between original points'

        subplot(2,1,2)
        plot( resampledPointsDs );
        title 'distance between resampled points'

        figure;
        % plot the new and original points, in 3d
        hold off;
        plot3(originalPoints(:,1),originalPoints(:,2),originalPoints(:,3),'b.');
        hold on
        plot3(resampledPoints(:,1),resampledPoints(:,2),resampledPoints(:,3),'r*');
        legend('original points','resampled points')
    end
 
end

 
function pf = findPf( pi, pa, pb, s )
% finds a point pf, such that
%   (1) pf lies on the line formed by pa and pb 
%   (2) mag(pf-pi) has a length of s
% is assumed that the point will lie between pa and pb;
% if, not the function will work, but display a warning
%
% function works by parameterzing the line
%   pf = pa + (pb-pa) * t
% which garantees contidion (1), and finding t such that (2) is
% satisfied as well
% note that this line points from pa to pb, as t increases ...
% therefore, choosing the max(t) keeps the resampled points from turning
% back around

    dab = pb - pa;           % distance from point a to point b
    dia = pa - pi;           % distance from point i to point a

    % ... solve quadratic equation with 
    a = dab(1)^2 + dab(2)^2 + dab(3)^2;                        % coefficient of t^2
    b = 2 * (dia(1)*dab(1) + dia(2)*dab(2) + dia(3)*dab(3));   % coefficient of t
    c = dia(1)^2 + dia(2)^2 + dia(3)^2 - s^2;

    r = roots( [a b c] );

    if ~isreal( r )
        r
        error 'one of the roots was imaginary!'
    end

    t = max( r );

    if (t < 0) | (t > 1)
        t
        disp 'warning, the value of t did not lie on the expected interval'
    end

    % convert t back into a point, using the original parametized line
    pf = pa + (pb-pa) * t;

end