function fcn_displayresolution(hAxes,h_dr,drflag,scfile,n,imagelist,inpath,userid,sep)
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
if drflag==0, set(hAxes,'UserData',[]); return; end

hImage = findobj(hAxes,'Type','Image'); % handle of image
imsize = size(get(hImage,'CData'));
% imsize = size(hImage.CData);

% Axes position (requires switching temporarily to pixel units)
AxesUnits = get(hAxes,'Units');
set(hAxes,'Units','pixels');
AxesPos = get(hAxes,'Position');
set(hAxes,'Units',AxesUnits);

AxesWidth = AxesPos(4); % Axes width in screen pixels

dr = str2double(get(h_dr,'String')); % default value [mm/screen pxl]
if isempty(dr), set(hAxes,'UserData',[]); end % saves the value

if exist('scfile','var')~=1 || isempty(scfile)
    scpath = [inpath userid '_scale' sep];
    [~,iname,~] = fileparts(imagelist{n});
    scfile = [ scpath iname '.txt' ];
end

% Read existing scale
if exist(scfile,'file')==2
    scdata = importdata(scfile,'\t');
    if ~isempty(scdata) && numel(scdata)==5
        scpxl = sqrt( (scdata(3)-scdata(1))^2 + (scdata(4)-scdata(2))^2 ); % scalebar length in pixels
        sc = scdata(5);
        
        % Calculate image width that fits given display resolution
        imw_m = imsize(2) * sc / scpxl; % image width in metres
        dr0 = (1000*imw_m) / AxesWidth; % display resolution of full image
        minDeltaX = imsize(2) * dr / dr0;
        set(hAxes,'UserData',minDeltaX); % saves the value
        
    end
end

end
