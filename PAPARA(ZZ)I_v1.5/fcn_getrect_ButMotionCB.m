function fcn_getrect_ButMotionCB(~,~)
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
global RECT_START_COORD;
global RECT_END_COORD;
global RECTANGLE_HANDLE;

if ~isempty(IS_BUTTON_DOWN) && IS_BUTTON_DOWN
    
    % get bottom right corner of rectangle
    RECT_END_COORD = get(gca,'CurrentPoint');
    
    % get the top left corner and width and height of
    % rectangle (note the absolute value forces it to "open"
    % from left to right - need smarter logic for other direction)
    x = min(RECT_START_COORD(1,1),RECT_END_COORD(1,1));
    y = min(RECT_START_COORD(1,2),RECT_END_COORD(1,2));
    w = abs(x-max(RECT_START_COORD(1,1),RECT_END_COORD(1,1)));
    h = abs(y-max(RECT_START_COORD(1,2),RECT_END_COORD(1,2)));
    
    % only draw the rectangle if the width and height are positive
    if w>0 && h>0
        
        % rectangle drawn in white (better colour needed for different
        % images?)
        if isempty(RECTANGLE_HANDLE)
            % empty so rectangle not yet drawn
            RECTANGLE_HANDLE = rectangle('Position',[x,y,w,h],'EdgeColor','w');
        else
            % need to redraw
            set(RECTANGLE_HANDLE,'Position',[x,y,w,h],'EdgeColor','w');
        end
    end
end

end
