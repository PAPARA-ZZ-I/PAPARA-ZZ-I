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
ds = 1; % display scale ['display cm' per 'image cm']
dsflag = 0; % activate/deactivate display resolution limit
ppi = get(0,'ScreenPixelsPerInch'); % pixels per inch of monitor
ButtonColor = [.83 .89 .96];
aflag = ''; % action flag to determine action when clicking on the image
lastsel = 1; % saves the selection within the list
kwlist = {' '};
searchstr = '2'; % '2' is the Aphia ID (WoRMS) of the 'Animalia' kingdom
WoRMSlist = [];
WoRMSrecords = [];
first_match = 1; % index of the first result to search for in the WoRMS database
filterlist = []; % empty filter
cversion = '2.8'; % current version
cdate = 'October 2017'; % current date
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
scr_w = scrsz(sel,3); % width of selected monitor
scr_h = scrsz(sel,4); % height of selected monitor


%% Welcome screen
% Coordinates for main figure
fig_w = .8 * scr_w;
fig_h = .7 * scr_h;
fig_x = x + (scr_w - fig_w) / 2;
fig_y = scrsz(1,4) + (y-1) - fig_h + 1;
Welcomesize = [fig_x, fig_y, fig_w, fig_h];
cpr = sprintf('Copyright %s 2015-%s Yann Marcon and Autun Purser',char(169),cdate(end-3:end));

welname = sprintf('PAPARA(ZZ)I v%s - %s',cversion,cpr);
fig_welcome = figure('MenuBar','none','NumberTitle','off','Name',welname,...
    'WindowStyle','modal','Units','pixels','OuterPosition',Welcomesize,...
    'Resize','on','Tag','annotatorGUI',...
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
ttline1 = 'The user name is used to differenciate annotations made by different users.';
ttline2 = 'Try to always use the same user name for your annotations.';
ttstr = sprintf('%s\n%s',ttline1,ttline2);
h_userid = uicontrol('Parent',gp_user,'Style','edit',...
    'BackgroundColor',[1 1 1],'String','','Tag','ChangeImageButtons',...
    'Units','normalized','TooltipString',ttstr,'Position',[.55 .1 .25 .8]);
uicontrol('Parent',gp_user,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','OK','Units','normalized','Position',[.85 .1 .1 .8],...
    'CallBack','userid = fcn_userid(h_userid);');
uicontrol('Parent',gp_signature,'Style','text',...
    'String',paparazzistr,'FontWeight','bold',...
    'HorizontalAlignment','left','Units','normalized',...
    'Position',[.01 .1 .58 .6]);
uicontrol('Parent',gp_signature,'Style','text',...
    'String',signaturestr,'FontWeight','bold',...
    'HorizontalAlignment','right','Units','normalized',...
    'Position',[.61 .1 .38 .6]);
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

imagelist = [];
strlist = {'jpg','JPG','jpeg','JPEG','tif','TIF','tiff','TIFF','png','PNG'};
for str = strlist
    imagelist = vertcat(imagelist,dir([inpath '*.' str{1}]));
end
imagelist = fcn_field2array(imagelist,'name','cell'); % convert to cell array
imagelist = unique(imagelist); % remove duplicates
nmax = numel(imagelist); % max number of images

if nmax==0, clearvars; return; end

% creates annotation folder
tmp = [inpath userid '_annotations' sep];
if isdir(tmp)==0, mkdir(tmp); end

% creates rectangle folder
tmp = [inpath userid '_rectangle' sep];
if isdir(tmp)==0, mkdir(tmp); end

% creates scale folder
tmp = [inpath userid '_scale' sep];
if isdir(tmp)==0, mkdir(tmp); end


% Randomize imagelist
[imagelist,nmax] = fcn_randim(imagelist,inpath,userid,sep);


%% defines callback functions
cbNval = horzcat('if isnan(str2double(get(h_val,''String'')))',...
    '|| str2double(get(h_val,''String'')) < 1 ',...
    '|| str2double(get(h_val,''String'')) > nmax, ',...
    'set(h_val,''String'',n); ',...
    'else n = str2double(get(h_val,''String'')); end');
cbFilter = horzcat('filterlist = fcn_filter(hfilter,filterlist,hlist,ButtonColor); ',...
    'ninc = 0; init_disp_image;');
cbHideShow = horzcat('switch get(hhideshow,''Value''), ',...
    'case 1, set(hhideshow,''String'',''Hide annotations''); ',...
    'case 0, set(hhideshow,''String'',''Show annotations''); end; ',...
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
cbImAdjust = horzcat('adjB = 1 - get(hbrightness,''Value''); ',...
    'adjC = get(hcontrast,''Value''); ',...
    'adjG = get(hgamma,''Value'') + 1; ',...
    'fcn_imcalcs(him,imdbl,class(imCData),adjB,adjC,adjG);');
cbPrev = 'ninc = -1; init_disp_image;'; % 'previous' button CallBack
cbNext = 'ninc = 1; init_disp_image;'; % 'next' button CallBack
cbPrevSection = 'pn = -1; fcn_navigate_image_sections(h,pn);'; % 'previous' button CallBack
cbNextSection = 'pn = 1; fcn_navigate_image_sections(h,pn);'; % 'next' button CallBack
cbMeas = horzcat('hToolbar = findall(gcf,''Tag'',''FigureToolBar''); ',...
    'if ~isempty(findobj(h,''Selected'',''on'')) && ~numel(aflag), ',...
    'aflag = ''meas1''; set(infotxt,''String'',',...
    '[get(infotxt,''String'') '': (PT1) select FRONT side of feature'']); ',...
    'fcn_freeze_fig(''off'',gcf,''Button-containing panel''); ',...
    'fcn_freeze_ZoomPan(''on'',gcf); ',...
    'set(findobj(hToolbar,''Tag'',''Toolbar_Measure''),''Enable'',''on''); ',...
    'set(him,''HitTest'',''on''); ',...
    'else, if strcmp(aflag,''meas3''), fprintf(fid,''\r\n''); ',...
    'set(findobj(h,''Selected'',''on''),''Selected'',''off''); ',...
    'set(findobj(h,''Tag'',annotype),''HitTest'',''on''); end; ',...
    'aflag = ''''; fcn_infotxt(infotxt); ',...
    'fcn_freeze_fig(''on'',gcf,''Button-containing panel''); ',...
    'set(findall(hToolbar,''Tag'',''Toolbar_Measure''),''State'',''off''); ',...
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
cbSaveDefault = horzcat('if exist(''imformat'',''var'')~=1, ',...
    'set(hSave,''State'',''off''); return; end; ',...
    'switch imformat, case {''JPG'',''TIF''},', ...
    'switch get(hPoints,''State''), ',...
    'case ''off'', fcn_save_image(n,imagelist,inpath,userid,sep,h,imformat,annotype); ',...
    'case ''on'', fcn_save_image(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax); ',...
    'end;',...
    'case {''EPS2'',''EPS3''},', ...
    'switch get(hPoints,''State''), ',...
    'case ''off'', fcn_save_eps(n,imagelist,inpath,userid,sep,h,imformat,annotype); ',...
    'case ''on'', fcn_save_eps(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax); ',...
    'end; end; set(hSave,''State'',''off'');');
cbSaveJPG = horzcat('imformat = ''JPG''; fcn_updateSAVEicon(imformat); ',...
    'switch get(hPoints,''State''), ',...
    'case ''off'', fcn_save_image(n,imagelist,inpath,userid,sep,h,imformat,annotype); ',...
    'case ''on'', fcn_save_image(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax); ',...
    'end; set(hSave,''State'',''off'');');
cbSaveTIF = horzcat('imformat = ''TIF''; fcn_updateSAVEicon(imformat); ',...
    'switch get(hPoints,''State''), ',...
    'case ''off'', fcn_save_image(n,imagelist,inpath,userid,sep,h,imformat,annotype); ',...
    'case ''on'', fcn_save_image(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax); ',...
    'end; set(hSave,''State'',''off'');');
cbSaveEPS2 = horzcat('imformat = ''EPS2''; fcn_updateSAVEicon(imformat); ',...
    'switch get(hPoints,''State''), ',...
    'case ''off'', fcn_save_eps(n,imagelist,inpath,userid,sep,h,imformat,annotype); ',...
    'case ''on'', fcn_save_eps(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax); ',...
    'end; set(hSave,''State'',''off'');');
cbSaveEPS3 = horzcat('imformat = ''EPS3''; fcn_updateSAVEicon(imformat); ',...
    'switch get(hPoints,''State''), ',...
    'case ''off'', fcn_save_eps(n,imagelist,inpath,userid,sep,h,imformat,annotype); ',...
    'case ''on'', fcn_save_eps(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax); ',...
    'end; set(hSave,''State'',''off'');');
cbSave = [ {cbSaveDefault},{cbSaveJPG},{cbSaveTIF},{cbSaveEPS2},{cbSaveEPS3} ];
cbDs = horzcat('dsflag = get(h_dscb,''Value''); ',...
    'fcn_displayresolution(h,h_ds,h_ppi,dsflag,[],n,imagelist,inpath,userid,sep);');
cbPPI = horzcat('if isnan(str2double(get(h_ppi,''String'')))',...
    '|| str2double(get(h_ppi,''String'')) <= 0 ',...
    'set(h_ppi,''String'',ppi); ',...
    'else ppi = str2double(get(h_ppi,''String'')); end; ',cbDs);
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
fig_y = scrsz(1,4) + (y-1) - fig_h + 1;
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
[hPoints,hSave] = fcn_ctrl_FigTools(fig_main,'off',cbPrevSection,...
    cbNextSection,cbMeas,cbRect,cbIgnore,cbPoints,cbSave,cbExport,cbHelp,cbAbout);
fcn_ctrl_FigMenus(fig_main,'off');
set(fig_main,'Visible','on');

% Create axes for image
uip_image = uipanel(fig_main,'Units','normalized','Position',[.2 0 .8 .9]);
h = axes('Parent',uip_image,'ActivePositionProperty','Position',...
    'Position',[0 0 1 .95],'Visible','off','UserData',[]);

% Create sliders
% pos_image = get(uip_image,'Position');
% sliderV_thick = 15 / (pos_image(3) * fig_w); % vertical slider must be 15 pixel thick
% sliderH_thick = 15 / (pos_image(4) * fig_h); % horizontal slider must be 15 pixel thick
% sliderV_pos = [ 1 - sliderV_thick , 0 , sliderV_thick , 1 ];
% sliderH_pos = [ 0 , 0 , 1 , sliderH_thick ];
% sliderV_image = uicontrol('Style','Slider','Parent',uip_image,'Units','normalized','Position',sliderV_pos,'Value',1); %,'Callback',{@slider_callback1,panel2});
% sliderH_image = uicontrol('Style','Slider','Parent',uip_image,'Units','normalized','Position',sliderH_pos,'Value',1); %,'Callback',{@slider_callback1,panel2});

% Set scrolling ability
set(fig_main,'WindowScrollWheelFcn',@fcn_scrollzoom);

%% controls the change of pointer type when it moves over the figure
iptPointerManager(fig_main, 'enable');
pointerBehavior.enterFcn = @(fig_main, currentPoint) set(fig_main,'Pointer','cross');
pointerBehavior.exitFcn = [];
pointerBehavior.traverseFcn = [];
iptSetPointerBehavior(h,pointerBehavior);

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
    'Units','normalized','Position',[.005 .54 .1 .42],...
    'CallBack',cbFilter);

hhideshow = uicontrol('Parent',gp_top,'Style','togglebutton',...
    'BackgroundColor',ButtonColor,'Min',1,'Max',0,'Value',1,...
    'String','Hide annotations','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.115 .54 .1 .42],...
    'CallBack',cbHideShow);

uicontrol('Parent',gp_top,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Refresh / Go to image:','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.225 .54 .115 .42],...
    'CallBack','ninc = 0; init_disp_image;');

h_val = uicontrol('Parent',gp_top,'Style','edit',...
    'BackgroundColor',[1 1 1],'String',n,'Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.345 .54 .1 .42],...
    'CallBack',cbNval);

infotxt = uicontrol('Parent',gp_top,'Style','text',...
    'String','','FontUnits','normalized','FontSize',.6,...
    'HorizontalAlignment','center','Units','normalized',...
    'Position',[.005 .04 .44 .42]);

ax_brightness = axes('Parent',gp_top,'ActivePositionProperty','Position',...
    'Position',[.455 .69 .02 .24],'Color','None');
im_brightness = imshow('ico_brightness.gif','Parent',ax_brightness);
[cdata,iconmask] = fcn_icon('ico_brightness.gif',[255 255 255]);
set(im_brightness,'CData',cdata,'AlphaData',~iconmask);
hbrightness = uicontrol('Parent',gp_top,'Style','slider',...
    'Min',-1,'Max',1,'Value',0,...
    'String','Previous image','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.475 .69 .105 .24],...
    'CallBack',cbImAdjust);

ax_contrast = axes('Parent',gp_top,'ActivePositionProperty','Position',...
    'Position',[.455 .38 .02 .24],'Color','None');
im_contrast = imshow('ico_contrast.gif','Parent',ax_contrast);
[cdata,iconmask] = fcn_icon('ico_contrast.gif',[255 255 255]);
set(im_contrast,'CData',cdata,'AlphaData',~iconmask);
hcontrast = uicontrol('Parent',gp_top,'Style','slider',...
    'Min',-.99,'Max',.99,'Value',0,...
    'String','Previous image','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.475 .38 .105 .24],...
    'CallBack',cbImAdjust);

ax_gamma = axes('Parent',gp_top,'ActivePositionProperty','Position',...
    'Position',[.455 .07 .02 .24],'Color','None');
im_gamma = imshow('ico_gamma.gif','Parent',ax_gamma);
[cdata,iconmask] = fcn_icon('ico_gamma.gif',[255 255 255]);
set(im_gamma,'CData',cdata,'AlphaData',~iconmask);
hgamma = uicontrol('Parent',gp_top,'Style','slider',...
    'Min',-1,'Max',1,'Value',0,...
    'String','Previous image','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.475 .07 .105 .24],...
    'CallBack',cbImAdjust);

uicontrol('Parent',gp_top,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Previous image','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.59 .04 .2 .92],...
    'CallBack','ninc = -1; init_disp_image;');

uicontrol('Parent',gp_top,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Next image','Tag','ChangeImageButtons',...
    'Units','normalized','Position',[.795 .04 .2 .92],...
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
    'Units','normalized','Position',[.1 .120 .8 .035],...
    'CallBack',cbScaleBar);

uicontrol('Parent',gp_left,'Style','text','FontUnits','normalized',...
    'FontSize',.4,'String','Scalebar length [m]:',...
    'TooltipString','Scalebar length [m]',...
    'HorizontalAlignment','right','Units','normalized',...
    'Position',[.1 .085 .24 .030]);

h_sc = uicontrol('Parent',gp_left,'Style','edit',...
    'BackgroundColor',[1 1 1],'String',sc,...
    'Units','normalized','Position',[.38 .085 .24 .030],...
    'CallBack',cbScaleVal);

uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Apply','TooltipString','Apply scale value',...
    'Units','normalized','Position',[.65 .085 .24 .030],...
    'CallBack','fcn_applyscale(n,imagelist,inpath,aflag,sc,userid,sep);');

ds_ttp = ['Maximum display scale in ''display centimetres'' per ',...
    '''scene centimetre'' [display cm / scene cm].'];
ds_ttp = sprintf('%s\n \nA scale of N:D means that N cm on the screen represents D cm on the image.',ds_ttp);
ds_ttp = sprintf('%s\n \nNote: works only if the scale bar has been defined.',ds_ttp);

uicontrol('Parent',gp_left,'Style','text','FontUnits','normalized',...
    'FontSize',.4,'String','Max. scale:',...
    'HorizontalAlignment','right','Units','normalized',...
    'Position',[.1 .045 .18 .030]);

h_ds = uicontrol('Parent',gp_left,'Style','edit',...
    'BackgroundColor',[1 1 1],'String',ds,...
    'Units','normalized','Position',[.28 .045 .12 .03],...
    'TooltipString',ds_ttp,'CallBack',['ds = cb_dispscale([],ds); ',cbDs]);

uicontrol('Parent',gp_left,'Style','text','FontUnits','normalized',....
    'FontSize',.4,'String','Screen PPI:','TooltipString',...
    'Pixels Per Inch (PPI) of the monitor',...
    'HorizontalAlignment','right','Units','normalized',...
    'Position',[.42 .045 .14 .030]);

ppi_ttp = 'Set here the number of pixels per inch (PPI) of your monitor.';
MonitorSizes = get(0,'MonitorPositions');
hpxl = MonitorSizes(:,3);
vpxl = MonitorSizes(:,4);
MonitorMax = size(MonitorSizes,1);
if MonitorMax==1
    dpxl = sqrt(hpxl^2 + vpxl^2);
    ppi_ttp = sprintf('%s\n \nPPI = %.1f / D',ppi_ttp,dpxl);
    ppi_ttp = sprintf('%s\n \nWith:',ppi_ttp);
    ppi_ttp = sprintf('%s\nD = Length of monitor diagonal (in inches)',ppi_ttp);
else
    ppi_ttp = sprintf('%s\n \nPPI = (hpxl^2 + vpxl^2)^0.5 / D',ppi_ttp);
    ppi_ttp = sprintf('%s\n \nWith:',ppi_ttp);
    ppi_ttp = sprintf('%s\nD = Length of monitor diagonal (in inches)',ppi_ttp);
    ppi_ttp = sprintf('%s\nhpxl = Horizontal resolution of monitor (in pixels)',ppi_ttp);
    ppi_ttp = sprintf('%s\nvpxl = Vertical resolution of monitor (in pixels)',ppi_ttp);
    ppi_ttp = sprintf('%s\n \n%i monitors were detected:',ppi_ttp,MonitorMax);
    for k=1:MonitorMax
        ppi_ttp = sprintf('%s\n- Monitor %i: %ix%i pxl',ppi_ttp,k,hpxl(k),vpxl(k));
    end

end


h_ppi = uicontrol('Parent',gp_left,'Style','edit',...
    'BackgroundColor',[1 1 1],'String',ppi,...
    'Units','normalized','Position',[.56 .045 .14 .03],...
    'TooltipString',ppi_ttp,'CallBack',cbPPI);

h_dscb = uicontrol('Parent',gp_left,'Style','checkbox',...
    'BackgroundColor',ButtonColor,'FontUnits','normalized','FontSize',.4,...
    'String','Enable','TooltipString','Enable/disable display scale control',...
    'Units','normalized','Position',[.72 .045 .17 .030],...
    'CallBack',cbDs);

uicontrol('Parent',gp_left,'Style','pushbutton',...
    'BackgroundColor',ButtonColor,...
    'String','Export summary results','Tag','ExportResults',...
    'Units','normalized','Position',[.1 0.005 .8 .035],...
    'TooltipString','Export summary results','CallBack',cbExport);


%% other
ds = cb_dispscale(h_ds,ds);
set(fig_main,'currentaxes',h); % ensures the main axes are current axes to avoid errors
[him,fid,sc,annotype,rectfile] = fcn_disp_image(n,imagelist,inpath,h,hhideshow,h_sc,h_ds,h_ppi,dsflag,0,userid,sep,kwlist,filterlist,infotxt);
imCData = get(him,'CData'); % get image CData for image enhancements
imdbl = fcn_im2dbl(imCData); % convert to double precision for image enhancements
[selec,fid,~] = list_callback(fid,hlist,him,infotxt,annotype);
