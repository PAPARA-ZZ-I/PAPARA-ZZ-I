function fcn_export(userid,inpath,sep,annotype,pointtype,pointmax)
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
strlist = [];
datapath = [inpath userid '_' lower(annotype) 's' sep];
rectpath = [inpath userid '_rectangle' sep];
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
sizefile1_root = [sizepath userid '_WholeImage_SizeDistribution_'];
sizefile2_root = [sizepath userid '_UsableArea_SizeDistribution_'];


% try to open the files
fidout1 = fopen(abundancefile1,'w');
fidout2 = fopen(abundancefile2,'w');
fidout3 = fopen(anglefile1,'w');
fidout4 = fopen(anglefile2,'w');
if fidout1==-1 || fidout2==-1 || fidout3==-1 || fidout4==-1
    errordlg('Problem creating one of the summary files. Check if they are not already open.',...
        'File error','modal');
    return;
end

% remove 'ignorelist.txt' from the list
idC = strfind(strlist,'ignorelist.txt');
id = find(~cellfun('isempty',idC), 1);
if ~isempty(id) % i.e. image must be ignored
    strlist(id) = [];
    strlist = strlist(~cellfun('isempty',strlist));
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

featsz = zeros(kmax,1); % [WHOLE] contains all feature measurements (sorted by keyword)
featszCnt = 0; % [WHOLE] this variable keeps track of how many sizes there are for each keyword
featszS = zeros(kmax,1); % [SELECTION] contains feature measurements in selected area (sorted by keyword)
featszCntS = 0; % [SELECTION] this variable keeps track of how many sizes there are for each keyword
pg = 0; % progress
hwb = waitbar(pg,'Summarizing existing data...','CreateCancelBtn','return;');
for k1=kmax:-1:1 % go backward!!!
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
    
    
    % Open file
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
    
    % get rectangle limits if rectangle exists
    clear('rectX','rectY'); % clear variables
    rectfile = [rectpath iname(1:id-1) '.txt'];
    if exist(rectfile,'file')==2
        rect = importdata(rectfile,'\t');
        if ~isempty(rect) && numel(rect)==4
            % rectangle limits
            rectX = [rect(1,1) , rect(1,1) + rect(1,3) ];
            rectY = [rect(1,2) , rect(1,2) + rect(1,4) ];
        end
    end
    
    while ~feof(fid)
        tline = fgetl(fid);
        if tline ~= -1
            strline = textscan(tline,'%f%f%s%f%f%f%f%f%f%f%f','delimiter','\t');
            x = strline{1};
            y = strline{2};
            kw = strline{3}{1};
            
            % Size 1: length
            if ~isempty(strline{4}) && ~isempty(strline{5}) ...
                    && ~isempty(strline{6}) && ~isempty(strline{7})
                
                pt1 = [strline{4};strline{5}];
                pt2 = [strline{6};strline{7}];
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
            if ~isempty(strline{8}) && ~isempty(strline{9}) ...
                    && ~isempty(strline{10}) && ~isempty(strline{11})
                
                pt1 = [strline{8};strline{9}];
                pt2 = [strline{10};strline{11}];
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
                        sizefile1 = [sizefile1_root kw '.txt'];
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
                    if exist('rectX','var')==1 && exist('rectY','var')==1 ...
                            && x >= rectX(1,1) && x <= rectX(1,2) ...
                            && y >= rectY(1,1) && y <= rectY(1,2)
                        
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
                            sizefile2 = [sizefile2_root kw '.txt'];
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
        else
            % option deactivated because if an image may have zero
            % annotation and this information should be stored.
%             strlist{k1} = [];
%             counts(k1,:) = [];
%             countsS(k1,:) = [];
        end
    end
    fclose(fid);
end

% Remove images to ignore from the variables
strlist(ignoreIDs,:) = [];
counts(ignoreIDs,:) = [];
countsS(ignoreIDs,:) = [];
angvec(ignoreIDs,:,:) = [];
angvecS(ignoreIDs,:,:) = [];
featsz(ignoreIDs,:) = [];
featszS(ignoreIDs,:) = [];
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
fprintf(fidout1,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
    'image_name','width_pxl','height_pxl','width_m','height_m',...
    'scale_pxl','scale_m','area_used','image_area_m2');
fprintf(fidout2,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s',...
    'image_name','width_pxl','height_pxl','width_m','height_m',...
    'scale_pxl','scale_m','area_used','usable_area_m2');
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
for k1=1:size(counts,1)
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
                imarea = area_pxl * (scm/scpxl)^2; % convert to m2
            end
        end
    end
    totalarea(1,1) = totalarea(1,1) + imarea; % total images area
    
    % get rectangle area
    rectarea = 0; % initialize value
    rectfile = [rectpath iname(1:id1-1) '.txt'];
    if exist(rectfile,'file')==2
        rect = importdata(rectfile,'\t');
        if ~isempty(rect) && numel(rect)==4
            % rectangle area
            rectwm = scm * rect(1,3)/scpxl;
            recthm = scm * rect(1,4)/scpxl;
            rectarea = rectwm * recthm;
            if ~isempty(camera_intrinsics) && exist(scfile,'file')==2 % the second condition means that the scale exists
                area_pxl = fcn_undistort_area(rect,camera_intrinsics(k1),imw,imh,PcM);
                rectarea = area_pxl * (scm/scpxl)^2; % convert to m2
            end
        end
    end
    tline = sprintf('%s\t%li\t%li\t%f\t%f\t%f\t%f',tline,imw,imh,imwm,imhm,scpxl,scm);
    
    % print count results for whole image (FIDOUT1)
    tline1 = sprintf('%s\t%s\t%f',tline,'whole image',imarea);
    tline3 = sprintf('%s\t%s',iname,'whole image');
    for k2=1:size(counts,2)
        tline1 = sprintf('%s\t%li',tline1,counts(k1,k2));
        
        meanangle = atan2(angvec(k1,k2,1),angvec(k1,k2,2)) * 180/pi();
        tline3 = sprintf('%s\t%f',tline3,meanangle);
    end
    fprintf(fidout1,'%s\r\n',tline1);
    fprintf(fidout3,'%s\r\n',tline3);
    
    % print count results for selected area (FIDOUT2)
    if rectarea == 0 % if no rectangle, use the whole image counts
        tline2 = sprintf('%s\t%s\t%f',tline,'whole image',imarea);
        tline4 = sprintf('%s\t%s',iname,'whole image');
        for k2=1:size(counts,2)
            tline2 = sprintf('%s\t%li',tline2,counts(k1,k2));
            
            meanangle = atan2(angvec(k1,k2,1),angvec(k1,k2,2)) * 180/pi();
            tline4 = sprintf('%s\t%f',tline4,meanangle);
        end
        totalarea(1,2) = totalarea(1,2) + imarea; % total images area
        
    else % if rectangle exists, use the selected counts
        tline2 = sprintf('%s\t%s\t%f',tline,'selected area',rectarea);
        tline4 = sprintf('%s\t%s',iname,'selected area');
        for k2=1:size(counts,2)
            tline2 = sprintf('%s\t%li',tline2,countsS(k1,k2));
            
            meanangle = atan2(angvecS(k1,k2,1),angvecS(k1,k2,2)) * 180/pi();
            tline4 = sprintf('%s\t%f',tline4,meanangle);
        end
        totalarea(1,2) = totalarea(1,2) + rectarea; % total selected area
        
    end
    fprintf(fidout2,'%s\r\n',tline2);
    fprintf(fidout4,'%s\r\n',tline4);
    
end

%% Add extra lines for total counts, etc

% [WHOLE]
totalline1 = sprintf('\t\t\t\t\t\t\t\t%s','Total annotations (in images with scale)'); % total line
densityline1 = sprintf('\t\t\t\t\t\t\t\t%s','Density (ind/m2)'); % density line
blankline1 = sprintf('\t\t\t\t\t\t\t\t'); % blank line

% [SELECTION]
totalline2 = sprintf('\t\t\t\t\t\t\t\t%s','Total annotations (in images with scale)'); % total line
densityline2 = sprintf('\t\t\t\t\t\t\t\t%s','Density (ind/m2)'); % density line
blankline2 = sprintf('\t\t\t\t\t\t\t\t'); % blank line

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
countline1 = sprintf('\t\t\t\t\t\t\t\t%s','Number of size measurements'); % count line
minline1 = sprintf('\t\t\t\t\t\t\t\t%s','Min length [m]'); % min line
maxline1 = sprintf('\t\t\t\t\t\t\t\t%s','Max length [m]'); % max line
meanline1 = sprintf('\t\t\t\t\t\t\t\t%s','Mean length [m]'); % mean line
medianline1 = sprintf('\t\t\t\t\t\t\t\t%s','Median length [m]'); % median line
std1line1 = sprintf('\t\t\t\t\t\t\t\t%s','Standard deviation (n-1) [m]'); % standard deviation line
std2line1 = sprintf('\t\t\t\t\t\t\t\t%s','Standard deviation (n) [m]'); % standard deviation line

% [SELECTION]
countline2 = sprintf('\t\t\t\t\t\t\t\t%s','Number of size measurements'); % count line
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
msgbox(msg,'Export finished','modal');
end
