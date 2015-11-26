function fcn_freeze_fig(onoff,h,PanelTag)
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
if exist('onoff','var')~=1, onoff = 'off'; end % disable interface
if exist('h','var')~=1 || isempty(h), h = gcf; end

% Disable all buttons
if exist('PanelTag','var')~=1 || isempty(PanelTag)
    uipanelHandles = findobj(h,'Type','uipanel');
else
    uipanelHandles = findobj(0,'Tag',PanelTag);
end
for htmp = uipanelHandles'
    hButtons = get(htmp,'Children');
    set(hButtons,'Enable',onoff);
end

% Disable toolbar
hToolbar = findall(h,'Tag','FigureToolBar');
for htmp = hToolbar'
    hButtons = allchild(htmp);
    hVisibleButtons = findobj(hButtons,'Visible','on');
    set(hVisibleButtons,'Enable',onoff);
end


end
