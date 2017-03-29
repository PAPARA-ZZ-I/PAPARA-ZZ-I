function [kwlist,WoRMSlist,WoRMSrecords] = fcn_popup1(hpop,hbutton,hlist,objWoRMS,kwlist,WoRMSlist,WoRMSrecords,first_match,ButtonColor)
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
strlist = get(hpop,'String');
sel = get(hpop,'Value');
selstr = strlist{sel};

% Get handles of ButWoRMS buttons
gp = get(hbutton,'Parent');
ButWoRMS = findobj(gp,'Tag','ButWoRMS');


%%
if strfind(selstr,'WoRMS'), selstr = 'WoRMS'; end

switch selstr
    case 'List of keywords'
        set(hbutton,'Callback','kwlist = fcn_keywords(hlist);');
        set(hbutton,'String','Load list of keywords');
        set(ButWoRMS,'Visible','off');
        set(ButWoRMS,'Enable','off');
        set(hlist,'Tag','keywords');
        set(hlist,'Position',[0 .2 1 .7]);
        set(hlist,'Value',1); % prevents display errors
        set(hlist,'String',kwlist);
        
    case 'WoRMS'
        if ~iscell(WoRMSlist) || ...
                ( numel(WoRMSlist)==1 && isempty(strtrim(WoRMSlist{1})) )
            % '2' is the Aphia ID of the 'Animalia' kingdom
            [WoRMSlist,~,WoRMSrecords] = fcn_WoRMS_search(objWoRMS,{'2'},...
                'Children from AphiaID','is in full','All taxa',[],[],first_match);
        end
        
        if exist('ButtonColor','var')~=1, ButtonColor = [.83 .89 .96]; end
        
        set(hbutton,'Callback','fcn_WoRMS(objWoRMS,GUIsize,ButtonColor);');
        set(hbutton,'String','WoRMS Taxon search');
        set(hlist,'Position',[0 .2 1 .671]);
        set(ButWoRMS,'Enable','on');
        set(ButWoRMS,'Visible','on');
        set(hlist,'Tag','WoRMS');
        set(hlist,'Value',1); % prevents display errors
        set(hlist,'String',WoRMSlist);
        
end

end
