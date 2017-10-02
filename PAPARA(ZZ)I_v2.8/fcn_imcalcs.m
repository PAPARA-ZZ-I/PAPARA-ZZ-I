function fcn_imcalcs(him,im,imclass,B,C,G)
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
% Disable all buttons and toolbars of the GUI (to prevent double-clicks)
fcn_freeze_fig('off',gcf,'Button-containing panel');
drawnow;

% Parameters of initial image
maxint = double(intmax(imclass)); % max integer of class, expressed in double precision

imMin1 = squeeze(min(min(im)))';
imMax1 = squeeze(max(max(im)))';
imMean1 = squeeze(mean(mean(im)))';

% Apply brightness
dMean = imMean1 .* B - imMean1; 
imMin2 = imMin1 + dMean;
imMax2 = imMax1 + dMean;
imMean2 = imMean1 + dMean;

imMin2 = max(0,imMin2);
imMax2 = min(1,imMax2);

% Apply contrast
imMin3 = (imMin2 - imMean2) .* (1-abs(C)) + imMean2;
imMax3 = (imMax2 - imMean2) .* (1-abs(C)) + imMean2;

imMin3 = max(0,imMin3);
imMax3 = min(1,imMax3);

% if license('test','Distrib_Computing_Toolbox')==1, im = gpuArray(im); end

% Apply image enhancement
if C>=0
    im = imadjust(im,[imMin3;imMax3],[imMin1;imMax1],G) * maxint;
else
    im = imadjust(im,[imMin1;imMax1],[imMin3;imMax3],G) * maxint;
end

set(him,'CData',eval([imclass,'(im);']));

% Disable all buttons and toolbars of the GUI (to prevent double-clicks)
fcn_freeze_fig('on',gcf,'Button-containing panel');
drawnow;

end
