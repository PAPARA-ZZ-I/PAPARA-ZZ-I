function fcn_replacekw(inpath,userid,sep,hlist)
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
strlist = [];
annopath = [inpath userid '_annotations' sep];

strlist = vertcat(strlist,dir([annopath '*.txt']));
strlist = fcn_field2array(strlist,'name','cell'); % convert to cell array
strlist = unique(strlist); % remove duplicates
if isempty(strlist), return; end

% remove 'ignorelist.txt' and 'randomlist.txt' from the list
files2remove = {'ignorelist.txt';'randomlist.txt'};
[~,id2keep] = setdiff(strlist,files2remove);
if ~isempty(id2keep) % i.e. image must be ignored
    strlist = strlist(id2keep);
end
kmax = length(strlist); % max number of images


% Check if list of new keywords has been loaded
newkwlist = get(hlist,'String');
alphabet = 'abcdefghijklmnopkrstuvwxyz';
if isempty(newkwlist) || ( numel(newkwlist)==1 && ...
        (~any(ismember(newkwlist,alphabet)) || ...
        strcmp(newkwlist{1}(1),'_')==1) )
    return;
end


% Generate list of old keywords
oldkwlist = {};
pg = 0; % progress
hwb = waitbar(pg,'Please wait...');
for k1=1:kmax
    pg = pg + (1/kmax);
    waitbar(pg,hwb);
    fid = fopen([annopath strlist{k1}],'r');
    while ~feof(fid)
        tline = fgetl(fid);
        if tline ~= -1
            strline = textscan(tline,'%s','delimiter','\t');
            kw = strline{1}{3};
            if ~ismember(kw,oldkwlist)
                oldkwlist = [ oldkwlist , {kw} ];
            end
        end
    end
    fclose(fid);
end
delete(hwb);

if isempty(oldkwlist), return; end

% Sorts the categories (and counts) in the alphabetical order
oldkwlist = sort(oldkwlist);

% ask for the keyword to replace
[oldkw,ok] = listdlg('Name','Old keyword','PromptString',...
    'Select the old keyword that is to be replaced:',...
    'SelectionMode','single','ListString',oldkwlist,'ListSize',[500 500]);
drawnow; pause(0.1); % prevents dialog box from freezing
if ok == 0, return; end

% ask for the new keyword
[newkw,ok] = listdlg('Name','New keyword','PromptString',...
    'Select the new keyword:','SelectionMode','single',...
    'ListString',newkwlist,'ListSize',[500 500]);
drawnow; pause(0.1); % prevents dialog box from freezing
if ok == 0, return; end

oldkw = oldkwlist{oldkw};
newkw = newkwlist{newkw};


% Disable all buttons and toolbars of the GUI (to prevent double-clicks)
fcn_freeze_fig('off',gcf,'Button-containing panel');
drawnow;


% Replace keywords

pg = 0; % progress
hwb = waitbar(pg,'Please wait...');
for k1=1:kmax
    pg = pg + (1/kmax);
    waitbar(pg,hwb);
    
    % read first point
    txtfile = [annopath strlist{k1}];
    fid = fopen(txtfile,'r');
    % read data from file
    Data = textscan(fid,'%s','delimiter','\n');
    CStr = Data{1};
    fclose(fid);
    
    if isempty(CStr), continue; end
    
    % Remove empty rows if any
    CStr = CStr(~cellfun('isempty',CStr));
    
    for k2=1:numel(CStr)
        strline = textscan(CStr{k2},'%s', 'delimiter', '\t');
        if strcmp(strline{1}{3},oldkw)==1
            CStr{k2} = sprintf('%s\t%s\t%s',strline{1}{1},strline{1}{2},newkw);
            if numel(strline{1}) > 3 % if there is additional data (e.g. size)
                for k3 = 4:numel(strline{1})
                    CStr{k2} = sprintf('%s\t%s',CStr{k2},strline{1}{k3});
                end
            end
        end
    end
    
    % Create a new file and save it again:
    fid = fopen(txtfile,'w');
    if fid == -1, error('Cannot open file'), end
    fprintf(fid,'%s\r\n',CStr{:});
    fclose(fid);
end
delete(hwb);
msg = sprintf('%s','Keywords successfully replaced.');
waitfor(msgbox(msg,'Finished','modal'));

% Enable all buttons and toolbars of the GUI
fcn_freeze_fig('on',gcf,'Button-containing panel');
end
