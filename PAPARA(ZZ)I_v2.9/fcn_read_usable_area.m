function [x,y,uatype] = fcn_read_usable_area(txtfile)
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



%% Read existing annotations

% initialisation
x = [];
y = [];
uatype = '';

% read data from file
if ~isempty(txtfile) && exist(txtfile,'file')==2
    ua = importdata(txtfile,'\t');
    if isstruct(ua)==1 && isfield(ua,'textdata')==1 && isfield(ua,'data')==1
        uatype = ua.textdata{1};
        if strcmpi(uatype,'rectangle')==1 && numel(ua.data)==4 % usable area is a valid rectangle ('rectangle x y width height')
            % RECTANGLE
            [x, y] = rect2vertices(ua.data);
            
        elseif strcmpi(uatype,'polygon')==1 && numel(ua.data)>=6 ...
                && mod(numel(ua.data),2)==0 % usable area is a valid polygon, i.e. at least a triangle ('polygon x1 y1 x2 y2 x3 y3')
            % POLYGON
            x = ua.data(1:2:end-1);
            y = ua.data(2:2:end);
        end
        
    elseif ~isempty(ua) && numel(ua)==4  % legacy compatibility with PAPARA(ZZ)I versions before v.2.9
        uatype = 'rectangle';
        [x, y] = rect2vertices(ua);
    end
end
end


function [x,y] = rect2vertices(data)
x = [data(1,1) , data(1,1) + data(1,3) , data(1,1) + data(1,3) , data(1,1)];
y = [data(1,2) , data(1,2) , data(1,2) + data(1,4) , data(1,2) + data(1,4)];
end

