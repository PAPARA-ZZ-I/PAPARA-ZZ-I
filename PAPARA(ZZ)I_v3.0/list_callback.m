function [item,fid,WoRMSflag] = list_callback(fid,hObject,h,infotxt,annotype)
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
WoRMSflag = 0;

index_selected = get(hObject,'Value');
list = get(hObject,'String');
item = list{index_selected};

alphabet = 'abcdefghijklmnopkrstuvwxyz';
if isempty(item) || ~any(ismember(item,alphabet)) || strcmp(item(1),'_')==1
    set(h,'HitTest','off');
    return;
else
    set(h,'HitTest','on');
end


% find handle of the main figure
h_tmp = hObject;
while h_tmp~=0
    h_tmp = get(h_tmp,'Parent');
    if h_tmp~=0, fig_main = h_tmp; end
end
clicktype = get(fig_main,'SelectionType');

switch clicktype
    case 'normal' % single click
        %% Check if the selection is an update of a selected point
        
        % Additional actions depending on object color
        h_sel = findobj(gca,'Selected','on');
        if isempty(h_sel), return; end
        
        h_sel = h_sel(1); % makes sure there is only one
        if all(get(h_sel,'Color')==[1,0,0])==1 % Check if object is red
            
            % CHANGE THE DATA FROM THE TEXT FILE
            fid = fcn_change_annotation(fid,h_sel,item);
            
            % CHANGE THE POINT ON THE GRAPH
            set(infotxt,'String','');
            set(infotxt,'TooltipString',get(infotxt,'String'));
            switch annotype
                case 'Annotation'
                    set(h_sel,'Selected','off','Color','c'); % cyan
                    
                    % update callback
                    fcn_update_cbfun(h_sel,item);
                    
                case 'GeneratedPoint'
                    hGP = findobj(0,'Tag','GeneratedPoint');
                    hGP = findobj(hGP,'XData',get(h_sel,'XData'));
                    hGP = findobj(hGP,'YData',get(h_sel,'YData'));
                    ms = get(hGP,'MarkerSize');
                    ms = cell2mat(ms);
                    [~,IX] = sort(ms);
                    hGP = hGP(IX);
                    %set(hGP(1),'Selected','off','Color','c'); % cyan
                    set(hGP(1),'Color','c'); % cyan
                    for k = 2:numel(hGP)
                        set(hGP(k),'Selected','off','Visible','off');
                    end
                    
                    % update callback
                    fcn_update_cbfun(hGP,item);
            end
            
        elseif all(get(h_sel,'Color')==[0,1,1])==1 % Check if object is cyan
            if strcmp(annotype,'GeneratedPoint')==1
                
                % SEARCH FOR OTHER ANNOTATIONS FOR SAME POINT
                [~,CStr,txtfile] = fcn_find_annotations(fid,h_sel);
                
                % Re-open the file in 'append' mode
                fid = fopen(txtfile,'a');
                
                x = get(h_sel,'XData');
                y = get(h_sel,'YData');
                XYKstr = sprintf('%f\t%f\t%s',x,y,item);
                
                % Search the lines with same X-Y-Keyword
                idC = strfind(CStr, XYKstr);
                id = find(~cellfun('isempty',idC), 1);
                
                % create annotation only if it does not exist already
                if isempty(id)
                    fcn_annotate(fid,[],[x,y],item,annotype);
                    fcn_update_cbfun(h_sel,item);
                    set(infotxt,'String',['Current selection: ' item]);
                    set(infotxt,'TooltipString',get(infotxt,'String'));
                end
            end
            
        end
        
    case 'open' % double click
        if strcmp(get(hObject,'Tag'),'WoRMS')==1 % if list contains WoRMS data
            % Search for the selected term in WoRMS
            WoRMSflag = 1;
        end
        
end

end
