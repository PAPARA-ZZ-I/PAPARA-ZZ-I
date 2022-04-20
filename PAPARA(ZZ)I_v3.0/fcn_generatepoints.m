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

% Use RECTANGLE size if usable-area exists and it is a rectangle (not a polygon)
numberofpoints = pointmax;
if ~isempty(uafile) && exist(uafile,'file')==2
    % Get image size from usable area
    [uaX,uaY,uatype] = fcn_read_usable_area(uafile);
    switch lower(uatype)
        case 'rectangle'
            % RECTANGLE
            offset_x = min(uaX);
            offset_y = min(uaY);
            imw = floor(max(uaX) - min(uaX));
            imh = floor(max(uaY) - min(uaY));
            
        case 'polygon'
            % compute bounding rectangle and adjust number of points
            % proportionally
            offset_x = min(uaX);
            offset_y = min(uaY);
            [pxl_arrayX, pxl_arrayY] = meshgrid(min(uaX):max(uaX), min(uaY):max(uaY)); % rectangular array of pixels encompassing the polygon)
            imw = size(pxl_arrayX, 2);
            imh = size(pxl_arrayX, 1);
            bounding_area = imw * imh;
            meshin = inpolygon(pxl_arrayX, pxl_arrayY, uaX, uaY);
            polygon_area = sum(sum(meshin));
            numberofpoints = round(pointmax * bounding_area / polygon_area);
    end
end


%% Generate grid
switch pointtype
    case 'grid'
        % Generate points
        pts = fcn_generategrid(numberofpoints,imw,imh);
        
        % Special case for polygons (exclude points outside of polygon)
        if exist('uatype','var')==1 && strcmpi(uatype,'polygon')==1
            [in, on] = inpolygon(pts(:,1)+offset_x, pts(:,2)+offset_y, uaX, uaY);
            
            % if number of inliers higher than desired points, remove the
            % points that are on the boundary first
            kon = find(on);
            pos = numel(kon);
            while sum(sum(in)) > pointmax && pos > 0
                in(kon(pos)) = 0; % remove point
                pos = pos - 1;
            end
            
            pts = pts(in,:);
        end
        pts(:,1) = pts(:,1) + offset_x;
        pts(:,2) = pts(:,2) + offset_y;
        
    case 'random'
        % Generate points
        if exist('uatype','var')==1 && strcmpi(uatype,'polygon')==1
            id = randperm(polygon_area);
            id = id(1:pointmax);
            inliers = find(meshin);
            pts = [pxl_arrayX(inliers(id)), pxl_arrayY(inliers(id))];
            
        else % normal case if not polygon
            id = randperm(imw*imh);
            id = id(1:pointmax);
            x = id - (ceil(id/imw)-1)*imw;
            y = ceil(id/imw);
            pts = [x',y'];
            
            pts(:,1) = pts(:,1) + offset_x;
            pts(:,2) = pts(:,2) + offset_y;
        end
        
    otherwise
        return;
        
end

fid = fopen(pointfile,'w');
for k=1:size(pts,1)
    fid = fcn_annotate(fid,gca,pts(k,:),'empty','GeneratedPoint',[{'w'},{'c'},{'k'}]);
end
fclose(fid);

end
