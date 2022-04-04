function fid = fcn_seldelA(fid,h_gcbf,h_gcbo,infotxt,selstr)
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
mousestate = get(h_gcbf,'SelectionType'); 

switch mousestate
    case 'normal'
        % indicates single-click left button
        switch get(h_gcbo,'Selected')
            case 'off'
                % Un-select previously selected objects
                set(findobj(gca,'Selected','on'),'Selected','off');
                set(findobj(gca,'Color','r'),'Color','y');
                
                % Select current object
                set(h_gcbo,'Selected','on');
                str = ['Current selection: ' selstr];
                set(infotxt,'String',str);
                set(infotxt,'TooltipString',get(infotxt,'String'));
                
            case 'on'
                if ~all(get(h_gcbo,'Color')==[0,1,1]) % check if cyan
                    set(h_gcbo,'Color','y');
                end
                set(h_gcbo,'Selected','off');
                set(infotxt,'String','');
                set(infotxt,'TooltipString',get(infotxt,'String'));
        end
        
    case 'alt'
        % indicates right-click or control-left
        if strcmpi(get(h_gcbo,'Selected'),'on') == 1

            % DELETE THE DATA FROM THE TEXT FILE
            [id,CStr,txtfile,~,x,y] = fcn_find_annotations(fid,h_gcbo);
            
            id = id(1);
            if ~isempty(id)
                CStr(id) = [];
                CStr = CStr(~cellfun('isempty',CStr));
            end
            
            % Create a new file and save it again:
            fid = fopen(txtfile,'w');
            if fid == -1, error('Cannot open file'), end
            fprintf(fid,'%s\r\n',CStr{:});
            fclose(fid);
            
            % Re-open the file in 'append' mode
            fid = fopen(txtfile,'a');
            
            % DELETE THE POINT ON THE GRAPH
            set(infotxt,'String','');
            set(infotxt,'TooltipString',get(infotxt,'String'));
            delete(h_gcbo); % deletes the link from the figure
            userdataStr = [str2double(sprintf('%f',x)) str2double(sprintf('%f',y))];
            delete(findobj(gca,'UserData',userdataStr));
            
        end
        
    case 'open'
        % indicates double-click (either button)
        return
        
    case 'extend'
        % indicates shift-click (either button)
        
        % Un-select previously selected objects
        set(findobj(gca,'Selected','on'),'Selected','off');
        set(findobj(gca,'Color','r'),'Color','y');
        
        set(h_gcbo,'Selected','on','Color','r');
        str = ['Current selection: ' selstr];
        set(infotxt,'String',str);
        set(infotxt,'TooltipString',get(infotxt,'String'));
        
end

end
