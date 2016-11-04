function fcn_scrollzoom(hObject,callbackdata)
%% Copyright 2015, 2016 Yann Marcon and Autun Purser

% This file is part of PAPARA(ZZ)I.
% 
% PAPARA(ZZ)I is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% PAPARA(ZZ)I is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with PAPARA(ZZ)I.  If not, see <http://www.gnu.org/licenses/>.


%% Contact:
% Yann Marcon: yann.marcon@awi.de
% Autun Purser: autun.purser@awi.de




%%
hAxes = get(hObject,'CurrentAxes'); % handle of current axes
hPanel = get(hAxes,'Parent'); % handle of uipanel
hImage = findobj(hAxes,'Type','Image'); % handle of image
imsize = size(get(hImage,'CData'));
% imsize = size(hImage.CData);

% Panel position (requires switching temporarily to pixel units)
PanelUnits = get(hPanel,'Units');
set(hPanel,'Units','pixels');
PanelPos = get(hPanel,'Position');
set(hPanel,'Units',PanelUnits);

% Axes position (requires switching temporarily to pixel units)
AxesUnits = get(hAxes,'Units');
set(hAxes,'Units','pixels');
AxesPos = get(hAxes,'Position');
set(hAxes,'Units',AxesUnits);

% Axes position within figure
AxesPos(1:2) = AxesPos(1:2) + PanelPos(1:2);

% Pointer position in the figure (expressed in pixels on the screen)
cPointPos = get(hObject,'CurrentPoint'); % Current point (when scrolling happened)

% Maximum ZoomIn
minDeltaX = get(hAxes,'UserData');

% image boundaries
imratio = imsize(1,2)/imsize(1,1);
widthratio = imsize(1,2)/AxesPos(3);
heightratio = imsize(1,1)/AxesPos(4);
if widthratio >= heightratio
    imleft = AxesPos(1);
    imright = AxesPos(1) + AxesPos(3);
    imbottom = AxesPos(2) + (AxesPos(4)-AxesPos(3)/imratio)/2;
    imtop = imbottom + AxesPos(3)/imratio;
else
    imleft = AxesPos(1) + (AxesPos(3)-AxesPos(4)*imratio)/2;
    imright = imleft + AxesPos(4)*imratio;
    imbottom = AxesPos(2);
    imtop = AxesPos(2) + AxesPos(4);
end


% Activate zoom only if pointer within image boundaries
if cPointPos(1,1) >= imleft && cPointPos(1,1) <= imright ...
        && cPointPos(1,2) >= imbottom && cPointPos(1,2) <= imtop
    
    % compute zoom factor
    scrollcount = callbackdata.VerticalScrollCount; % scroll count
    zoomfactor = 1 + scrollcount/10; % zoom factor for sensitivity adjustment
    
    cLimits = axis(hAxes); % current axis limits
    cDeltaX = cLimits(2) - cLimits(1); % length of x-axis before zoom
    cDeltaY = cLimits(4) - cLimits(3); % length of y-axis before zoom
    newDeltaX = (cLimits(2) - cLimits(1)) * zoomfactor; % length of x-axis after zoom
    newDeltaY = (cLimits(4) - cLimits(3)) * zoomfactor; % length of y-axis after zoom
    
    if ~isempty(minDeltaX) && ...
            (newDeltaX < minDeltaX || newDeltaY < minDeltaX / imratio)
        newDeltaX = minDeltaX;
        newDeltaY = minDeltaX / imratio;
    end
    
    % pixel position of current point on the screen image (not original
    % image)
    cPxlPosScreenRes = cPointPos - [ imleft , imbottom ];
    
    % pixel position of current point on the actual image (image pixels)
    % (the absolute value is required because the YDir is 'reverse')
    cPxlPos = abs(cPxlPosScreenRes .* ...
        [ cDeltaX / (imright - imleft) , cDeltaY / (imtop - imbottom) ] + ...
        [ cLimits(1) , -cLimits(4) ]);
    
    % ratios between current point position and current axes limits
    cRatioX = (cPxlPos(1,1) - cLimits(1)) / cDeltaX;
    cRatioY = (cPxlPos(1,2) - cLimits(3)) / cDeltaY;
    rangeX = [ -cRatioX , (1 - cRatioX) ];
    rangeY = [ -cRatioY , (1 - cRatioY) ];
    
    % new axis limits (after zoom)
    newLimits = [ cPxlPos(1,1) + rangeX .* newDeltaX , ...
        cPxlPos(1,2) + rangeY .* newDeltaY ];
    
    % check is outside boundary
    if newLimits(1) < 0
        newLimits(1:2) = newLimits(1:2) + abs(newLimits(1)) + 1;
        newLimits(2) = min(newLimits(2),imsize(1,2));
    end
    if newLimits(2) > imsize(1,2)
        newLimits(1:2) = newLimits(1:2) - (newLimits(2)-imsize(1,2));
        newLimits(1) = max(newLimits(1),1);
    end
    if newLimits(3) < 0
        newLimits(3:4) = newLimits(3:4) + abs(newLimits(3)) + 1;
        newLimits(3) = max(newLimits(3),1);
    end
    if newLimits(4) > imsize(1,1)
        newLimits(3:4) = newLimits(3:4) - (newLimits(4)-imsize(1,1));
        newLimits(4) = min(newLimits(4),imsize(1,1));
    end
    
    newLimits(1) = max(newLimits(1),1);
    newLimits(2) = min(newLimits(2),imsize(1,2));
    newLimits(3) = max(newLimits(3),1);
    newLimits(4) = min(newLimits(4),imsize(1,1));
    
    % Apply new limits
    axis(hAxes,newLimits);
    
end

end