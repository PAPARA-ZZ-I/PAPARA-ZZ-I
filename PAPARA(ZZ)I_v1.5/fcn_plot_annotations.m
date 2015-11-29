function him = fcn_plot_annotations(h,txtfile,n,imagelist,inpath,rectfile,scfile,aflag,kwlist,filterlist,infotxt,annotype)
%% Copyright 2015 Yann Marcon and Autun Purser

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

% Create generated points if they don't exist
if strcmp(annotype,'GeneratedPoint')==1 && exist(txtfile,'file')~=2
    % if points do not exist, create them
    [~,~] = fcn_generatepoints(txtfile);
end


% Read existing annotations
fid = fopen(txtfile,'r');
x = [];
y = [];
strlist = {};
measx1 = []; measy1 = []; measx2 = []; measy2 = [];
if fid ~= -1
    while ~feof(fid)
        tline = fgetl(fid);
        if tline ~= -1
            strline = textscan(tline,'%s', 'delimiter', '\t');
            x = [ x , str2double(strline{1}{1}) ];
            y = [ y , str2double(strline{1}{2}) ];
            strlist = [ strlist , strline{1}(3) ];
            if size(strline{1},1)==7
                measx1 = [ measx1 , str2double(strline{1}{4}) ];
                measy1 = [ measy1 , str2double(strline{1}{5}) ];
                measx2 = [ measx2 , str2double(strline{1}{6}) ];
                measy2 = [ measy2 , str2double(strline{1}{7}) ];
            else
                measx1 = [ measx1 , NaN ];
                measy1 = [ measy1 , NaN ];
                measx2 = [ measx2 , NaN ];
                measy2 = [ measy2 , NaN ];
            end
        end
    end
    fclose(fid);
end
clear fid


% Open image
hold off
him = imshow([inpath imagelist{n}],'Parent',h);
imtitle = ['Image ' num2str(n) ': ' imagelist{n}];
title(h,strrep(imtitle,'_','\_'));

switch annotype
    case 'Annotation'
        fcn_callback = horzcat('switch get(gcbf,''SelectionType''), case ''normal''; ',...
            'CP = get(h,''CurrentPoint''); ',...
            'switch aflag, case {''scale1'',''scale2''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_defscale(aflag,''',scfile,''',h,CP,sc,''',annotype,'''); ',...
            'case {''meas1'',''meas2''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_measfeat(fid,aflag,CP,infotxt,''',annotype,'''); ',...
            'otherwise, fcn_annotate(fid,h,CP,selec); end; ',...
            'case ''alt''; fcn_pointer(gcf); end');
        
    case 'GeneratedPoint'
        fcn_callback = horzcat('switch get(gcbf,''SelectionType''), ',...
            'case ''normal''; ',...
            'CP = get(h,''CurrentPoint''); ',...
            'switch aflag, case {''scale1'',''scale2''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_defscale(aflag,''',scfile,''',h,CP,sc,''',annotype,'''); ',...
            'case {''meas1'',''meas2''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_measfeat(fid,aflag,CP,infotxt,''',annotype,'''); end; ',...
            'case ''alt''; fcn_pointer(gcf); end');
        
end
set(him,'ButtonDownFcn',fcn_callback);
hold on

% Plot rectangle
if exist(rectfile,'file')==2
    rect = importdata(rectfile,'\t');
    if ~isempty(rect) && numel(rect)==4
        rectangle('Position',rect,'EdgeColor','w','Tag','rectangle');
    end
end

% Plot existing annotations and length measurements
if ~isempty(x)
    for k=1:length(x)
        % the loop if required to make sure that individual objects are selectable
        
        if isempty(filterlist) || ismember(strlist{k},filterlist)==1 || ...
                ( ismember('Filter keywords that are not in this list',filterlist)==1 && ...
                ismember(strlist{k},kwlist)==0 )
            
            if ~isnan(measx1(k))
                plot(gca,measx1(k),measy1(k),'o','Color','c',...
                    'MarkerFaceColor','c','MarkerSize',4);
                plot(h,[measx1(k) measx2(k)],[measy1(k) measy2(k)],'-',...
                    'Color','c','Tag','MeasurementLine','UserData',[x(k),y(k)]);
            end
            
            switch annotype
                case 'Annotation'
                    cbfun = ['fid = fcn_seldelA(fid,gcbf,gcbo,infotxt,''',strlist{k},''');'];
                    plot(h,x(k),y(k),'o','Color','y','ButtonDownFcn',cbfun,'Tag','Annotation');
                    
                case 'GeneratedPoint'
                    ms = 6; % default marker size
                    colorcode = [{'w'},{'c'},{'k'}];
                    for c=1:numel(colorcode)
                        hplot = plot(h,x(k),y(k),'o',...
                            'Color',colorcode{c},'MarkerSize',ms,...
                            'Tag','GeneratedPoint');
                        ms = ms + 4;
                        
                        cbfun = ['fid = fcn_seldelGP(fid,gcbf,gcbo,infotxt,''',strlist{k},''');'];
                        set(hplot,'ButtonDownFcn',cbfun);
                        
                        if strcmp(strlist{k},'empty')~=1
                            if c==1
                                set(hplot,'Color','c');
                            else
                                set(hplot,'Visible','off');
                            end
                        end
                    end
            end
        end
        
    end
end
end

