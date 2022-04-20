function fcn_defpoly(uafile,h,GUIsize)
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
% Set toolbar toggle button in a pressed state
set(findall(gcf,'Tag','Toolbar_Polygon'),'State','on');

% Disable all buttons and toolbars
fcn_freeze_fig('off',gcf,'Button-containing panel');

% Selecting polygon
pol = getline(h);

% Get axes limits
xLimits = get(gca,'XLim');  %# Get the range of the x axis
yLimits = get(gca,'YLim');  %# Get the range of the y axis

% Conditions to validate the polygon
ok = 0;
if sum(sum(pol))~=0 && size(pol,1)>=3, ok = ok + 1; end % makes sure that polygon has at least three points
if all(sum(diff(pol,1,1))), ok = ok + 1; end % makes sure that no consecutive points are identical
if all(pol(:,1)>=xLimits(1)) && all(pol(:,1)<=xLimits(2)), ok = ok + 1; end % makes sure that points are within image limits
if all(pol(:,2)>=yLimits(1)) && all(pol(:,2)<=yLimits(2)), ok = ok + 1; end % makes sure that points are within image limits

if ok==4 % 4 means all conditions were fulfilled
    % Delete any existing polygon before drawing the new one
    delete(findobj(h,'Tag','usable-area'));
    
    % Draw new polygon
    patch('XData',pol(:,1),'YData',pol(:,2),'FaceColor','none','EdgeColor','w','Tag','usable-area');
    
    % Open text file for writing
    fid = fopen(uafile,'w');
    fprintf(fid,'polygon');
    for k = 1:size(pol,1)
        fprintf(fid,'\t%f\t%f',pol(k,1),pol(k,2));
    end
    fprintf(fid,'\r\n');
    fclose(fid);
end

% Enable all buttons and toolbars
fcn_freeze_fig('on',gcf,'Button-containing panel');

% Set toolbar toggle button back to default
set(findall(gcf,'Tag','Toolbar_Polygon'),'State','off');


end
