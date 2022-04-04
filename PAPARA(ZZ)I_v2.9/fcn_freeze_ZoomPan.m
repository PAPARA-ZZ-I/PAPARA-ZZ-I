function fcn_freeze_ZoomPan(onoff,h)
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
if exist('onoff','var')~=1, onoff = 'off'; end % disable interface
if exist('h','var')~=1 || isempty(h), h = gcf; end

% Disable zoom and pan buttons
set(findall(h,'Tag','Exploration.ZoomIn'),'Enable',onoff);
set(findall(h,'Tag','Exploration.ZoomOut'),'Enable',onoff);
set(findall(h,'Tag','Exploration.Pan'),'Enable',onoff);


end
