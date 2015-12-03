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




%% Initialization

% Closes figure if it is already open
if ~isempty(findobj('Tag','annotatorGUI'))
    delete(findobj('Tag','annotatorGUI'));
end

clearvars;

% system properties:
switch computer % detects operating system
    case {'PCWIN','PCWIN64'}
        sep = '\'; % '\' for Windows systems
    case {'GLNX86','GLNXA64','MACI','MACI64'}
        sep = '/'; % '/' for Linux and MaxOS
end

warning off all;

% Add to path
if isdeployed
    
    % path of deployed code with subfolders
    pathsToAdd = {genpath(fullfile(ctfroot))};
    try
        for str = pathsToAdd
            % temporarily add folders to the OS path
            setenv('PATH',[getenv('PATH') ';' str{1}]);
        end
    end
    
    % Path to WoRMS 'aphia.xml' file
    WoRMSfile = 'aphia.php';
    
    % Create the WoRMS class in current folder
    % (I know changing the current folder is bad practice but i did not
    % find a better solution to prevent the Aphia Name Service folder from
    % being created wherever the current folder is. Although, there were
    % permissions issues when deploying in Linux, which are now solved. The
    % new 'matlab.wsdl.createWSDLClient' command present in MATLAB 2015b
    % could solve this issue more elegantly but it does not work in older
    % MATLAB versions and it needs additional dependencies to be installed
    % separately, which makes the whole deployed program less of a turnkey
    % product for the non computer-oriented users).
    currentfolder = pwd;
    cd(ctfroot); % change current folder 
    createClassFromWsdl(WoRMSfile);
    cd(currentfolder); % change current folder back
    
    
%     % Get path of the exe file where the WoRMS libraries are:
%     [status, result] = system('set PATH');
%     exePath = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
%
%     % Copy the WoRMS libraries to the deployed path
%     sourcefolder = [exePath sep 'WoRMS'];
%     destinationfolder = [ctfroot sep 'WoRMS'];
%     if exist(sourcefolder,'folder')==7 && ...
%             exist(destinationfolder,'folder')~=7
%         % if source folder exists and destination folder does not exist
%         
%         copyfile(sourcefolder,destinationfolder,'f');
%     end
%        
%     % path of deployed code with subfolders
%     pathsToAdd = {genpath(fullfile(ctfroot))};
%     try
%         for str = pathsToAdd
%             % temporarily add folders to the OS path
%             setenv('PATH',[getenv('PATH') ';' str{1}]);
%         end
%     end
    
else
    mPath = fileparts(mfilename('fullpath')); % path to folder where PAPARAZZI.m is located
    % WoRMSpath = [mPath sep 'WoRMS' sep];
    WoRMSpath = [mPath sep];
    addpath(WoRMSpath);
    WoRMSfile = [WoRMSpath 'aphia.php'];
    
    createClassFromWsdl(WoRMSfile);
end

% Create a WoRMS object from the WoRMS class
objWoRMS = AphiaNameService;



% initial values
n = 1;
sc = 1;
ButtonColor = [.83 .89 .96];
aflag = ''; % action flag to determine action when clicking on the image
lastsel = 1; % saves the selection within the list
kwlist = {' '};
searchstr = '2'; % '2' is the Aphia ID (WoRMS) of the 'Animalia' kingdom
WoRMSlist = [];
WoRMSrecords = [];
first_match = 1; % index of the first result to search for in the WoRMS database
filterlist = []; % empty filter
cversion = '1.6'; % current version
cdate = 'December 2015'; % current date
helpfile = [ 'PAPARAZZI_' , cversion , '_UserManual.pdf' ];
signaturestr = 'PAPARA(ZZ)I team:   Yann Marcon (development) & Autun Purser (design)';
paparazzistr = ['Program for Annotation of Photographs And Rapid ',...
    'Analysis (of Zillions and Zillions) of Images'];
TaxoRanking = {'Kingdom';'Subkingdom';'Phylum';'Subphylum';...
    'Infraphylum';'Superclass';'Class';'Subclass';'Infraclass';...
    'Superorder';'Order';'Suborder';'Infraorder';'Parvorder';...
    'Section';'Subsection';'Superfamily';'Family';'Subfamily';...
    'Supertribe';'Tribe';'Subtribe';'Genus';'Subgenus';'Species';...
    'Subspecies';'Natio';'Variety';'Subvariety';'Forma';'Subforma'};

% sets figure size
sel = 1; % id of primary monitor
scrsz = get(0,'MonitorPositions'); % gets screens dimensions and positions
x = scrsz(sel,1); % 1 = left pixel of the primary screen
y = scrsz(sel,2); % 1 = top pixel of the primary monitor (increases downwards)
scr_w = scrsz(sel,3) - (x-1); % width of selected monitor
scr_h = scrsz(sel,4) - (y-1); % height of selected monitor


%% Welcome screen
% Coordinates for main figure
fig_w = .8 * scr_w;
fig_h = .7 * scr_h;
fig_x = x + (scr_w - fig_w) / 2;
fig_y = scrsz(1,4) - (y-1) - fig_h + 1;
Welcomesize = [fig_x, fig_y, fig_w, fig_h];
cpr = sprintf('Copyright %s %s Yann Marcon and Autun Purser',char(169),cdate(end-4:end));

welname = sprintf('PAPARA(ZZ)I v%s - %s',cversion,cpr);
fig_welcome = figure('MenuBar','none','NumberTitle','off','Name',welname,...
    'WindowStyle','modal','Units','pixels','OuterPosition',Welcomesize,...
    'Resize','off','Tag','annotatorGUI',...
    'DeleteFcn','clearvars; return;');
hwelcome = axes('Parent',fig_welcome,'ActivePositionProperty','Position',...
    'Position',[0 .2 1 .8]);

% display image with transparent layer
[~,~,Alpha] = imread('papa_1000pix.png');
hlogo = imshow('papa_1000pix.png','Parent',hwelcome);
set(hlogo,'AlphaData',Alpha);

gp_user = uipanel('Parent',fig_welcome,'Visible','on','Position',[0 .05 1 .15]);
gp_signature = uipanel('Parent',fig_welcome,'Visible','on','Position',[0 0 1 .05]);
uicontrol('Parent',gp_user,'Style','text',...
    'String','Name of annotator:','FontUnits','normalized','FontSize',.5,...
    'FontWeight','bold','HorizontalAlignment','right','Units','normalized',...
    'Position',[.05 .1 .45 .6]);
h_userid = uicontrol('Parent',gp_user,'Style','edit',...
    'BackgroundColor',[1 1 1],'String','','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.55 .1 .25 .8]);
uicontrol('Parent',gp_user,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','OK','Units','normalized','Position',[.85 .1 .1 .8],...
    'CallBack','userid = fcn_userid(h_userid);');
uicontrol('Parent',gp_signature,'Style','text',...
    'String',paparazzistr,'FontWeight','bold',...
    'HorizontalAlignment','left','Units','normalized',...
    'Position',[.01 .1 .48 .6]);
uicontrol('Parent',gp_signature,'Style','text',...
    'String',signaturestr,'FontWeight','bold',...
    'HorizontalAlignment','right','Units','normalized',...
    'Position',[.51 .1 .48 .6]);
uiwait(gcf);
set(gcf,'DeleteFcn','');
close(gcf);
if exist('userid','var')~=1 || isempty(userid), clearvars; return; end

% % asks for userid
% userid = lower(strrep(inputdlg('Name of annotator:','Name'),' ','_'));
% if isempty(userid) || isempty(userid{1}), clearvars; return; end
% userid = userid{1};


%% asks for the input folder
inpath =  uigetdir('','Select image folder');
if inpath==0, clearvars; return; end
inpath = [inpath sep];

% inpath = 'E:\Documents\MATLAB\ImageAnnotator\images\';

% creates annotation folder
tmp = [inpath userid '_annotations' sep];
if isdir(tmp)==0, mkdir(tmp); end

% creates rectangle folder
tmp = [inpath userid '_rectangle' sep];
if isdir(tmp)==0, mkdir(tmp); end

% creates scale folder
tmp = [inpath userid '_scale' sep];
if isdir(tmp)==0, mkdir(tmp); end


imagelist = [];
strlist = {'jpg','JPG','jpeg','JPEG','tif','TIF','tiff','TIFF','png','PNG'};
for str = strlist
    imagelist = vertcat(imagelist,dir([inpath '*.' str{1}]));
end
imagelist = fcn_field2array(imagelist,'name','cell'); % convert to cell array
imagelist = unique(imagelist); % remove duplicates
nmax = numel(imagelist); % max number of images


%% defines callback functions
cbNval = horzcat('if isnan(str2double(get(h_val,''String'')))',...
    '|| str2double(get(h_val,''String'')) < 1 ',...
    '|| str2double(get(h_val,''String'')) > nmax, ',...
    'set(h_val,''String'',n); ',...
    'else n = str2double(get(h_val,''String'')); end');
cbFilter = horzcat('filterlist = fcn_filter(hfilter,filterlist,hlist,ButtonColor); ',...
    'ninc = 0; init_disp_image;');
cbList = horzcat('[selec,fid,WoRMSflag] = list_callback(fid,hlist,him,infotxt,annotype); ',...
    'if WoRMSflag==1, searchstr = fcn_listName2AphiaID(selec); ',...
    'searchtype = ''Children from AphiaID''; ',...
    '[WoRMSlist,WoRMSrecords] = ',...
    'fcn_WoRMS_hlist(hlist,objWoRMS,searchstr,searchtype,WoRMSlist,WoRMSrecords,1); ',...
    'first_match = 1; WoRMS_StepSize = numel(WoRMSlist); ',...
    '[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype); end; ',...
    'if strcmp(get(hlist,''Tag''),''WoRMS'')==1, ',...
    'k = get(hlist,''Value''); ',...
    'set(hranktxt,''String'',WoRMSrecords(k).rank); end;');
cbPop1 = horzcat('tmpsel = get(hlist,''Value''); ',...
    '[kwlist,WoRMSlist,WoRMSrecords] = ',...
    'fcn_popup1(hpop1,hbutton1,hlist,objWoRMS,kwlist,WoRMSlist,WoRMSrecords,first_match,ButtonColor); ',...
    'WoRMS_StepSize = numel(WoRMSlist);',...
    'set(hlist,''Value'',lastsel); lastsel = tmpsel; ',...
    '[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype);',...
    'k = get(hlist,''Value''); set(hranktxt,''String'',WoRMSrecords(k).rank);');
cbRank = horzcat('[parent_name,parent_rank] = ',...
    'fcn_WoRMS_parent(WoRMSrecords,TaxoRanking); ',...
    'searchstr = parent_name; searchtype = ''Scientific Name''; ',...
    '[WoRMSlist,WoRMSrecords] = ',...
    'fcn_WoRMS_hlist(hlist,objWoRMS,searchstr,searchtype,WoRMSlist,WoRMSrecords,1); ',...
    'first_match = 1; WoRMS_StepSize = numel(WoRMSlist); ',...
    '[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype);',...
    'k = get(hlist,''Value''); set(hranktxt,''String'',WoRMSrecords(k).rank);');
cbMoreRes = horzcat('first_match = numel(WoRMSlist) + 1; ',...
    'searchtype = ''Children from AphiaID''; ',...
    '[newWoRMSlist,newWoRMSrecords] = fcn_WoRMS_hlist(hlist,',...
    'objWoRMS,searchstr,searchtype,WoRMSlist,WoRMSrecords,first_match); ',...
    '[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype);',...
    'k = get(hlist,''Value''); set(hranktxt,''String'',WoRMSrecords(k).rank);');
cbRect = ['iptPointerManager(fig_main,''disable''); ',...
    'fcn_defrect(rectfile,h,GUIsize); ',...
    'iptPointerManager(fig_main,''enable'');'];
cbScaleBar = horzcat('if isempty(aflag), aflag = ''scale1''; ',...
    'fcn_freeze_fig(''off'',gcf,''Button-containing panel''); ',...
    'fcn_freeze_ZoomPan(''on'',gcf); ',...
    'set(h_scbar,''Enable'',''on''); set(him,''HitTest'',''on''); ',...
    'else, aflag = ''''; ',...
    'fcn_freeze_fig(''on'',gcf,''Button-containing panel''); ',...
    '[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype); end');
cbScaleVal = horzcat('if isnan(str2double(get(h_sc,''String'')))',...
    '|| str2double(get(h_sc,''String'')) <= 0 ',...
    'set(h_sc,''String'',sc); ',...
    'else sc = str2double(get(h_sc,''String'')); end');
cbPrev = 'ninc = -1; init_disp_image;'; % 'previous' button CallBack
cbNext = 'ninc = 1; init_disp_image;'; % 'next' button CallBack
cbMeas = horzcat('if ~isempty(findobj(gca,''Selected'',''on'')), ',...
    'aflag = ''meas1''; set(infotxt,''String'',',...
    '[get(infotxt,''String'') '': first select FRONT side of feature!'']); ',...
    'fcn_freeze_fig(''off'',gcf,''Button-containing panel''); ',...
    'fcn_freeze_ZoomPan(''on'',gcf); ',...
    'set(findobj(gcf,''Tag'',''Toolbar_Measure''),''Enable'',''on''); ',...
    'set(him,''HitTest'',''on''); ',...
    'else, aflag = ''''; ',...
    'fcn_freeze_fig(''on'',gcf,''Button-containing panel''); ',...
    'set(findall(gcf,''Tag'',''Toolbar_Measure''),''State'',''off''); ',...
    '[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype); end');
cbIgnore = horzcat('fcn_ignim(n,imagelist,inpath,userid,sep); ',...
    'init_disp_image;');
cbPointsDefault = horzcat('if exist(''pointtype'',''var'')~=1 && ',...
    'exist(''pointmax'',''var'')~=1, set(hPoints,''State'',''off''); ',...
    'return; end; init_disp_image;');
cb10Grid = horzcat('pointtype = ''grid''; pointmax = 10; ',...
    'fcn_updateGPicon(pointtype,pointmax); init_disp_image;');
cb100Grid = horzcat('pointtype = ''grid''; pointmax = 100; ',...
    'fcn_updateGPicon(pointtype,pointmax); init_disp_image;');
cbXGrid = horzcat('pointtype = ''grid''; pointmax = fcn_Xpoints(); ',...
    'fcn_updateGPicon(pointtype); init_disp_image;');
cb10Random = horzcat('pointtype = ''random''; pointmax = 10; ',...
    'fcn_updateGPicon(pointtype,pointmax); init_disp_image;');
cb100Random = horzcat('pointtype = ''random''; pointmax = 100; ',...
    'fcn_updateGPicon(pointtype,pointmax); init_disp_image;');
cbXRandom = horzcat('pointtype = ''random''; pointmax = fcn_Xpoints(); ',...
    'fcn_updateGPicon(pointtype); init_disp_image;');
cbPoints = [ {cbPointsDefault},{cb10Grid},{cb100Grid},{cbXGrid},{cb10Random},{cb100Random},{cbXRandom} ];
cbExport = horzcat('switch get(hPoints,''State''), ',...
    'case ''off'', fcn_export(userid,inpath,sep,annotype); ',...
    'case ''on'', fcn_export(userid,inpath,sep,annotype,pointtype,pointmax); ',...
    'end;');

% opening a pdf file is different depending on the OS
if ispc || ismac
    helpcmd = 'open(helpfile);';
% elseif isunix
%     helpcmd = ['system([''evince ' helpfile ' &]);'];
else
    if isdeployed
        tmpPath = [ ctfroot sep ];
    else
        tmpPath = [ mPath sep ];
    end
    helpcmd = ['msgbox(sprintf(''The help file cannot be opened ',...
        'automatically with this operating system.\n\n',...
        'Please open the following file manually: %s\n\n',...
        'The help file is located in:\n%s'',helpfile,tmpPath),',...
        '''Product Help'',''modal'');'];
end

cbHelp = horzcat('if exist(helpfile,''file'')==2, ', helpcmd ,...
    'else, errordlg(''Help file not found.'',''File missing'',''modal''); end;');
cbAbout = 'fcn_about(cversion,cdate);';



%% Main figure

% Coordinates for main figure
fig_w = scr_w;
fig_h = .92 * scr_h;
fig_x = x;
fig_y = scrsz(1,4) - (y-1) - fig_h + 1;
GUIsize = [fig_x, fig_y, fig_w, fig_h];

% Main figure
figname = sprintf(['PAPARA(ZZ)I v%s - %s                ',...
    'Current annotator: %s'],cversion,cpr,userid);
fig_main = figure('MenuBar','figure','NumberTitle','off','Name',figname,...
    'Units','pixels','OuterPosition',GUIsize,...
    'Resize','on','Tag','annotatorGUI','CloseRequestFcn',...
    ['delete(findobj(''Tag'',''annotatorGUI'')); ',...
    'if exist(''fid'',''var'')==1  && ~isempty(fopen(fid)), ',...
    'fclose(fid); end;'],'Visible','off');

% Hide unwanted tools from menubar and toolbar
hPoints = fcn_ctrl_FigTools(fig_main,'off',cbPrev,cbNext,cbMeas,cbRect,...
    cbIgnore,cbPoints,cbExport,cbHelp,cbAbout);
fcn_ctrl_FigMenus(fig_main,'off');
set(fig_main,'Visible','on');

% Create axes for image
uip_image = uipanel(fig_main,'Units','normalized','Position',[.2 0 .8 .9]);
h = axes('Parent',uip_image,'ActivePositionProperty','Position',...
    'Position',[0 0 1 .95],'Visible','off');


%% controls the change of pointer type when it moves over the figure
iptPointerManager(fig_main, 'enable');
pointerBehavior.enterFcn = @(fig_main, currentPoint) set(fig_main,'Pointer','cross');
pointerBehavior.exitFcn = [];
pointerBehavior.traverseFcn = [];
iptSetPointerBehavior(gca,pointerBehavior);

%% creates groups
gp_top = uipanel('Parent',fig_main,'Visible','on',...
    'Position',[.2 .9 .8 .1],'Tag','Button-containing panel');
gp_left = uipanel('Parent',fig_main,'Visible','on',...
    'Position',[0 .0 .2 1],'Tag','Button-containing panel');


%% display logo
% DEACTIVATED BECAUSE IT MAKES THE INTERFACE MUCH SLOWER
% gp_logo = uipanel('Parent',fig_main,'Visible','on',...
%     'Position',[.8 0 .2 .05],'Tag','Logo panel');

% % display image with transparent layer
% logo_axes = axes('Parent',gp_logo,'ActivePositionProperty',...
%     'Position','Position',[0 0 1 1]);
% set(fig_main,'currentaxes',h); % ensures the main axes are current axes
% [~,~,Alpha] = imread('papa_100pix.png');
% hlogo = imshow('papa_100pix.png','Parent',logo_axes);
% set(hlogo,'AlphaData',Alpha);


%% creates buttons
hfilter = uicontrol('Parent',gp_top,'Style','pushbutton',...
    'String','Filter OFF','BackgroundColor',ButtonColor,...
    'Units','normalized','Position',[.025 .54 .125 .42],...
    'CallBack',cbFilter);

uicontrol('Parent',gp_top,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Refresh / Go to image:','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.175 .54 .2 .42],...
    'CallBack','ninc = 0; init_disp_image;');

h_val = uicontrol('Parent',gp_top,'Style','edit',...
    'BackgroundColor',[1 1 1],'String',n,'Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.385 .54 .1 .42],...
    'CallBack',cbNval);

infotxt = uicontrol('Parent',gp_top,'Style','text',...
    'String','','FontUnits','normalized','FontSize',.6,...
    'HorizontalAlignment','center','Units','normalized',...
    'Position',[.025 .04 .47 .42]);

uicontrol('Parent',gp_top,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Previous image','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.515 .04 .225 .92],...
    'CallBack','ninc = -1; init_disp_image;');

uicontrol('Parent',gp_top,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Next image','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.77 .04 .225 .92],...
    'CallBack','ninc = 1; init_disp_image;');

hpop1 = uicontrol('Parent',gp_left,'Style','popupmenu',...
    'String',{'List of keywords';'Connect to WoRMS (http://www.marinespecies.org/)'},...
    'Units','normalized','Position',[.1 .955 .8 .04],...
    'CallBack',cbPop1);

hbutton1 = uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Load list of keywords',...
    'Units','normalized','Position',[.1 .91 .8 .04],...
    'CallBack','kwlist = fcn_keywords(hlist);');

hrank = uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'Visible','off','Enable','off','String','Higher rank',...
    'Tag','ButWoRMS','Units','normalized','Position',[.1 .875 .2 .03],...
    'TooltipString','Go a taxonomic rank higher','CallBack',cbRank);

hranktxt = uicontrol('Parent',gp_left,'Style','text',...
    'Visible','off','Enable','off','HorizontalAlignment','center',...
    'String','','Tag','ButWoRMS',...
    'Units','normalized','Position',[.325 .871 .275 .03]);

hMoreRes = uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'Visible','off','Enable','off','String','More results...',...
    'Tag','ButWoRMS','Units','normalized','Position',[.625 .875 .275 .03],...
    'TooltipString','Find more WoRMS results','CallBack',cbMoreRes);

hlist = uicontrol('Parent',gp_left,'Style','listbox',...
    'String',kwlist,'Tag','keywords','Units','normalized',...
    'Position',[0 .2 1 .7],'CallBack',cbList);

uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Replace a keyword in all images',...
    'Units','normalized','Position',[.1 .160 .8 .035],...
    'TooltipString','Replace a keyword in all images',...
    'CallBack','fcn_replacekw(inpath,userid,sep,hlist);');

h_scbar = uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Draw scale bar','TooltipString','Draw scale bar',...
    'Units','normalized','Position',[.1 .105 .8 .035],...
    'CallBack',cbScaleBar);

uicontrol('Parent',gp_left,'Style','text',...
    'String','scale [m]:',...
    'HorizontalAlignment','right','Units','normalized',...
    'Position',[.1 .065 .24 .035]);

h_sc = uicontrol('Parent',gp_left,'Style','edit',...
    'BackgroundColor',[1 1 1],'String',sc,...
    'Units','normalized','Position',[.38 .065 .24 .035],...
    'CallBack',cbScaleVal);

uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Apply','TooltipString','Apply scale value',...
    'Units','normalized','Position',[.65 .065 .24 .035],...
    'CallBack','fcn_applyscale(n,imagelist,inpath,aflag,sc,userid,sep);');

uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Export summary results','Tag','ExportResults',...
    'Units','normalized','Position',[.1 0.005 .8 .035],...
    'TooltipString','Export summary results','CallBack',cbExport);


%% other
[him,fid,sc,annotype,rectfile] = fcn_disp_image(n,imagelist,inpath,h,h_sc,0,userid,sep,kwlist,filterlist,infotxt);
[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype);
