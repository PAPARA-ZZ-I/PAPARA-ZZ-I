function fcn_ctrl_FigMenus(h,onoff)
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
if exist('h','var')~=1, h = gcf; end
if exist('onoff','var')~=1 || ~strcmp(onoff,'on'), onoff = 'off'; end

allh = []; % list of handles
allh = [ allh , findall(h,'Tag','figMenuFile')];
allh = [ allh , findall(h,'Tag','figMenuEdit')];
allh = [ allh , findall(h,'Tag','figMenuView')];
allh = [ allh , findall(h,'Tag','figMenuInsert')];
allh = [ allh , findall(h,'Tag','figMenuTools')];
allh = [ allh , findall(h,'Tag','figMenuDesktop')];
allh = [ allh , findall(h,'Tag','figMenuWindow')];
allh = [ allh , findall(h,'Tag','figMenuHelp')];
set(allh,'Visible',onoff);

end