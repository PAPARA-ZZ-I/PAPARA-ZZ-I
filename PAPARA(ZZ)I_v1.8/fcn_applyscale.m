function fcn_applyscale(n,imagelist,inpath,scflag,sc,userid,sep)
%% Copyright 2015, 2016 Yann Marcon and Autun Purser

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

if scflag ~= 0, return; end

scpath = [inpath userid '_scale' sep];

choice = questdlg('Set scale bar length','Apply scale bar length to:', ...
 'This image only','All existing scale bars','Cancel','This image only');

switch choice
    case 'This image only'
        [~,iname,~] = fileparts(imagelist{n});
        scfile = [scpath iname '.txt'];
        
        % read first point
        fid = fopen(scfile,'r');
        tline = fgetl(fid);
        fclose(fid);
        if tline == -1, return; end
        strline = textscan(tline,'%s', 'delimiter', '\t');

        % Open text file for appending
        fid = fopen(scfile,'w');
        fprintf(fid,'%s\t%s\t%s\t%s\t%f\r\n',...
            strline{1}{1},strline{1}{1},strline{1}{1},strline{1}{1},sc);
        fclose(fid);
        
    case 'All existing scale bars'
        str = 'The length of all existing scale bars will be set to: ';
        str2 = 'Do you wish to continue?';
        msg = sprintf('%s%f m.\n\n%s',str,sc,str2);
        answer = questdlg(msg,'Confirmation required','Confirm',...
            'Cancel','Cancel');
        
        switch answer
            case 'Confirm'
                pg = 0; % progress
                hwb = waitbar(pg,'Please wait...');
                
                strlist = [];
                strlist = vertcat(strlist,dir([scpath '*.txt']));
                strlist = fcn_field2array(strlist,'name','cell'); % convert to cell array
                strlist = unique(strlist); % remove duplicates
                kmax = length(strlist); % max number of images
                for k=1:kmax
                    pg = pg + (1/kmax); % progress up to 80%
                    waitbar(pg,hwb);
                    
                    % read first point
                    scfile = [scpath strlist{k}];
                    fid = fopen(scfile,'r');
                    tline = fgetl(fid);
                    fclose(fid);
                    if tline == -1, continue; end
                    strline = textscan(tline,'%s', 'delimiter', '\t');
                    
                    % Open text file for appending
                    fid = fopen(scfile,'w');
                    fprintf(fid,'%s\t%s\t%s\t%s\t%f\r\n',...
                        strline{1}{1},strline{1}{2},strline{1}{3},strline{1}{4},sc);
                    fclose(fid);
                end
                delete(hwb);
                msg = sprintf('%s%f m.','Length of scale bars successfully set to: ',sc);
                msgbox(msg,'Finished','modal');
                
            case 'Cancel'
                return;
        end
            
    case 'Cancel'
        return;
end
