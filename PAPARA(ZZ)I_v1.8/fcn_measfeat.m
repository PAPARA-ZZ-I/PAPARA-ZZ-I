function aflag = fcn_measfeat(fid,aflag,CP,infotxt,annotype)
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
switch aflag
    case 'meas1'
        
        % handle of selected annotation
        hsel = findobj(gca,'Selected','on');
        
        % Exit if nothing is selected
        if isempty(hsel)
            aflag = '';
            
            % Empty info text
            set(infotxt,'String','');
            set(infotxt,'TooltipString',get(infotxt,'String'));
            
            % Enable all buttons and toolbars
            fcn_freeze_fig('on',gcf,'Button-containing panel');
            
            % Enable selection of annotations
            set(findobj(gca,'Tag',annotype),'HitTest','on');
            
            % Set toolbar toggle button back to default
            set(findall(gcf,'Tag','Toolbar_Measure'),'State','off');
            
            return;
        end
        
        
        % Disable all buttons and toolbars
        fcn_freeze_fig('off',gcf,'Button-containing panel');
        fcn_freeze_ZoomPan('on',gcf);
        
        
        % DELETE THE DATA FROM THE TEXT FILE
        [~,CStr,txtfile,id] = fcn_find_annotations(fid,hsel);

        % Search and delete the line
        id = id(1);
        if ~isempty(id)
            str = CStr{id}; % save line to rewrite it later
            CStr(id) = [];
            CStr = CStr(~cellfun('isempty',CStr));
        end
        
        % WRITE DATA IN NEW FILE
        % Create a new file and save it again:
        fid = fopen(txtfile,'w');
        if fid == -1, error('Cannot open file'), end
        fprintf(fid,'%s\r\n',CStr{:});
        fclose(fid);
        
        % Read annotation data
        aData = textscan(str,'%f%f%s%f%f%f%f','Delimiter','\t'); % the last 4 variables may not exist
        x = aData{1};
        y = aData{2};
        annostr = aData{3}{1};
        
        switch annotype
            case 'Annotation'
                userdataStr = [x,y];
            case 'GeneratedPoint'
                x1 = aData{4};
                y1 = aData{5};
                userdataStr = [x,y,x1,y1];
        end
        
        % Delete any prior measurement for this feature
        delete(findobj(gca,'UserData',userdataStr));
        
        
        % Re-open the file in 'append' mode
        fid = fopen(txtfile,'a');
        fprintf(fid,'%f\t%f\t%s\t%f\t%f\t',x,y,annostr,CP(1,1),CP(1,2));
        
        if strcmp(annotype,'GeneratedPoint')==1
            x1 = str2double(sprintf('%f',CP(1,1)));
            y1 = str2double(sprintf('%f',CP(1,2)));
            userdataStr = [x,y,x1,y1];
        end
        
        % Draw the point on the graph
        % plot(gca,CP(1,1),CP(1,2),'+','Color','c','Tag','measurement_point');
        plot(gca,CP(1,1),CP(1,2),'o','Color','c','MarkerFaceColor','c',...
            'MarkerSize',4,'UserData',userdataStr);
        
        % Update info text
        infostr = get(infotxt,'String');
        id = strfind(infostr,':'); id = id(end);
        infostr = [infostr(1:id-1) ': now select REAR side of feature.'];
        set(infotxt,'String',infostr);
        set(infotxt,'TooltipString',get(infotxt,'String'));
        
        aflag = 'meas2';
            
        
    case 'meas2'
        % GET DATA FROM THE TEXT FILE
        txtfile = fopen(fid); % get filename
        fclose(fid);
        
        % read first point from the last line
        fid = fopen(txtfile,'r');
        while ~feof(fid)
            tline = fgets(fid);
        end
        fclose(fid);
        aData = textscan(tline,'%f%f%s%f%f','Delimiter','\t'); % the last 2 variables must exist
        x = aData{1}; % x of annotation
        y = aData{2}; % y of annotation
        x1 = aData{4}; % x of first point of measurement line
        y1 = aData{5}; % y of first point of measurement line
        
        switch annotype
            case 'Annotation'
                userdataStr = [x,y];
            case 'GeneratedPoint'
                userdataStr = [x,y,x1,y1];
        end
        
        % Open text file for appending
        fid = fopen(txtfile,'a');
        
        fprintf(fid,'%f\t%f\r\n',CP(1,1),CP(1,2));
%         plot(gca,CP(1,1),CP(1,2),'+','Color','c','Tag','measurement_point');
        plot([x1 CP(1,1)],[y1 CP(1,2)],'-','Color','c',...
            'Tag','MeasurementLine','UserData',userdataStr);
        aflag = '';
        
        % Delete the crosses
        % delete(findobj(gca,'Tag','measurement_point'));
        
        % Update info text
        set(infotxt,'String','');
        set(infotxt,'TooltipString',get(infotxt,'String'));
        
        % De-select the annotation if it is selected
        set(findobj(gca,'Selected','on'),'Selected','off');
        
        % Enable all buttons and toolbars
        fcn_freeze_fig('on',gcf,'Button-containing panel');
        
        % Enable selection of annotations
        set(findobj(gca,'Tag',annotype),'HitTest','on');
        
        % Set toolbar toggle button back to default
        set(findall(gcf,'Tag','Toolbar_Measure'),'State','off');
        
end

end
