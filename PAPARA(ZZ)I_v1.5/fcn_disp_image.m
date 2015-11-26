function [him,fid,sc,annotype,rectfile] = fcn_disp_image(n,imagelist,inpath,h,h_sc,...
    aflag,userid,sep,kwlist,filterlist,infotxt,pointtype,pointmax)
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




%%
% Disable all buttons and toolbars of the GUI (to prevent double-clicks)
fcn_freeze_fig('off',gcf,'Button-containing panel');
drawnow;

% Get toolbar handle
hToolbar = findall(gcf,'Tag','FigureToolBar');

% Type of annotations
hPoints  = findobj(hToolbar,'Tag','Toolbar_Points');
onoff = get(hPoints,'State');
switch onoff
    case 'on' % display generated points
        annotype = 'GeneratedPoint';
    case 'off'
        annotype = 'Annotation';
end

% Get image dimensions
infostr = imfinfo([inpath imagelist{n}]);
imw = infostr.Width;
imh = infostr.Height;


annopath = [inpath userid '_annotations' sep];
rectpath = [inpath userid '_rectangle' sep];
scpath = [inpath userid '_scale' sep];


%%
% Check if image name is in the list of images to ignore
ignorelist = [annopath 'ignorelist.txt'];
fid = fopen(ignorelist,'r');
if fid ~= -1
    Data = textscan(fid,'%s','delimiter','\n');
    CStr = Data{1};
    fclose(fid);
    
    idC = strfind(CStr,imagelist{n});
    id = find(~cellfun('isempty',idC), 1);
end
if fid ~= -1 && exist('id','var')==1 && ~isempty(id) % if image is in the list of images to ignore
    % Set toolbar toggle button in a pressed state
    set(findall(hToolbar,'Tag','Toolbar_Ignore'),'State','on');
    
    % Open image without callback option
    hold off
    im = imread([inpath imagelist{n}]);
    him = imshow(im,'Parent',h);
    imtitle = ['Image ' num2str(n) ': ' imagelist{n}];
    title(h,strrep(imtitle,'_','\_'));
    hold on
    
    % Display a cross across the image
    plot(h,[0 0 ; imw imw ],[0 imh ; imh 0],'-','Color','k',...
        'LineWidth',5,'Tag','ignore');
    
    % Enable button to ignore image
    set(findall(gcf,'Tag','Toolbar_Ignore'),'Enable','on');
    
    % Enable buttons to export results
    set(findall(gcf,'Tag','ExportResults'),'Enable','on');
    
    % Enable buttons to change image
    set(findall(gcf,'Tag','ChangeImageButtons'),'Enable','on');
    
    sc = [];
    rectfile = [];
    return; % abort plotting of the rest
else
    % Set toolbar toggle button back to default
    set(findall(hToolbar,'Tag','Toolbar_Ignore'),'State','off');
end


            
%% Display annotation or generated points
[~,iname,~] = fileparts(imagelist{n});
scfile = [ scpath iname '.txt' ];
rectfile = [ rectpath iname '.txt' ];

switch onoff
    case 'on' % display generated points
        if exist('pointtype','var')~=1, pointtype = 'grid'; end
        if exist('pointmax','var')~=1, pointmax = 10; end
        pointpath = [inpath userid '_generatedpoints' sep];
        txtfile = sprintf('%s%s_%lix%li_%li%s.txt',pointpath,iname,imw,imh,pointmax,pointtype);
        him = fcn_plot_annotations(h,txtfile,n,imagelist,inpath,...
            rectfile,scfile,aflag,kwlist,filterlist,infotxt,annotype);
        
    case 'off' % display annotations
        txtfile = sprintf('%s%s_%lix%li.txt',annopath,iname,imw,imh);
        him = fcn_plot_annotations(h,txtfile,n,imagelist,inpath,...
            rectfile,scfile,aflag,kwlist,filterlist,infotxt,annotype);
        
end

% Read existing scale
sc = str2double(get(h_sc,'String')); % default value
if exist(scfile,'file')==2
    scdata = importdata(scfile,'\t');
    if ~isempty(scdata) && numel(scdata)==5
        scx = [scdata(1) scdata(3)];
        scy = [scdata(2) scdata(4)];
        sc = scdata(5);
        set(h_sc,'String',sc);
    end
end

% Plot scale
if exist('scx','var')==1
    plot(h,scx,scy,'o',scx,scy,'-','Color','g','Tag','scalebar');
end

% Open text file for appending
fid = fopen(txtfile,'a');

% Enable all buttons and toolbars of the GUI
fcn_freeze_fig('on',gcf,'Button-containing panel');

end
