function [mLocs,delta,pSize] = macbethRectangles(cornerPoints)
% Calculate mid point of rectangles for an MCC from the corner points
%
%   [mLocs,delta,pSize] = macbethRectangles(cornerPoints)
%
% mLocs:  Middle locations of the MCC patches
% delta:  Size in pixels of something
% pSize:  Patch size in pixels. Covers about 1/3 of the square
%
% Example:
%
%
% TODO:  The rectangles are not quite centered.  Fix.]
%
% Copyright ImagEval Consultants, LLC, 2011.

if ieNotDefined('cornerPoints'), error('Point corners required'); end

% mLocs contains the middle points of the MCC squares
% cornerPoints contains the positions of the four corners.
mWhite = cornerPoints(1,:);
mBlack = cornerPoints(2,:);
mBlue  = cornerPoints(3,:);
mBrown = cornerPoints(4,:);

% Find the affine transformation that maps the selected point values into a
% standard spatial coordinate frame for the Macbeth Color Checker, with the
% white in the lower left, black in lower right, and brown on the upper
% left.
offset = mWhite;
mBlack = mBlack - offset;
mBlue  = mBlue - offset;
mBrown = mBrown - offset;

% Find the linear transformation that maps the non-white points into the
% ideal positions
%  White -> 0,0
%  Black -> 6,0
%  Blue ->  6,4
%  Brown -> 0,4
ideal = [6 6 0; 0 4 4];
current = [mBlack(:), mBlue(:), mBrown(:)];

%  current = L * ideal
L = current*pinv(ideal);

%  Any coordinate in the ideal target can be transformed into the current
%  row, col values in the current data by currentLoc = L*idealLoc
%  So, for example, the red is at 2.5,1.5
%  In the current data this would be
% (L*[2.5,1.5]') + offset(:)
%
% So now, we make up the coordinates of all 24 patches.  These are
[X,Y] = meshgrid((0.5:1:5.5),(0.5:1:3.5));
idealLocs = [X(:),Y(:)]';

% The mLocs contains (rows,cols) of the center of the 24 patches.
% These are from white (lower left) reading up the first row, and then back
% down to the 2nd column, starting at the gray, and reading up again
mLocs = round(L*idealLocs + repmat(offset(:),1,24));

% Build a square of a certain size around the point mLocs(:,N)
% We need to know whether the white->black is down the rows (first
% dimension) or down the columns (second dimension). If the row difference
% between the first two is much larger than the column difference, then we
% assume white black is down the rows.  Otherwise, we assume white->black
% is across the columns.
if abs(cornerPoints(1,2) - cornerPoints(2,2)) > abs(cornerPoints(1,1) - cornerPoints(2,1))
    % In this case the col range exceeds the row range, so the
    % white->black dimension runs left-right in the image.
    deltaX = round(abs(cornerPoints(1,2) - cornerPoints(2,2))/6);
    deltaY = round(abs(cornerPoints(1,1) - cornerPoints(4,2))/4);
else
    % In this case the row range exceeds the column range, and so
    % black-white is running up-down in the image.
    deltaY = round(abs(cornerPoints(1,1) - cornerPoints(2,1))/6);
    deltaX = round(abs(cornerPoints(1,2) - cornerPoints(4,2))/4);
end

% We want to pick out a square region that is within the size of the patch.
% So, we divide the estimated width by 3 and take the smaller one.  This
% way, the coverage is about 2/3rds of the estimated square size.  If we
% divide by 4, rather than 3, we will get 1/2 the patch size.
delta = round(min(deltaX,deltaY)/3);
pSize = 2*delta + 1;

% Debug:
% Put up the mean locations in the sensor image
%   plot(mLocs(2,:),mLocs(1,:),'wo')
%
return;
