function fcn_navigate_image_sections(hAxes,pn)
%% Copyright 2015-2017 Yann Marcon and Autun Purser

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


hImage = findobj(hAxes,'Type','Image'); % handle of image
imsize = size(get(hImage,'CData'));
% imsize = size(hImage.CData);

xlim = get(hAxes,'XLim');
ylim = get(hAxes,'YLim');

% Variables
ImageWidth = imsize(1,2);
ImageHeight = imsize(1,1);


Xdelta = abs(diff(xlim));
Ydelta = abs(diff(ylim));
Xbins = ceil(ImageWidth / Xdelta); % number of bins in X axis
Ybins = ceil(ImageHeight / Ydelta); % number of bins in Y axis
binmax = Xbins * Ybins; % absolute number of bins in image

cXbin = floor( min(xlim) / Xdelta ) + 1; % current bin in X
cYbin = floor( min(ylim) / Ydelta ) + 1; % current bin in Y
cbin = (cYbin-1) * Xbins + cXbin; % current bin in image

cbin = cbin + pn; % add increment to change bin
while cbin > binmax
    cbin = cbin - binmax;
end
while cbin < 1
    cbin = cbin + binmax;
end

cXbin = cbin;
while cXbin > Xbins, cXbin = cXbin - Xbins; end
cYbin = (cbin - cXbin) / Xbins + 1;

xlim = [ cXbin-1 , cXbin ] * Xdelta;
ylim = [ cYbin-1 , cYbin ] * Ydelta;
set(hAxes,'XLim',xlim,'YLim',ylim);

end
