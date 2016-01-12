function fid = fcn_change_annotation(fid,h,selstr,szdel)
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
if exist('szdel','var')~=1, szdel = 0; end
% if szdel~0, then any size measurement associated with the annotation is deleted


% CHANGE ANNOTATION IN TEXT FILE
txtfile = fopen(fid); % get filename
fclose(fid);

% read data from file
fid = fopen(txtfile,'r');
Data = textscan(fid,'%s','delimiter','\n');
CStr = Data{1};
fclose(fid);

% Get point coordinates
x = get(h,'XData');
y = get(h,'YData');
XYstr = sprintf('%f\t%f\t',x,y);

% Search and delete the line
idC = strfind(CStr, XYstr);
id = find(~cellfun('isempty',idC), 1);
if ~isempty(id)
    v = textscan(CStr{id},'%f%f%s%f%f%f%f','Delimiter','\t'); % the last 4 variables may not exist
    if ~isempty(v{4}) && ~isempty(v{5}) && ~isempty(v{6}) && ~isempty(v{7}) && szdel==0
        CStr{id} = sprintf('%f\t%f\t%s\t%f\t%f\t%f\t%f',x,y,selstr,v{4},v{5},v{6},v{7});
    else
        CStr{id} = sprintf('%f\t%f\t%s',x,y,selstr);
    end
end

% Create a new file and save it again:
fid = fopen(txtfile,'w');
if fid == -1, error('Cannot open file'), end
fprintf(fid,'%s\r\n',CStr{:});
fclose(fid);

% Re-open the file in 'append' mode
fid = fopen(txtfile,'a');

end
