function [pointtype,pointmax] = fcn_generatepoints(pointfile,uafile,n,imagelist,inpath,userid,sep,pointtype,pointmax)
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




%% NOTE:
% All input arguments can be omitted if the first one is given.
% 


%%
% Get button handle
hToolbar = findall(gcf,'Tag','FigureToolBar');
hPoints  = findobj(hToolbar,'Tag','Toolbar_Points');
set(hPoints,'State','on');

if ~isempty(pointfile)
    pos1 = strfind(pointfile,'_'); pos1 = pos1(end) + 1;
    pos2 = strfind(pointfile,'.'); pos2 = pos2(end) - 1;
    k = 0;
    while ~isnan(str2double(pointfile(pos1:pos1+k)))
        k = k + 1;
    end
    pointmax = str2double(pointfile(pos1:pos1+k-1));
    pointtype = pointfile(pos1+k:pos2);
end

% Delete previous points
delete(findobj(gca,'Tag','GeneratedPoint'));

% Disable every button in the interface
fcn_freeze_fig('off',gcf,'Button-containing panel');
drawnow;

if ~isempty(pointfile)
    [pointpath,iname,~] = fileparts(pointfile);
    if isdir(pointpath)==0, mkdir(pointpath); end
    
else
    % Create generatedpoints folder
    pointpath = [inpath userid '_generatedpoints' sep];
    if isdir(pointpath)==0, mkdir(pointpath); end
    
    % Name of corresponding annotation text file
    annopath = [inpath userid '_annotations' sep];
    id = strfind(imagelist{n},'.'); id = id(end);
    annofile = dir([annopath imagelist{n}(1:id-1) '*.txt']);
    [~,iname,~] = fileparts([annopath annofile.name]);
    
    % Name of point text file
    pointfile = sprintf('%s%s_%li%s.txt',pointpath,iname,pointmax,pointtype);
    [~,iname,~] = fileparts(pointfile);
end



%% Get size of area

% Get image size from annotation file
id1 = strfind(iname,'_'); id1a = id1(end-1); id1b = id1(end);
id2 = strfind(iname,'x'); id2 = id2(end);
imw = str2double(iname(id1a+1:id2-1));
imh = str2double(iname(id2+1:id1b-1));
offset_x = 0;
offset_y = 0;

% Use RECTANGLE size is usable-area exists and it is a rectangle (not a polygon)
if ~isempty(uafile) && exist(uafile,'file')==2
    % Get image size from rectangle (not from polygon!)
    ua = importdata(uafile,'\t');
    if isstruct(ua)==1 && isfield(ua,'textdata')==1 && isfield(ua,'data')==1 ...
            && strcmpi(ua.textdata,'rectangle')==1 && numel(ua.data)==4
        % RECTANGLE
        offset_x = ua.data(1);
        offset_y = ua.data(2);
        imw = floor(ua.data(3));
        imh = floor(ua.data(4));
    end
end


%% Generate grid
switch pointtype
    case 'grid'
        % Generate points
        pts = fcn_generategrid(pointmax,imw,imh);
        
    case 'random'
        % Generate points
        id = randperm(imw*imh);
        id = id(1:pointmax);
        x = id - (ceil(id/imw)-1)*imw;
        y = ceil(id/imw);
        pts = [x',y'];
        
    otherwise
        return;
        
end
pts(:,1) = pts(:,1) + offset_x;
pts(:,2) = pts(:,2) + offset_y;

fid = fopen(pointfile,'w');
for k=1:size(pts,1)
    fid = fcn_annotate(fid,gca,pts(k,:),'empty','GeneratedPoint',[{'w'},{'c'},{'k'}]);
end
fclose(fid);

end
