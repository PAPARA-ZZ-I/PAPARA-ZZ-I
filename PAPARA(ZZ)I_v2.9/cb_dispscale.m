function ds = cb_dispscale(h,oldds)
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
if exist('h','var')~=1 || isempty(h), h = gcbo; end
if exist('oldds','var')~=1 || isempty(oldds), oldds = 1; end

str = get(h,'String');
str = strtrim(str);

id = [ strfind(str,':') , strfind(str,'/') ];
if numel(id)==1 && id > 1 && id < numel(str)
    N = str2double(str(1:id-1));
    D = str2double(str(id+1:end));
    if ~isnan(N) && ~isnan(D) && N > 0 && D > 0
        ds = N / D;
    end
end

if exist('ds','var')~=1
    if ~isnan(str2double(str)) && str2double(str) > 0
        ds = str2double(str);    
    else
        ds = oldds;
    end
end
    
[N,D] = rat(ds);
str = sprintf('%li:%li',N,D);
set(h,'String',str);

end
