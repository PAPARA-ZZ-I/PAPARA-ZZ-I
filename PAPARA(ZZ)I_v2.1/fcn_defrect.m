function fcn_defrect(rectfile,h,GUIsize)
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
global rect;

% Set toolbar toggle button in a pressed state
set(findall(gcf,'Tag','Toolbar_Rectangle'),'State','on');

% Disable all buttons and toolbars
fcn_freeze_fig('off',gcf,'Button-containing panel');

% Prompt for selecting rectangle
if exist('getrect.m','file')==2 || exist('getrect','builtin')==5
    rect = getrect(h);
else
    im = findobj(get(h,'Children'),'type','Image');
    im = get(im,'CData');
%     im = im.CData;
    rectfig = fcn_getrect(im,GUIsize);
    waitfor(rectfig);
end


% Set the pointer style back to default
set(gcf,'Pointer','arrow');

% Get axes limits
xLimits = get(gca,'XLim');  %# Get the range of the x axis
yLimits = get(gca,'YLim');  %# Get the range of the y axis

% Conditions to validate the rectangle
ok = 0;
if rect(1,3)~=0 && rect(1,4)~=0, ok = ok + 1; end % makes sure that no side is 0
if rect(1,1)>=xLimits(1) && (rect(1,1)+rect(1,3))<=xLimits(2), ok = ok + 1; end
if rect(1,2)>=yLimits(1) && (rect(1,2)+rect(1,4))<=yLimits(2), ok = ok + 1; end

if ok==3 % 3 means all conditions were fulfilled
    % Delete any existing rectangle before drawing the new one
    delete(findobj(h,'Tag','rectangle'));
    
    % Draw new rectangle
    rectangle('Position',rect,'EdgeColor','w','Tag','rectangle');
    
    % Open text file for appending
    fid = fopen(rectfile,'w');
    fprintf(fid,'%f\t%f\t%f\t%f\r\n',rect(1,1),rect(1,2),rect(1,3),rect(1,4));
    fclose(fid);
end

clear GLOBAL;

% Enable all buttons and toolbars
fcn_freeze_fig('on',gcf,'Button-containing panel');

% Set toolbar toggle button back to default
set(findall(gcf,'Tag','Toolbar_Rectangle'),'State','off');


end
