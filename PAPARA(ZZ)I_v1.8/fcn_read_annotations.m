function [x,y,strlist,measx1,measy1,measx2,measy2,CStr] = fcn_read_annotations(txtfile)
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



%% Read existing annotations

% initialisation
x = [];
y = [];
strlist = {};
measx1 = []; measy1 = []; measx2 = []; measy2 = [];
CStr = [];

% read data from file
fid = fopen(txtfile,'r');

if fid ~= -1
    Data = textscan(fid,'%s','delimiter','\n');
    CStr = Data{1};
    fclose(fid);
    
    if ~isempty(CStr)
        % initialize variables
        kmax = numel(CStr);
        x = NaN(1,kmax);
        y = NaN(1,kmax);
        strlist = cell(1,kmax);
        measx1 = NaN(1,kmax);
        measy1 = NaN(1,kmax);
        measx2 = NaN(1,kmax);
        measy2 = NaN(1,kmax);
        
        for k = 1:kmax
            if ~isempty(CStr{k})
                strline = textscan(CStr{k},'%s', 'delimiter', '\t');
                x(k) = str2double(strline{1}{1});
                y(k) = str2double(strline{1}{2});
                strlist{k} = strline{1}{3};
                if size(strline{1},1)==7
                    measx1(k) = str2double(strline{1}{4});
                    measy1(k) = str2double(strline{1}{5});
                    measx2(k) = str2double(strline{1}{6});
                    measy2(k) = str2double(strline{1}{7});
                end
            end
        end
    end
end
clear fid


end

