function filterlist = fcn_filter(hObject,filterlist,hlist,defaultcolor)
%% Copyright 2015-2017 Yann Marcon and Autun Purser

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
switch get(hObject,'String')
    case 'Filter OFF'
        alphabet = 'abcdefghijklmnopkrstuvwxyz';
        
        strlist = get(hlist,'String');
        if isempty(strlist) || ( numel(strlist)==1 && (~any(ismember(strlist,alphabet)) || ...
                    strcmp(strlist{1}(1),'_')==1) )
            filterlist = [];
            return;
        elseif ~isempty(filterlist)
            [~,sel] = ismember(filterlist,strlist);
            sel(sel==0) = [];
            sel = sel + 2; % to compensate for the added lines
        else
            sel = 1;
        end
        strlist = [ {'Filter keywords that are not in this list' ; ''} ; strlist ];
        [sel,ok] = listdlg('Name','Filter','PromptString',...
            'Select one or more keywords:','SelectionMode','multiple',...
            'ListString',strlist,'InitialValue',sel,'ListSize',[500 500]);
        drawnow; pause(0.1); % prevents dialog box from freezing
        if ok == 0, return; end
        
        filterlist = strlist(sel);
        
        % filter the filterlist
        for k = numel(filterlist):-1:1 % go backwards
            if isempty(filterlist{k}) || ...
                    ~any(ismember(filterlist{k},alphabet)) || ...
                    strcmp(filterlist{k}(1),'_')==1
                filterlist(k) = [];
            end
        end
            
        set(hObject,'FontWeight','bold','BackgroundColor','g');
        set(hObject,'String','Filter ON');
        
    case 'Filter ON'
        filterlist = [];
        % defaultcolor = [0.9412,0.9412,0.9412];
        set(hObject,'FontWeight','normal','BackgroundColor',defaultcolor);
        set(hObject,'String','Filter OFF');
        
end

end