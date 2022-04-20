function fcn_WoRMS(objWoRMS,GUIsize,ButtonColor)
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
searchres = {''};

fig_w = 500;
fig_h = 500;
fig_x = GUIsize(1,1) + (GUIsize(1,3) - fig_w)/2;
fig_y = GUIsize(1,1) + (GUIsize(1,4) - fig_h)/2;

fig_search = figure('WindowStyle','modal','MenuBar','none','NumberTitle','off',...
    'Name','WoRMS Taxon search','Units','pixels',...
    'OuterPosition',[fig_x, fig_y, fig_w, fig_h],'Resize','on');
% fig_search = figure('MenuBar','none','NumberTitle','off',...
%     'Name','CHANGE BACK TO MODAL FIG','Units','pixels',...
%     'OuterPosition',[fig_x, fig_y, fig_w, fig_h],'Resize','off');


%% Buttons
strlist1 = {'Scientific Name';'Common Name';'AphiaID';...
    '[BOLD] Barcode of Life Database (BOLD) TaxID'; ...
    '[DYNTAXA] Dyntaxa ID'; ...
    '[EOL] Encyclopedia of Life (EoL) page identifier'; ...
    '[FISHBASE] FishBase species ID'; ...
    '[IUCN] IUCN Red List Identifier'; ...
    '[LSID] Life Science Identifier'; ...
    '[NCBI] NCBI Taxonomy ID (Genbank)'; ...
    '[ITIS] ITIS Taxonomic Serial Number'; ...
    '[GISD] Global Invasive Species Database'};
strlist2 = {'contains';'is in full';'begins with';'ends with'};
strlist3 = {'Marine only';'All taxa'};

% initialize variables
selstr1 = strlist1{1};
selstr2 = strlist2{1};
selstr3 = strlist3{1};

% Define buttons
htmp1 = uicontrol('Parent',fig_search,'Style','popupmenu',...
    'String',strlist1,'Tag','htmp1',...
    'Units','normalized','Position',[.04 .9 .55 .08]);
htmp2 = uicontrol('Parent',fig_search,'Style','popupmenu',...
    'String',strlist2,'Tag','htmp2',...
    'Units','normalized','Position',[.61 .9 .16 .08]);
htmp3 = uicontrol('Parent',fig_search,'Style','popupmenu',...
    'String',strlist3,'Tag','htmp3',...
    'Units','normalized','Position',[.79 .9 .17 .08]);
htxt = uicontrol('Parent',fig_search,'Style','edit',...
    'BackgroundColor',[1 1 1],'String','','Tag','htxt',...
    'Units','normalized','Position',[.04 .81 .92 .08]);
hsearch = uicontrol('Parent',fig_search,'Style','pushbutton',...
    'String','Search','BackgroundColor',ButtonColor,...
    'Units','normalized','Position',[.04 .76 .4 .04]);
htxtleft = uicontrol('Parent',fig_search,'Style','listbox',...
    'BackgroundColor',[1 1 1],'String',searchres,'Tag','htxtleft',...
    'Units','normalized','Position',[.04 .1 .44 .64],'Enable','on');
htxtright = uicontrol('Parent',fig_search,'Style','listbox',...
    'BackgroundColor',[1 1 1],'String',searchres,'Tag','htxtright',...
    'Units','normalized','Position',[.52 .1 .44 .64],'Enable','on');
hmore = uicontrol('Parent',fig_search,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'Enable','off','String','More results...','Tag','MoreResults',...
    'Units','normalized','Position',[.04 .05 .44 .04]);


%% Callbacks
callback1 = ['htmp1 = findobj(gcf,''Tag'',''htmp1'');', ...
    'tmplist1 = get(htmp1,''String''); ', ...
    'sel1 = get(htmp1,''Value''); ', ...
    'selstr1 = tmplist1{sel1};'];
set(htmp1,'Callback',callback1);

callback2 = ['htmp2 = findobj(gcf,''Tag'',''htmp2'');', ...
    'tmplist2 = get(htmp2,''String''); ', ...
    'sel2 = get(htmp2,''Value''); ', ...
    'selstr2 = tmplist2{sel2};'];
set(htmp2,'Callback',callback2);

callback3 = ['htmp3 = findobj(gcf,''Tag'',''htmp3'');', ...
    'tmplist3 = get(htmp3,''String''); ', ...
    'sel3 = get(htmp3,''Value''); ', ...
    'selstr3 = tmplist3{sel3};'];
set(htmp3,'Callback',callback3);

search_callback = [callback1,callback2,callback3, ...
    'htxt = findobj(gcf,''Tag'',''htxt'');', ...
    'htxtleft = findobj(gcf,''Tag'',''htxtleft'');', ...
    'htxtright = findobj(gcf,''Tag'',''htxtright'');', ...
    'searchstr = get(htxt,''String''); ', ...
    'searchstr = strtrim(searchstr); ', ...
    'if ~isempty(searchstr), first_match = 1;',...
    '[searchres,searchreclist,searchrecstruct] = fcn_WoRMS_search(objWoRMS,', ...
    'searchstr,selstr1,selstr2,selstr3,htxtleft,htxtright,first_match); ', ...
    'results_StepSize = numel(searchres); if numel(searchres)>1, ',...
    'if ismember(selstr1,{''Common Name'';''Children from AphiaID''}), ',...
    'set(findobj(gcf,''Tag'',''MoreResults''),''Enable'',''on''); end; end; end;'];
set(hsearch,'Callback',search_callback);

htxtleft_callback = ['if exist(''searchres'',''var'')==1, ',...
    '[searchres,searchrecstruct] = ',...
    'fcn_htxtleft_callback(hlist,searchres,searchreclist,searchrecstruct); ', ...
    'if isempty(findobj(0,''Name'',''WoRMS Taxon search'')), ',...
    'WoRMSlist = searchres;, WoRMSrecords = searchrecstruct; ',...
    'if numel(WoRMSlist)==1, first_match = 1; WoRMS_StepSize = 1; ',...
    '[selec,fid,~] = list_callback(fid,hlist,him,infotxt); end; ',...
    'if strcmp(get(hlist,''Tag''),''WoRMS'')==1, ',...
    'k = get(hlist,''Value''); ',...
    'set(hranktxt,''String'',WoRMSrecords(k).rank); end; end; end;'];
set(htxtleft,'Callback',htxtleft_callback);

hmore_callback = horzcat('htxtleft = findobj(gcf,''Tag'',''htxtleft''); ',...
    'first_match = numel(searchres) + 1; ',...
    '[newsearchres,newreclist,newrecstruct] = fcn_WoRMS_search(objWoRMS,',...
    'searchstr,selstr1,selstr2,selstr3,htxtleft,htxtright,first_match,',...
    'searchres,searchreclist,searchrecstruct); ',...
    'if (numel(newsearchres)-numel(searchres))<results_StepSize, ',...
    'set(findobj(gcf,''Tag'',''MoreResults''),''Enable'',''off''); end;',...
    'if numel(newsearchres)>=numel(searchres), ',...
    'searchres = newsearchres; searchreclist = newreclist; ',...
    'searchrecstruct = newrecstruct; end;');
set(hmore,'Callback',hmore_callback);

end
