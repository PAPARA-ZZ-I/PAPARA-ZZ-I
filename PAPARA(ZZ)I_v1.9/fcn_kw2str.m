function str = fcn_kw2str(str)
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
str = strtrim(str);
str = strrep(str,'\','_');
str = strrep(str,'/','_');
str = strrep(str,'!','_');
str = strrep(str,'"','_');
str = strrep(str,'�','_');
str = strrep(str,':','_');
str = strrep(str,'$','_');
str = strrep(str,'%','_');
str = strrep(str,'&','_');
str = strrep(str,'=','_');
str = strrep(str,'?','_');
str = strrep(str,'''','_');
str = strrep(str,'*','_');
str = strrep(str,'+','_');
str = strrep(str,'~','_');
str = strrep(str,'#','_');
str = strrep(str,';','_');
str = strrep(str,':','_');
str = strrep(str,'.','_');
str = strrep(str,'<','_');
str = strrep(str,'>','_');
str = strrep(str,'|','_');
str = strrep(str,'{','(');
str = strrep(str,'}',')');
str = strrep(str,'[','(');
str = strrep(str,']',')');


end
