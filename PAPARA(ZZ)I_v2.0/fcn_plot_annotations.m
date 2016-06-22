function him = fcn_plot_annotations(h,txtfile,n,imagelist,inpath,rectfile,scfile,aflag,kwlist,filterlist,infotxt,annotype)
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




%% Create generated points if they don't exist at all
checkflag = 1; % enables the checking if points fall outside of rectangle
if strcmp(annotype,'GeneratedPoint')==1 && exist(txtfile,'file')~=2
    % if points do not exist, create them
    [~,~] = fcn_generatepoints(txtfile,rectfile);
    checkflag = 0;
end


%% Read existing annotations
[x,y,strlist,meas1,meas2] = fcn_read_annotations(txtfile);


%% Re-create generated points if they don't fall outside of rectangle
if strcmp(annotype,'GeneratedPoint')==1 && checkflag==1
    % if both points and rectangle exist too, prompt user for action
    if ~isempty(rectfile) && exist(rectfile,'file')==2
        rect = importdata(rectfile,'\t');
        if ~isempty(rect) && numel(rect)==4 % ensure that rectangle exists
            
            % search for outlying points
            x_out1 = x < rect(1,1); x_out2 = x > (rect(1,1)+rect(1,3));
            y_out1 = y < rect(1,2); y_out2 = y > (rect(1,2)+rect(1,4));
            outliers = x_out1 + x_out2 + y_out1 + y_out2;
            
            if any(outliers)
                if isempty(strfind(txtfile,'grid.txt'))
                    pointtype = 'random';
                else
                    pointtype = 'grid';
                end
                str1 = ['Some of the ',pointtype,...
                    ' points lie outside of the usable area. ',...
                    'Do you want to re-generate the points for this image?'];
                str2 = ['Warning: all existing ',pointtype,...
                    ' points will be deleted (for this image only).'];
                msg = sprintf('%s\n\n%s',str1,str2);
                msg2 = ['Generate new ',pointtype,' points'];
                answer = questdlg(msg,'Confirmation required',msg2,...
                    'Cancel','Cancel');
                
                if strcmp(answer,msg2)==1
                    % Re-create points
                    [~,~] = fcn_generatepoints(txtfile,rectfile);
                    
                    % Read newly created points
                    [x,y,strlist,meas1,meas2] = fcn_read_annotations(txtfile);
                end
            end
        end
    end
end


%% Open image
hold off
him = imshow([inpath imagelist{n}],'Parent',h);
imtitle = ['Image ' num2str(n) ': ' imagelist{n}];
title(h,strrep(imtitle,'_','\_'));

% Reset zoom
% (this line is required or the zoom buttons will not zoom out
% properly. This is caused by the fcn_scrollzoom function).
zoom reset;

switch annotype
    case 'Annotation'
        fcn_callback = horzcat('switch get(gcbf,''SelectionType''), case ''normal''; ',...
            'CP = get(h,''CurrentPoint''); ',...
            'switch aflag, case {''scale1'',''scale2''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_defscale(aflag,''',scfile,''',h,CP,sc,''',annotype,'''); ',...
            'case {''meas1'',''meas2'',''meas3'',''meas4''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_measfeat(fid,aflag,CP,infotxt,''',annotype,'''); ',...
            'otherwise, fcn_annotate(fid,h,CP,selec,annotype); end; ',...
            'case ''alt''; fcn_pointer(gcf); end');
        
    case 'GeneratedPoint'
        fcn_callback = horzcat('switch get(gcbf,''SelectionType''), ',...
            'case ''normal''; ',...
            'CP = get(h,''CurrentPoint''); ',...
            'switch aflag, case {''scale1'',''scale2''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_defscale(aflag,''',scfile,''',h,CP,sc,''',annotype,'''); ',...
            'case {''meas1'',''meas2'',''meas3'',''meas4''}, ',...
            'set(findobj(gca,''Tag'',''',annotype,'''),''HitTest'',''off''); ',...
            'aflag = fcn_measfeat(fid,aflag,CP,infotxt,''',annotype,'''); end; ',...
            'case ''alt''; fcn_pointer(gcf); end');
        
end
set(him,'ButtonDownFcn',fcn_callback);
hold on

%% Plot rectangle
if exist(rectfile,'file')==2
    rect = importdata(rectfile,'\t');
    if ~isempty(rect) && numel(rect)==4
        rectangle('Position',rect,'EdgeColor','w','Tag','rectangle');
    end
end

%% Plot existing annotations and length measurements
if ~isempty(x)
    for k=1:length(x)
        % the loop if required to make sure that individual objects are selectable
        
        if isempty(filterlist) || ismember(strlist{k},filterlist)==1 || ...
                ( ismember('Filter keywords that are not in this list',filterlist)==1 && ...
                ismember(strlist{k},kwlist)==0 )
            
            switch annotype
                case 'Annotation'
                    userdataStr = [x(k),y(k)];
                case 'GeneratedPoint'
                    userdataStr = [x(k),y(k),meas1.x1(k),meas1.y1(k)];
            end
            
            % Draw length measurement
            if ~isnan(meas1.x1(k))
                plot(gca,meas1.x1(k),meas1.y1(k),'o','Color','c',...
                    'MarkerFaceColor','c','MarkerSize',4,'UserData',userdataStr);
                plot(h,[meas1.x1(k) meas1.x2(k)],[meas1.y1(k) meas1.y2(k)],'-',...
                    'Color','c','Tag','MeasurementLine','UserData',userdataStr);
            end
            
            % Draw width measurement
            if ~isnan(meas2.x1(k))
                plot(h,[meas2.x1(k) meas2.x2(k)],[meas2.y1(k) meas2.y2(k)],'-',...
                    'Color','b','Tag','MeasurementLine','UserData',userdataStr);
            end
            
            switch annotype
                case 'Annotation'
                    cbfun = ['fid = fcn_seldelA(fid,gcbf,gcbo,infotxt,''',strlist{k},''');'];
                    plot(h,x(k),y(k),'o','Color','y','ButtonDownFcn',cbfun,'Tag','Annotation');
                    
                case 'GeneratedPoint'
                    
                    % multi-annotation: check if there is already a point at that position
                    if isempty(findobj(h,'XData',x(k),'YData',y(k)))
                        % plot point if it does not exist already
                        
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
end

