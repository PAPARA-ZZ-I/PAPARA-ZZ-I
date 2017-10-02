function h = fcn_getrect(im,figpos)
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

% clear all global variables (or just those specific to this app)
clear GLOBAL;

global rect;
rect = [0,0,0,0]; % default value

% display the image
h = figure('MenuBar','none','NumberTitle','off','Name','Draw rectangle',...
    'WindowStyle','modal','Pointer','fullcross','OuterPosition',figpos);
axes('Parent',h,'ActivePositionProperty','Position','Position',[0 0 1 1]);
image(im);
axis image
set(gca,'visible','off');

% set callbacks for the handling of the mouse button down, motion, and
% up events against this figure
set(h,'WindowButtonDownFcn',@fcn_getrect_ButDownCB,...
    'WindowButtonUpFcn',@fcn_getrect_ButUpCB,...
    'WindowButtonMotionFcn',@fcn_getrect_ButMotionCB);

end
