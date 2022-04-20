function fcn_displayresolution(hAxes,h_ds,h_ppi,dsflag,scfile,n,imagelist,inpath,userid,sep)
%% Copyright 2015-2022 Yann Marcon and Autun Purser

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
% Yann Marcon: ymarcon@marum.de
% Autun Purser: autun.purser@awi.de




%%
if dsflag==0, set(hAxes,'UserData',[]); return; end

hImage = findobj(hAxes,'Type','Image'); % handle of image
imsize = size(get(hImage,'CData'));
% imsize = size(hImage.CData);

% Axes position (requires switching temporarily to pixel units)
AxesUnits = get(hAxes,'Units');
set(hAxes,'Units','pixels');
AxesPos = get(hAxes,'Position');
set(hAxes,'Units',AxesUnits);

% Variables
AxesWidth = AxesPos(3); % Axes width in screen pixels
AxesHeight = AxesPos(4); % Axes height in screen pixels
ImageWidth = imsize(1,2);
ImageHeight = imsize(1,1);
imratio = ImageWidth / ImageHeight;
widthratio = ImageWidth / AxesWidth;
heightratio = ImageHeight / AxesHeight;


ds = cb_dispscale(h_ds); % default value
scrPPI = str2double(get(h_ppi,'String')); % screen PPI
if isempty(ds) || isempty(scrPPI), set(hAxes,'UserData',[]); end % saves the value

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
        
        % Calculate resolutions
        imgPPM = scpxl / sc; % image pixels per metre
        scrPPM = scrPPI / 2.54 * 100; % screen pixels per metre
        
        if widthratio >= heightratio
            AxesWidth_m = AxesWidth / scrPPM; % axes height in metres
            
            minDeltaX = imgPPM * AxesWidth_m / ds;
        else
            AxesHeight_m = AxesHeight / scrPPM; % axes height in metres
            
            minDeltaY = imgPPM * AxesHeight_m / ds;
            minDeltaX = minDeltaY * imratio;
        end
        
        
%         ds0 = imw_m / (AxesWidth / scrPPM); % display size of full image (in 'image metres' per 'screen metre')
%         minDeltaX = imsize(2) * ds / ds0;
%         set(hAxes,'UserData',minDeltaX); % saves the value
        
        
        set(hAxes,'UserData',minDeltaX); % saves the value
        
    end
end

end
