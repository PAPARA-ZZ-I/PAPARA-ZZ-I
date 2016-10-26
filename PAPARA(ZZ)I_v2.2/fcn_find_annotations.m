function [id,CStr,txtfile,idKW,x,y] = fcn_find_annotations(fid,h_gcbo)
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



%% Find existing annotations

% SEARCH FOR OTHER ANNOTATIONS FOR SAME POINT
if ischar(fid) % filename instead of FileID
    txtfile = fid;
else
    txtfile = fopen(fid); % get filename
    fclose(fid);
end

% read data from file
fid = fopen(txtfile,'r');
Data = textscan(fid,'%s','delimiter','\n');
CStr = Data{1};
fclose(fid);

% Get point coordinates
x = get(h_gcbo,'XData');
y = get(h_gcbo,'YData');

% Search the lines with same X-Y
XYstr = sprintf('%f\t%f\t',x,y);
idC = strfind(CStr, XYstr);
id = find(~cellfun('isempty',idC));

% Search the lines with same X-Y-Keyword,
cbfun = get(h_gcbo,'ButtonDownFcn'); idtxt = strfind(cbfun,'''');
kw = cbfun(idtxt(1)+1:idtxt(end)-1);
XYKstr = sprintf('%f\t%f\t%s',x,y,kw);
idC = strfind(CStr, XYKstr);
idKW = find(~cellfun('isempty',idC));

end

