function [hPoints,hSave] = fcn_ctrl_FigTools(h,onoff,cbPrevSection,...
    cbNextSection,cbMeas,cbRect,cbPoly,cbIgnore,cbPoints,cbSave,cbExport,cbHelp,...
    cbAbout)
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
if exist('h','var')~=1, h = gcf; end
if exist('onoff','var')~=1 || ~strcmp(onoff,'on'), onoff = 'off'; end

hToolbar = findall(h,'Tag','FigureToolBar');

allh = []; % list of handles
allh = [ allh , findall(h,'Tag','Standard.NewFigure')];
allh = [ allh , findall(h,'Tag','Standard.FileOpen')];
allh = [ allh , findall(h,'Tag','Standard.SaveFigure')];
allh = [ allh , findall(h,'Tag','Standard.PrintFigure')];
allh = [ allh , findall(h,'Tag','Standard.EditPlot')];
% allh = [ allh , findall(h,'Tag','Exploration.ZoomIn')];
% allh = [ allh , findall(h,'Tag','Exploration.ZoomOut')];
% allh = [ allh , findall(h,'Tag','Exploration.Pan')];
allh = [ allh , findall(h,'Tag','Exploration.Rotate')];
allh = [ allh , findall(h,'Tag','Exploration.DataCursor')];
allh = [ allh , findall(h,'Tag','Exploration.Brushing')];
allh = [ allh , findall(h,'Tag','DataManager.Linking')];
allh = [ allh , findall(h,'Tag','Annotation.InsertColorbar')];
allh = [ allh , findall(h,'Tag','Annotation.InsertLegend')];
allh = [ allh , findall(h,'Tag','Plottools.PlottoolsOff')];
allh = [ allh , findall(h,'Tag','Plottools.PlottoolsOn')];
set(allh,'Visible',onoff);

% Separators
set(findall(h,'Tag','Standard.EditPlot'),'Separator',onoff);
set(findall(h,'Tag','Exploration.ZoomIn'),'Separator',onoff);
set(findall(h,'Tag','DataManager.Linking'),'Separator',onoff);
set(findall(h,'Tag','Annotation.InsertColorbar'),'Separator',onoff);
set(findall(h,'Tag','Plottools.PlottoolsOff'),'Separator',onoff);



%% Previous button
cdata = fcn_icon('ico_arrow_left.gif',[255 255 255]);

% Add the icon to the latest toolbar
hPrev = uipushtool(hToolbar,'CData',cdata,'Tag','ChangeImageButtons',...
    'TooltipString','Previous image section', 'ClickedCallback',cbPrevSection);



%% Next button
cdata = fcn_icon('ico_arrow_right.gif',[255 255 255]);

% Add the icon to the latest toolbar
hNext = uipushtool(hToolbar,'CData',cdata,'Tag','ChangeImageButtons',...
    'TooltipString','Next image section', 'ClickedCallback',cbNextSection);



%% Measure button
cdata = fcn_icon('ico_measure.gif',[255 255 255]);

% Add the icon to the latest toolbar
hMeas = uitoggletool(hToolbar,'CData',cdata,'Tag','Toolbar_Measure',...
    'TooltipString','Measure selected feature', 'ClickedCallback',cbMeas);



%% Rectangle button
cdata = fcn_icon('ico_rectangle.gif',[255 255 255]);

% Add the icon to the latest toolbar
hRect = uitoggletool(hToolbar,'CData',cdata,'Tag','Toolbar_Rectangle',...
    'TooltipString','Select usable rectangle area', 'ClickedCallback',cbRect);



%% Polygon button
cdata = fcn_icon('ico_polygon.gif',[255 255 255]);

% Add the icon to the latest toolbar
hPoly = uitoggletool(hToolbar,'CData',cdata,'Tag','Toolbar_Polygon',...
    'TooltipString','Select usable polygon area', 'ClickedCallback',cbPoly);



%% Ignore button
cdata = fcn_icon('ico_ignore_image.gif',[255 255 255]);

% Add the icon to the latest toolbar
hIgnore = uitoggletool(hToolbar,'CData',cdata,'Tag','Toolbar_Ignore',...
    'TooltipString','Ignore image', 'ClickedCallback',cbIgnore);



%% Create Random Grid of points
cdata = fcn_icon('ico_points_random.gif',[255 0 255]);

% Add the icon to the latest toolbar
hPoints = uitogglesplittool(hToolbar,'CData',cdata,'Tag','Toolbar_Points',...
    'TooltipString','Generate points','ClickedCallback',cbPoints{1});
drawnow; % prevents errors

% Define dropdown menu
jPoints = get(hPoints,'JavaContainer');
jMenu = get(jPoints,'MenuComponent');  % or: =jPoints.getMenuComponent
jOption1 = jMenu.add('Grid (10 points)');
jOption2 = jMenu.add('Grid (100 points)');
jOption3 = jMenu.add('Grid (X points)');
jOption4 = jMenu.add('Random (10 points)');
jOption5 = jMenu.add('Random (100 points)');
jOption6 = jMenu.add('Random (X points)');
% jOption1.setPreferredSize(java.awt.Dimension(150,22));
% jOption2.setPreferredSize(java.awt.Dimension(150,22));
% jOption3.setPreferredSize(java.awt.Dimension(150,22));
% jOption4.setPreferredSize(java.awt.Dimension(150,22));
% jOption5.setPreferredSize(java.awt.Dimension(150,22));
% jOption6.setPreferredSize(java.awt.Dimension(150,22));
jOption1.setIcon(javax.swing.ImageIcon('ico_points_grid10.gif'));
jOption2.setIcon(javax.swing.ImageIcon('ico_points_grid100.gif'));
jOption3.setIcon(javax.swing.ImageIcon('ico_points_gridX.gif'));
jOption4.setIcon(javax.swing.ImageIcon('ico_points_random10.gif'));
jOption5.setIcon(javax.swing.ImageIcon('ico_points_random100.gif'));
jOption6.setIcon(javax.swing.ImageIcon('ico_points_randomX.gif'));
set(jOption1, 'ActionPerformedCallback',cbPoints{2});
set(jOption2, 'ActionPerformedCallback',cbPoints{3});
set(jOption3, 'ActionPerformedCallback',cbPoints{4});
set(jOption4, 'ActionPerformedCallback',cbPoints{5});
set(jOption5, 'ActionPerformedCallback',cbPoints{6});
set(jOption6, 'ActionPerformedCallback',cbPoints{7});
% set(jOption1, 'ActionPerformedCallback', {@myCallbackFcn, extraData});


%% Save screenshot button
cdata = fcn_icon('ico_image_screenshot.gif',[255 255 255]);

% Add the icon to the latest toolbar
hSave = uitogglesplittool(hToolbar,'CData',cdata,'Tag','Toolbar_ImageSave',...
    'TooltipString','Export current image', 'ClickedCallback',cbSave{1});
drawnow; % prevents errors

% Define dropdown menu
jSave = get(hSave,'JavaContainer');
jSaveMenu = get(jSave,'MenuComponent');  % or: =jSave.getMenuComponent
jSaveOption1 = jSaveMenu.add('JPG (*.jpg)');
jSaveOption2 = jSaveMenu.add('TIF (*.tif)');
jSaveOption3 = jSaveMenu.add('EPS Level 2 (*.eps)');
jSaveOption4 = jSaveMenu.add('EPS Level 3 (*.eps)');
% jSaveOption1.setPreferredSize(java.awt.Dimension(150,22));
% jSaveOption2.setPreferredSize(java.awt.Dimension(150,22));
% jSaveOption3.setPreferredSize(java.awt.Dimension(150,22));
% jSaveOption4.setPreferredSize(java.awt.Dimension(150,22));
jSaveOption1.setIcon(javax.swing.ImageIcon('ico_image_screenshot_JPG.gif'));
jSaveOption2.setIcon(javax.swing.ImageIcon('ico_image_screenshot_TIF.gif'));
jSaveOption3.setIcon(javax.swing.ImageIcon('ico_image_screenshot_EPS2.gif'));
jSaveOption4.setIcon(javax.swing.ImageIcon('ico_image_screenshot_EPS3.gif'));
set(jSaveOption1, 'ActionPerformedCallback',cbSave{2});
set(jSaveOption2, 'ActionPerformedCallback',cbSave{3});
set(jSaveOption3, 'ActionPerformedCallback',cbSave{4});
set(jSaveOption4, 'ActionPerformedCallback',cbSave{5});
% set(jSaveOption1, 'ActionPerformedCallback', {@myCallbackFcn, extraData});



%% Export button
cdata = fcn_icon('ico_export_results.gif',[255 255 255]);

% Add the icon to the latest toolbar
hExport = uipushtool(hToolbar,'CData',cdata,'Tag','ExportResults',...
    'TooltipString','Export results', 'ClickedCallback',cbExport);



%% Help button
cdata = fcn_icon('ico_help.gif',[255 255 255]);

% Add the icon to the latest toolbar
hHelp = uipushtool(hToolbar,'CData',cdata, 'TooltipString','Help','ClickedCallback',cbHelp);



%% About button
cdata = fcn_icon('ico_about.gif',[255 255 255]);

% Add the icon to the latest toolbar
hAbout = uipushtool(hToolbar,'CData',cdata, 'TooltipString','About PAPARA(ZZ)I','ClickedCallback',cbAbout);


%% Re-order buttons
% hButtons = allchild(hToolbar);
% hVisibleButtons = findobj(hButtons,'Visible','on');
% set(hToolbar,'Children',hButtons([1:6,17:19,7:8,9:16])); % for some reason, handles are ordered from right to left


%% Separators
set(hPrev,'Separator','on');
set(findall(h,'Tag','Exploration.ZoomIn'),'Separator','on');
set(hMeas,'Separator','on');
set(hSave,'Separator','on');
set(hHelp,'Separator','on');
set(hAbout,'Separator','on');


end