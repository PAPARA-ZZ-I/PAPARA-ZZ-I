function [results,recordstruct] = fcn_htxtleft_callback(hlist,results,recordcell,recordstruct)
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
htxtleft = findobj(gcf,'Tag','htxtleft');
index_selected = get(htxtleft,'Value');

clicktype = get(gcf,'SelectionType');
switch clicktype
    case 'normal' % single click
        list = get(htxtleft,'String');
        item = strtrim(list{index_selected});
        htxtright = findobj(gcf,'Tag','htxtright');
        if ~isempty(item), set(htxtright,'String',recordcell{index_selected}); end
        
    case 'open' % double click
        delete(gcf); % 'delete' closes the figure without calling the CloseRequestFcn (use 'close' to call it instead)
        results = results(index_selected); % with brackets it remains a cell array
        recordstruct = recordstruct(index_selected);
        set(hlist,'Value',1); % prevents display errors
        set(hlist,'String',results);
end

end