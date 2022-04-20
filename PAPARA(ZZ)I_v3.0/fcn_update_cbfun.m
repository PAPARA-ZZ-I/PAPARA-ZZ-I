function [oldstr] = fcn_update_cbfun(h,str)
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

% update callback
cbfun = get(h(1),'ButtonDownFcn');
pos1 = strfind(cbfun,','); pos1 = pos1(end);
pos2 = strfind(cbfun,')'); pos2 = pos2(end);
oldstr = cbfun(pos1+2:pos2-2);

if exist('str','var')==1
    cbfun = [cbfun(1:pos1),'''',str,'''',cbfun(pos2:end)];
    set(h,'ButtonDownFcn',cbfun);
end

end
