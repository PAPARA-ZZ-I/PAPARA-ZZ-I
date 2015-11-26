function fcn_getrect_ButUpCB(~,~)
%% Copyright 2015 Yann Marcon and Autun Purser

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


global IS_BUTTON_DOWN;
global RECTANGLE_HANDLE;
global RECT_START_COORD;
global RECT_END_COORD;
global rect;

% reset the button down flag
IS_BUTTON_DOWN = false;

% delete the rectangle from the figure
delete(RECTANGLE_HANDLE);

% clear the handle
RECTANGLE_HANDLE = [];

% compute the top left (tl) and bottom right (br) coordinates
if ~isempty(RECT_END_COORD)
    x = min(RECT_START_COORD(1,1),RECT_END_COORD(1,1));
    y = min(RECT_START_COORD(1,2),RECT_END_COORD(1,2));
    w = abs(x-max(RECT_START_COORD(1,1),RECT_END_COORD(1,1)));
    h = abs(y-max(RECT_START_COORD(1,2),RECT_END_COORD(1,2)));
    rect = [x y w h];
else
    rect = [0,0,0,0];
end

delete(gcf);

end
