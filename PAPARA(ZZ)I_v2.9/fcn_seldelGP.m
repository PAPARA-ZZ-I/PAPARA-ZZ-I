function fid = fcn_seldelGP(fid,h_gcbf,h_gcbo,infotxt,selstr)
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
% Handles of all three markers of the point, sorted by size
hGP_all = findobj(gca,'Tag','GeneratedPoint');
hGP = findobj(hGP_all,'XData',get(h_gcbo,'XData'));
hGP = findobj(hGP,'YData',get(h_gcbo,'YData'));
ms = get(hGP,'MarkerSize');
ms = cell2mat(ms);
[~,IX] = sort(ms);
hGP = hGP(IX);



% Action based on mouse state
mousestate = get(h_gcbf,'SelectionType'); 

switch mousestate
    case 'normal'
        % indicates single-click left button
        
        item = fcn_update_cbfun(hGP);
        switch get(hGP(1),'Selected')
            case 'off'
                % Un-select previously selected objects
                set(findobj(hGP_all,'Selected','on'),'Selected','off');
                set(findobj(hGP_all,'Color','r'),'Color','w');
                
                % Select current object
                if strcmp(item,'empty')==1 % if no annotation for this pt
                    set(hGP(1),'Color','r');
                end
                set(hGP(1),'Selected','on');
                str = ['Current selection: ' selstr];
                set(infotxt,'String',str);
                set(infotxt,'TooltipString',get(infotxt,'String'));
                
            case 'on'
                if strcmp(item,'empty')==1 % if no annotation for this pt
                    set(hGP(1),'Color','w');
                    if length(hGP) > 1, set(hGP(2:end),'Visible','on'); end
                else
                    set(hGP(1),'Color','c');
                end
                set(hGP(1),'Selected','off');
                set(infotxt,'String','');
                set(infotxt,'TooltipString',get(infotxt,'String'));
        end
        
    case 'alt'
        % indicates right-click or control-left
        if strcmpi(get(hGP(1),'Selected'),'on') == 1

            % CHANGE ANNOTATION BACK TO 'EMPTY'
            [fid,newstr,userdataStr] = fcn_change_annotation(fid,hGP(1),'empty',1);
            
            % update callback
            fcn_update_cbfun(hGP,newstr);
            
            % CHANGE THE POINT ON THE GRAPH...OR NOT
            if isempty(newstr) || strcmp(newstr,'empty')==1 % change
                set(infotxt,'String','');
                set(hGP(1),'Selected','off','Color','w');
                if length(hGP) > 1, set(hGP(2:end),'Visible','on'); end
            else % no change
                set(infotxt,'String',['Current selection: ' newstr]);
            end
            set(infotxt,'TooltipString',get(infotxt,'String'));
            
            % delete size measurement
            delete(findobj(gca,'UserData',userdataStr));
            
        end
        
    case 'open'
        % indicates double-click (either button)
        return
        
    case 'extend'
        % indicates shift-click (either button)
        
        switch get(hGP(1),'Selected')
            case 'off'
                return
                
            case 'on'
                % SEARCH FOR OTHER ANNOTATIONS FOR SAME POINT
                [id,CStr,txtfile] = fcn_find_annotations(fid,h_gcbo);
                
                % Re-open the file in 'append' mode
                fid = fopen(txtfile,'a'); % it is used in parent functions
                
                if ~isempty(id)
                    
                    k = 1;
                    while k <= numel(id)
                        strline = textscan(CStr{id(k)},'%s', 'delimiter', '\t');
                        if strcmp(strline{1}{3},selstr)==1
                            if k==numel(id), k = 0; end
                            strline = textscan(CStr{id(k+1)},'%s', 'delimiter', '\t');
                            break;
                        end
                        k = k + 1;
                    end
                    
                    % update annotation text
                    selstr = strline{1}{3};
                    
                    % update callback function of the point
                    fcn_update_cbfun(hGP,selstr);
                    
                    % update the info text
                    str = ['Current selection: ' selstr];
                    set(infotxt,'String',str);
                    set(infotxt,'TooltipString',get(infotxt,'String'));
                end
        end
        
end

end
