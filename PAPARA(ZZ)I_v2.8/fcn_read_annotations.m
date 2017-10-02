function [x,y,strlist,meas1,meas2,CStr] = fcn_read_annotations(txtfile)
%% Copyright 2015-2017 Yann Marcon and Autun Purser

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
meas1.x1 = []; meas1.y1 = []; meas1.x2 = []; meas1.y2 = []; % length
meas2.x1 = []; meas2.y1 = []; meas2.x2 = []; meas2.y2 = []; % width
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
        meas1.x1 = NaN(1,kmax); % length
        meas1.y1 = NaN(1,kmax); % length
        meas1.x2 = NaN(1,kmax); % length
        meas1.y2 = NaN(1,kmax); % length
        meas2.x1 = NaN(1,kmax); % width
        meas2.y1 = NaN(1,kmax); % width
        meas2.x2 = NaN(1,kmax); % width
        meas2.y2 = NaN(1,kmax); % width
        
        for k = 1:kmax
            if ~isempty(CStr{k})
                strline = textscan(CStr{k},'%s', 'delimiter', '\t');
                x(k) = str2double(strline{1}{1});
                y(k) = str2double(strline{1}{2});
                strlist{k} = strline{1}{3};
                if size(strline{1},1)>=7
                    meas1.x1(k) = str2double(strline{1}{4});
                    meas1.y1(k) = str2double(strline{1}{5});
                    meas1.x2(k) = str2double(strline{1}{6});
                    meas1.y2(k) = str2double(strline{1}{7});
                end
                
                if size(strline{1},1)==11
                    meas2.x1(k) = str2double(strline{1}{8});
                    meas2.y1(k) = str2double(strline{1}{9});
                    meas2.x2(k) = str2double(strline{1}{10});
                    meas2.y2(k) = str2double(strline{1}{11});
                end
            end
        end
        
    end
end
clear fid


end

