function fcn_export(userid,inpath,sep,annotype,pointtype,pointmax)
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
% Disable all buttons and toolbars of the GUI (to prevent double-clicks)
fcn_freeze_fig('off',gcf,'Button-containing panel');
drawnow;


strlist = [];
datapath = [inpath userid '_' lower(annotype) 's' sep];
uapath = [inpath userid '_usable-area' sep];
scpath = [inpath userid '_scale' sep];

% Get date/time stamp for the output files
dt = clock;
strdate = sprintf('%4i-%02i-%02iT%02i-%02i-%02i',dt(1),dt(2),dt(3),dt(4),dt(5),round(dt(6)));

% creates data export folders
exportpath = [inpath 'data-export' sep strdate '_' userid sep];
switch annotype
    case 'Annotation'
        exportpath = [exportpath 'free-annotations' sep];
        abundancepath = [exportpath 'abundance-tables' sep];
        anglepath = [exportpath 'angle-calculations' sep];
        sizepath = [exportpath 'size-distributions' sep];
        
        % list of annotation files
        strlist = vertcat(strlist,dir([datapath '*.txt']));
        strlist = fcn_field2array(strlist,'name','cell'); % convert to cell array
        strlist = unique(strlist); % remove duplicates
        
    case 'GeneratedPoint'
        exportpath = sprintf('%s%li%s%sPoints%s',...
            exportpath,pointmax,upper(pointtype(1)),pointtype(2:end),sep);
        abundancepath = [exportpath 'abundance-tables' sep];
        anglepath = [exportpath 'angle-calculations' sep];
        sizepath = [exportpath 'size-distributions' sep];
        
        % list of annotation files
        strlist = vertcat(strlist,dir([datapath sprintf('*%li%s.txt',pointmax,pointtype)]));
        strlist = fcn_field2array(strlist,'name','cell'); % convert to cell array
        strlist = unique(strlist); % remove duplicates
end
if isdir(abundancepath)==0, mkdir(abundancepath); end
if isdir(anglepath)==0, mkdir(anglepath); end
if isdir(sizepath)==0, mkdir(sizepath); end


% filenames
abundancefile1 = [abundancepath userid '_WholeImage_Abundances.txt'];
abundancefile2 = [abundancepath userid '_UsableArea_Abundances.txt'];
anglefile1 = [anglepath userid '_WholeImage_Angles.txt'];
anglefile2 = [anglepath userid '_UsableArea_Angles.txt'];
legendfile = [sizepath userid '_Legend.txt'];
sizefile1_root = [sizepath userid '_WholeImage_SD_Keyword']; % SD = SizeDistribution
sizefile2_root = [sizepath userid '_UsableArea_SD_Keyword']; % SD = SizeDistribution


% try to open the files
fidout1 = fopen(abundancefile1,'w');
fidout2 = fopen(abundancefile2,'w');
fidout3 = fopen(anglefile1,'w');
fidout4 = fopen(anglefile2,'w');
fidout5 = fopen(legendfile,'w'); % legend file describing keyword labels in size distribution folder
if fidout1==-1 || fidout2==-1 || fidout3==-1 || fidout4==-1 || fidout5==-1
    errordlg('Problem creating one of the summary files. Check if they are not already open.',...
        'File error','modal');
    return;
end

% remove 'ignorelist.txt' and 'randomlist.txt' from the list
files2remove = {'ignorelist.txt';'randomlist.txt'};
[~,id2keep] = setdiff(strlist,files2remove);
if ~isempty(id2keep) % i.e. image must be ignored
    strlist = strlist(id2keep);
end

% Read ignore list (if it exist) (it is always in the annotations folder)
ignorelist = [inpath userid '_annotations' sep 'ignorelist.txt'];
fid = fopen(ignorelist,'r');
if fid ~= -1
    Data = textscan(fid,'%s','delimiter','\n');
    IgnStr = Data{1};
    fclose(fid);
end
ignoreIDs = [];


% read camera intrinsic parameters
kmax = length(strlist); % max number of images
namelist = cell(size(strlist));
for k = 1:kmax % Get list of image root names
    [~,iname] = fileparts(strlist{k});
    switch annotype
        case 'Annotation'
            id = strfind(iname,'_'); id = id(end);
        case 'GeneratedPoint'
            id = strfind(iname,'_'); id = id(end-1);
    end
    namelist{k} = iname(1:id-1);
end
camera_intrinsics = fcn_intrinsics(namelist,inpath);


kwlist = {};
counts = zeros(kmax,1); % [WHOLE] counts for WHOLE images
countsS = zeros(kmax,1); % [SELECTION] counts for SELECTED area
angvec = zeros(kmax,1,2); % [WHOLE] counts for WHOLE images
angvecS = zeros(kmax,1,2); % [SELECTION] counts for SELECTED area
% the 3rd dimension of 'angvec' is as follow:
% 1) sum of size measurement vector x coordinates per image and for each
%    keyword [pxl]
% 2) sum of size measurement vector y coordinates per image and for each
%    keyword [pxl]

% 'pmax' and 'pmaxS' keep track of how many POINTS there are in the images.
% This is important for the generated points (grid and random) because each
% POINT can have multiple ANNOTATIONS.
pmax = zeros(kmax,1); % [WHOLE] number of unique points
pmaxS = zeros(kmax,1); % [SELECTION] number of unique points in usable area

featsz = zeros(kmax,1); % [WHOLE] contains all feature measurements (sorted by keyword)
featszCnt = 0; % [WHOLE] this variable keeps track of how many sizes there are for each keyword
featszS = zeros(kmax,1); % [SELECTION] contains feature measurements in selected area (sorted by keyword)
featszCntS = 0; % [SELECTION] this variable keeps track of how many sizes there are for each keyword
pg = 0; % progress
hwb = waitbar(pg,'Summarizing existing data...','CreateCancelBtn','return;');
for k1=kmax:-1:1 % go backward!!! (loop through images)
    pg = pg + (1/kmax) * .8; % progress up to 80%
    waitbar(pg,hwb);
    
    % Get file name
    [~,iname,~] = fileparts(strlist{k1});
    switch annotype
        case 'Annotation'
            id = strfind(iname,'_'); id = id(end);
        case 'GeneratedPoint'
            id = strfind(iname,'_'); id = id(end-1);
    end
    
    % Check if image should be ignored
    if exist('IgnStr','var')==1
        ignIdC = strfind(IgnStr,iname(1:id-1));
        ignId = find(~cellfun('isempty',ignIdC), 1);
        
        if ~isempty(ignId) % i.e. image must be ignored
            ignoreIDs = [ ignoreIDs , k1 ];
            continue;
        end
    end
    
    % get image size
    if ~isempty(camera_intrinsics)
        switch annotype
            case 'Annotation'
                id1 = strfind(iname,'_'); id1 = id1(end);
                id2 = strfind(iname,'x'); id2 = id2(end);
                imw = str2double(iname(id1+1:id2-1));
                imh = str2double(iname(id2+1:end));
            case 'GeneratedPoint'
                id1 = strfind(iname,'_'); id1a = id1(end-1); id1b = id1(end);
                id2 = strfind(iname,'x'); id2 = id2(end);
                imw = str2double(iname(id1a+1:id2-1));
                imh = str2double(iname(id2+1:id1b-1));
                id1 = id1a;
        end
    end
    
    % Open file for annotation counts
    fid = fopen([datapath strlist{k1}],'r');
    
    % get scale if exists
    scfile = [scpath iname(1:id-1) '.txt'];
    scpxl = 0; % length of scale bar in pixels
    scm = 0; % length of scale bar in metres
    if exist(scfile,'file')==2
        scdata = importdata(scfile,'\t');
        if ~isempty(scdata) && numel(scdata)==5
            pt1 = [scdata(1);scdata(2)];
            pt2 = [scdata(3);scdata(4)];
            if ~isempty(camera_intrinsics)
                pt1 = fcn_undistort_pts(pt1,camera_intrinsics(k1),imw,imh);
                pt2 = fcn_undistort_pts(pt2,camera_intrinsics(k1),imw,imh);
            end
            scpxl = sqrt( (pt2(1)-pt1(1))^2 + (pt2(2)-pt1(2))^2 );
            scm = scdata(5);
        end
    end
    
    % get vertices of usable-area if it is defined
    clear('uaX','uaY'); % clear variables
    uaflag = 0;
    uafile = [uapath iname(1:id-1) '.txt'];
    if ~isempty(uafile) && exist(uafile,'file')==2
        [uaX,uaY,~] = fcn_read_usable_area(uafile);
    end
    if exist('uaX','var')==1 && exist('uaY','var')==1 && ~isempty(uaX) && ~isempty(uaY)
        uaflag = 1; % valid usable-area
    end
    
    if fid ~= -1
        Data = textscan(fid,'%f %f %s','delimiter','\n');
        fclose(fid);
        
        x = Data{1};
        y = Data{2};
        aStr = Data{3};
        
        amax = numel(x); % number of annotations in current image
        pmax(k1) = size(unique([x,y],'rows'),1); % number of points in current image (may be different from 'amax' for generated points if multiple annotations on same point)
        if uaflag
            in = inpolygon(x, y, uaX, uaY);
            pmaxS(k1) = size(unique([x(in),y(in)],'rows'),1); % number of points in usable area
        end
        
        
        if amax > 0
            for ka = 1:amax % loop through annotations in annotation file of image k1
                strline = textscan(aStr{ka},'%s%f%f%f%f%f%f%f%f','delimiter','\t');
                kw = strline{1}{1};
                
                % Size 1: length
                if ~isempty(strline{2}) && ~isempty(strline{3}) ...
                        && ~isempty(strline{4}) && ~isempty(strline{5})
                    
                    pt1 = [strline{2};strline{3}];
                    pt2 = [strline{4};strline{5}];
                    if ~isempty(camera_intrinsics)
                        pt1 = fcn_undistort_pts(pt1,camera_intrinsics(k1),imw,imh);
                        pt2 = fcn_undistort_pts(pt2,camera_intrinsics(k1),imw,imh);
                    end
                    sz1 = sqrt( (pt1(1)-pt2(1))^2 + (pt1(2)-pt2(2))^2 );
                    szvec = [pt1(1)-pt2(1) ; -(pt1(2)-pt2(2))]; % end point of the vector minus start point
                else
                    sz1 = [];
                    szvec = [];
                end
                
                % Size 2: width
                if ~isempty(strline{6}) && ~isempty(strline{7}) ...
                        && ~isempty(strline{8}) && ~isempty(strline{9})
                    
                    pt1 = [strline{6};strline{7}];
                    pt2 = [strline{8};strline{9}];
                    if ~isempty(camera_intrinsics)
                        pt1 = fcn_undistort_pts(pt1,camera_intrinsics(k1),imw,imh);
                        pt2 = fcn_undistort_pts(pt2,camera_intrinsics(k1),imw,imh);
                    end
                    sz2 = sqrt( (pt1(1)-pt2(1))^2 + (pt1(2)-pt2(2))^2 );
                else
                    sz2 = [];
                end
                
                % Count variables
                if ~ismember(kw,kwlist)
                    kwlist = [ kwlist , {kw} ];
                    fprintf(fidout5,'Keyword %04i\t%s\r\n',numel(kwlist),kw);
                    if numel(kwlist)>1
                        counts = [counts zeros(size(counts,1),1)];
                        countsS = [countsS zeros(size(countsS,1),1)];
                        angvec = [angvec zeros(size(angvec,1),1,size(angvec,3))];
                        angvecS = [angvecS zeros(size(angvecS,1),1,size(angvecS,3))];
                        featsz = [featsz zeros(size(featsz,1),1)];
                        featszCnt = [featszCnt 0];
                        featszS = [featszS zeros(size(featszS,1),1)];
                        featszCntS = [featszCntS 0];
                    end
                end
                for k2=1:numel(kwlist)
                    if strcmp(kw,kwlist{k2})==1
                        
                        % [WHOLE] counts for whole image
                        counts(k1,k2) = counts(k1,k2) + 1;
                        
                        if ~isempty(sz1) && scm~=0 && scpxl~=0 % Add size measurement to list
                            % convert sizes to metres
                            sz1m = scm * sz1/scpxl;
                            if ~isempty(sz2)
                                sz2m = scm * sz2/scpxl;
                            else
                                sz2m = NaN;
                            end
                            
                            % sum of normalized angles
                            angvec(k1,k2,1) = angvec(k1,k2,1) + szvec(1)/sz1; % sum of normalized x vectors per image
                            angvec(k1,k2,2) = angvec(k1,k2,2) + szvec(2)/sz1; % sum of normalized y vectors per image
                            
                            % add size value to variable
                            pos = featszCnt(1,k2) + 1;
                            if pos > size(featsz,1) % add a row to the variable
                                featsz = [featsz ; zeros(1,size(featsz,2))];
                            end
                            featsz(pos,k2) = sz1m; % size1 (length) in metres
                            featszCnt(1,k2) = pos;
                            
                            % write/append size value to size distribution file
                            sizefile1 = sprintf('%s%04i%s',sizefile1_root,k2,'.txt');
                            if exist(sizefile1,'file')~=2
                                fidoutSize1 = fopen(sizefile1,'w');
                                fprintf(fidoutSize1,'%s\t%s\t%s\t%s\t%s\r\n',...
                                    'image_name','feature','length','width','direction_angle');
                            else
                                fidoutSize1 = fopen(sizefile1,'a');
                            end
                            angdeg = atan2(szvec(1)/sz1,szvec(2)/sz1) * 180/pi();
                            fprintf(fidoutSize1,'%s\t%s\t%f\t%f\t%f\r\n',iname,kw,sz1m,sz2m,angdeg);
                            fclose(fidoutSize1);
                            
                        end
                        
                        
                        % [SELECTION] counts and feature sizes for selected area
                        if uaflag==1 && inpolygon(x(ka), y(ka), uaX, uaY)
                            
                            countsS(k1,k2) = countsS(k1,k2) + 1;
                            
                            if ~isempty(sz1) && scm~=0 && scpxl~=0 % Add size measurement to list
                                % convert sizes to metres
                                sz1m = scm * sz1/scpxl;
                                if ~isempty(sz2)
                                    sz2m = scm * sz2/scpxl;
                                else
                                    sz2m = NaN;
                                end
                                
                                % sum of normalized angles
                                angvecS(k1,k2,1) = angvecS(k1,k2,1) + szvec(1)/sz1; % sum of normalized x vectors per image
                                angvecS(k1,k2,2) = angvecS(k1,k2,2) + szvec(2)/sz1; % sum of normalized y vectors per image
                                
                                % add size value to variable
                                pos = featszCntS(1,k2) + 1;
                                if pos > size(featszS,1) % add a row to the variable
                                    featszS = [featszS ; zeros(1,size(featszS,2))];
                                end
                                featszS(pos,k2) = sz1m; % size1 (length) in metres
                                featszCntS(1,k2) = pos;
                                
                                % write/append size value to size distribution file
                                sizefile2 = sprintf('%s%04i%s',sizefile2_root,k2,'.txt');
                                if exist(sizefile2,'file')~=2
                                    fidoutSize2 = fopen(sizefile2,'w');
                                    fprintf(fidoutSize1,'%s\t%s\t%s\t%s\t%s\r\n',...
                                        'image_name','feature','length','width','direction_angle');
                                else
                                    fidoutSize2 = fopen(sizefile2,'a');
                                end
                                angdeg = atan2(szvec(1)/sz1,szvec(2)/sz1) * 180/pi();
                                fprintf(fidoutSize2,'%s\t%s\t%f\t%f\t%f\r\n',iname,kw,sz1m,sz2m,angdeg);
                                fclose(fidoutSize2);
                            end
                        end
                    end
                end
            end
        end
    end
end

% Remove images to ignore from the variables
strlist(ignoreIDs,:) = [];
counts(ignoreIDs,:) = [];
countsS(ignoreIDs,:) = [];
angvec(ignoreIDs,:,:) = [];
angvecS(ignoreIDs,:,:) = [];
featsz(ignoreIDs,:) = [];
featszS(ignoreIDs,:) = [];
pmax(ignoreIDs) = [];
pmaxS(ignoreIDs) = [];
kmax = length(strlist); % max number of images


% this part removes empty fields. It is deactivated because all images are
% kept, even if they contain no annotation.
% tmpstr = {};
% for str = strlist'
%     if ~isempty(str{1}), tmpstr = [ tmpstr ; str ]; end
% end
% strlist = tmpstr;


% Sorts the categories (and counts) in the alphabetical order
[kwlist,IX] = sort(kwlist);
counts = counts(:,IX);
countsS = countsS(:,IX);
angvec = angvec(:,IX,:);
angvecS = angvecS(:,IX,:);
featsz = featsz(:,IX);
featszCnt = featszCnt(:,IX);
featszS = featszS(:,IX);
featszCntS = featszCntS(:,IX);


%% Write in files
totalarea = [0 0]; % left: total image area, right: total selected area
fprintf(fidout1,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
    'image_name','width_pxl','height_pxl','width_m','height_m',...
    'scale_pxl','scale_m','area_used','image_area_m2','number_of_points');
fprintf(fidout2,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
    'image_name','width_pxl','height_pxl','width_m','height_m',...
    'scale_pxl','scale_m','area_used','usable_area_m2','number_of_points');
fprintf(fidout3,'%s\t%s','image_name','area_used');
fprintf(fidout4,'%s\t%s','image_name','area_used');
for k=1:numel(kwlist)
    fprintf(fidout1,'\t%s',kwlist{k});
    fprintf(fidout2,'\t%s',kwlist{k});
    fprintf(fidout3,'\t%s',kwlist{k});
    fprintf(fidout4,'\t%s',kwlist{k});
end
fprintf(fidout1,'\r\n');
fprintf(fidout2,'\r\n');
fprintf(fidout3,'\r\n');
fprintf(fidout4,'\r\n');
for k1=1:size(counts,1)  % (loop through image counts)
    pg = pg + (k1/size(counts,1)) * .2; % progress up to remaining 100%
    waitbar(pg,hwb,'Writing summary files...');
    
    [~,iname,~] = fileparts(strlist{k1});
    tline = sprintf('%s',iname);
    
    % get image size
    switch annotype
        case 'Annotation'
            id1 = strfind(iname,'_'); id1 = id1(end);
            id2 = strfind(iname,'x'); id2 = id2(end);
            imw = str2double(iname(id1+1:id2-1));
            imh = str2double(iname(id2+1:end));
        case 'GeneratedPoint'
            id1 = strfind(iname,'_'); id1a = id1(end-1); id1b = id1(end);
            id2 = strfind(iname,'x'); id2 = id2(end);
            imw = str2double(iname(id1a+1:id2-1));
            imh = str2double(iname(id2+1:id1b-1));
            id1 = id1a;
    end
    
    % get scale
    scfile = [scpath iname(1:id1-1) '.txt'];
    scpxl = 0; % length of scale bar in pixels
    scm = 0; % length of scale bar in metres
    imwm = 0; % image width in metres
    imhm = 0; % image height in metres
    imarea = 0; % image area in m2
    if exist(scfile,'file')==2
        scdata = importdata(scfile,'\t');
        if ~isempty(scdata) && numel(scdata)==5
            pt1 = [scdata(1);scdata(2)];
            pt2 = [scdata(3);scdata(4)];
            if ~isempty(camera_intrinsics)
                pt1 = fcn_undistort_pts(pt1,camera_intrinsics(k1),imw,imh);
                pt2 = fcn_undistort_pts(pt2,camera_intrinsics(k1),imw,imh);
            end
            scpxl = sqrt( (pt2(1)-pt1(1))^2 + (pt2(2)-pt1(2))^2 );
            scm = scdata(5);
            imwm = scm * imw/scpxl;
            imhm = scm * imh/scpxl;
            imarea = imwm * imhm;
            if ~isempty(camera_intrinsics)
                if exist('PcM','var')==1
                    [area_pxl,PcM] = fcn_undistort_area([],camera_intrinsics(k1),imw,imh,PcM);
                else
                    [area_pxl,PcM] = fcn_undistort_area([],camera_intrinsics(k1),imw,imh);
                end
                if ~isempty(area_pxl) % then update 'ua_area' with corrected values
                    imarea = area_pxl * (scm/scpxl)^2; % convert to m2
                end
            end
        end
    end
    totalarea(1,1) = totalarea(1,1) + imarea; % total images area
    
    % get area of usable-area
    ua_area = 0; % initialize value
    pxlarea = (scm/scpxl)^2; % area of one pixel (before correction of lens distortion)
    uafile = [uapath iname(1:id-1) '.txt'];
    if ~isempty(uafile) && exist(uafile,'file')==2
        [uaX,uaY,uatype] = fcn_read_usable_area(uafile);
    end
    if exist('uaX','var')==1 && exist('uaY','var')==1 && ~isempty(uaX) && ~isempty(uaY)
        switch uatype
            case 'rectangle'
                rectwm = scm * (max(uaX)-min(uaX))/scpxl; % width of rectangle in metres
                recthm = scm * (max(uaY)-min(uaY))/scpxl; % height of rectangle in metres
                ua_area = rectwm * recthm;
                uaCell = {uatype,[uaX([1,2]);uaY([1,3])]}; % variable used only for the 'fcn_undistort_area' function
                
            case 'polygon'
                [pxl_arrayX, pxl_arrayY] = meshgrid(min(uaX):max(uaX), min(uaY):max(uaY)); % rectangular array of pixels encompassing the polygon)
                in = inpolygon(pxl_arrayX, pxl_arrayY, uaX, uaY);
                ua_area = sum(sum(in)) * pxlarea;
                uaCell = {uatype,[min(uaX),max(uaX) ; min(uaY),max(uaY)],in}; % variable used only for the 'fcn_undistort_area' function
        end
        if ~isempty(camera_intrinsics) && exist(scfile,'file')==2 % the second condition means that the scale exists (otherwise the area cannot be computed)
            area_in_pxl = fcn_undistort_area(uaCell,camera_intrinsics(k1),imw,imh,PcM);
            if ~isempty(area_in_pxl) % then update 'ua_area' with corrected values
                ua_area = area_in_pxl * pxlarea; % convert to m2
            end
        end
    end
    tline = sprintf('%s\t%li\t%li\t%f\t%f\t%f\t%f',tline,imw,imh,imwm,imhm,scpxl,scm);
    
    % print count results for whole image (FIDOUT1)
    tline1 = sprintf('%s\t%s\t%f\t%li',tline,'whole image',imarea,pmax(k1));
    tline3 = sprintf('%s\t%s',iname,'whole image');
    for k2=1:size(counts,2)
        tline1 = sprintf('%s\t%li',tline1,counts(k1,k2));
        
        meanangle = atan2(angvec(k1,k2,1),angvec(k1,k2,2)) * 180/pi();
        tline3 = sprintf('%s\t%f',tline3,meanangle);
    end
    fprintf(fidout1,'%s\r\n',tline1);
    fprintf(fidout3,'%s\r\n',tline3);
    
    % print count results for selected area (FIDOUT2)
    if isnan(ua_area) || ua_area == 0 % if no usable_area, use the whole image counts
        tline2 = sprintf('%s\t%s\t%f\t%li',tline,'whole image',imarea,pmax(k1));
        tline4 = sprintf('%s\t%s',iname,'whole image');
        for k2=1:size(counts,2)
            tline2 = sprintf('%s\t%li',tline2,counts(k1,k2));
            
            meanangle = atan2(angvec(k1,k2,1),angvec(k1,k2,2)) * 180/pi();
            tline4 = sprintf('%s\t%f',tline4,meanangle);
        end
        totalarea(1,2) = totalarea(1,2) + imarea; % total images area
        
    else % if usable_area exists, use the selected counts
        tline2 = sprintf('%s\t%s\t%f\t%li',tline,'selected area',ua_area,pmaxS(k1));
        tline4 = sprintf('%s\t%s',iname,'selected area');
        for k2=1:size(counts,2)
            tline2 = sprintf('%s\t%li',tline2,countsS(k1,k2));
            
            meanangle = atan2(angvecS(k1,k2,1),angvecS(k1,k2,2)) * 180/pi();
            tline4 = sprintf('%s\t%f',tline4,meanangle);
        end
        totalarea(1,2) = totalarea(1,2) + ua_area; % total selected area
        
    end
    fprintf(fidout2,'%s\r\n',tline2);
    fprintf(fidout4,'%s\r\n',tline4);
    
end

%% Add extra lines for total counts, etc

% [WHOLE]
totalline1 = sprintf('\t\t\t\t\t\t\t\t\t%s','Total annotations (in images with scale)'); % total line
densityline1 = sprintf('\t\t\t\t\t\t\t\t\t%s','Density (ind/m2)'); % density line
blankline1 = sprintf('\t\t\t\t\t\t\t\t\t'); % blank line

% [SELECTION]
totalline2 = sprintf('\t\t\t\t\t\t\t\t\t%s','Total annotations (in images with scale)'); % total line
densityline2 = sprintf('\t\t\t\t\t\t\t\t\t%s','Density (ind/m2)'); % density line
blankline2 = sprintf('\t\t\t\t\t\t\t\t\t'); % blank line

for k2=1:size(counts,2)
    totalind = [ sum(counts(:,k2),1) sum(countsS(:,k2),1) ];
    den = [ totalind(1,1) / totalarea(1,1) , totalind(1,2) / totalarea(1,2) ];
    
    % [WHOLE]
    totalline1 = sprintf('%s\t%f',totalline1,totalind(1,1));
    densityline1 = sprintf('%s\t%f',densityline1,den(1,1));
    blankline1 = sprintf('%s\t',blankline1);
    
    % [SELECTION]
    totalline2 = sprintf('%s\t%f',totalline2,totalind(1,2));
    densityline2 = sprintf('%s\t%f',densityline2,den(1,2));
    blankline2 = sprintf('%s\t',blankline2);
end

% [WHOLE]
fprintf(fidout1,'%s\r\n',totalline1);
fprintf(fidout1,'%s\r\n',densityline1);
fprintf(fidout1,'%s\r\n',blankline1);

% [SELECTION]
fprintf(fidout2,'%s\r\n',totalline2);
fprintf(fidout2,'%s\r\n',densityline2);
fprintf(fidout2,'%s\r\n',blankline2);


%% Add the stats about the size measurements at the end of the file

% [WHOLE]
countline1 = sprintf('\t\t\t\t\t\t\t\t%s','Number of length measurements'); % count line
minline1 = sprintf('\t\t\t\t\t\t\t\t%s','Min length [m]'); % min line
maxline1 = sprintf('\t\t\t\t\t\t\t\t%s','Max length [m]'); % max line
meanline1 = sprintf('\t\t\t\t\t\t\t\t%s','Mean length [m]'); % mean line
medianline1 = sprintf('\t\t\t\t\t\t\t\t%s','Median length [m]'); % median line
std1line1 = sprintf('\t\t\t\t\t\t\t\t%s','Standard deviation (n-1) [m]'); % standard deviation line
std2line1 = sprintf('\t\t\t\t\t\t\t\t%s','Standard deviation (n) [m]'); % standard deviation line

% [SELECTION]
countline2 = sprintf('\t\t\t\t\t\t\t\t%s','Number of length measurements'); % count line
minline2 = sprintf('\t\t\t\t\t\t\t\t%s','Min length [m]'); % min line
maxline2 = sprintf('\t\t\t\t\t\t\t\t%s','Max length [m]'); % max line
meanline2 = sprintf('\t\t\t\t\t\t\t\t%s','Mean length [m]'); % mean line
medianline2 = sprintf('\t\t\t\t\t\t\t\t%s','Median length [m]'); % median line
std1line2 = sprintf('\t\t\t\t\t\t\t\t%s','Standard deviation (n-1) [m]'); % standard deviation line
std2line2 = sprintf('\t\t\t\t\t\t\t\t%s','Standard deviation (n) [m]'); % standard deviation line

for k2=1:size(counts,2)
    % [WHOLE]
    cfeatsz = featsz(:,k2);
    cfeatsz = cfeatsz(cfeatsz~=0);
    ccount = size(cfeatsz,1);
    cmin = min(cfeatsz,[],1);
    cmax = max(cfeatsz,[],1);
    cmean = sum(cfeatsz,1) / ccount;
    cmedian = median(cfeatsz,1);
    sd1 = std(cfeatsz,0,1); % method 1 with n-1
    sd2 = std(cfeatsz,1,1); % method 2 with n
    
    countline1 = sprintf('%s\t%f',countline1,ccount);
    minline1 = sprintf('%s\t%f',minline1,cmin);
    maxline1 = sprintf('%s\t%f',maxline1,cmax);
    meanline1 = sprintf('%s\t%f',meanline1,cmean);
    medianline1 = sprintf('%s\t%f',medianline1,cmedian);
    std1line1 = sprintf('%s\t%f',std1line1,sd1);
    std2line1 = sprintf('%s\t%f',std2line1,sd2);
    
    % [SELECTION]
    cfeatszS = featszS(:,k2);
    cfeatszS = cfeatszS(cfeatszS~=0);
    ccountS = size(cfeatszS,1);
    cminS = min(cfeatszS,[],1);
    cmaxS = max(cfeatszS,[],1);
    cmeanS = sum(cfeatszS,1) / ccountS;
    cmedianS = median(cfeatszS,1);
    sd1S = std(cfeatszS,0,1); % method 1 with n-1
    sd2S = std(cfeatszS,1,1); % method 2 with n
    
    countline2 = sprintf('%s\t%f',countline2,ccountS);
    minline2 = sprintf('%s\t%f',minline2,cminS);
    maxline2 = sprintf('%s\t%f',maxline2,cmaxS);
    meanline2 = sprintf('%s\t%f',meanline2,cmeanS);
    medianline2 = sprintf('%s\t%f',medianline2,cmedianS);
    std1line2 = sprintf('%s\t%f',std1line2,sd1S);
    std2line2 = sprintf('%s\t%f',std2line2,sd2S);
end

% [WHOLE]
fprintf(fidout1,'%s\r\n',countline1);
fprintf(fidout1,'%s\r\n',minline1);
fprintf(fidout1,'%s\r\n',maxline1);
fprintf(fidout1,'%s\r\n',meanline1);
fprintf(fidout1,'%s\r\n',medianline1);
fprintf(fidout1,'%s\r\n',std1line1);
fprintf(fidout1,'%s\r\n',std2line1);

% [SELECTION]
fprintf(fidout2,'%s\r\n',countline2);
fprintf(fidout2,'%s\r\n',minline2);
fprintf(fidout2,'%s\r\n',maxline2);
fprintf(fidout2,'%s\r\n',meanline2);
fprintf(fidout2,'%s\r\n',medianline2);
fprintf(fidout2,'%s\r\n',std1line2);
fprintf(fidout2,'%s\r\n',std2line2);


%% Finalize
fclose(fidout1);
fclose(fidout2);
fclose(fidout3);
fclose(fidout4);
delete(hwb);
msg = sprintf('%s\n%s','Export successful. The exported files are in:',exportpath);
waitfor(msgbox(msg,'Export finished','modal'));

% Enable all buttons and toolbars of the GUI
fcn_freeze_fig('on',gcf,'Button-containing panel');
end
