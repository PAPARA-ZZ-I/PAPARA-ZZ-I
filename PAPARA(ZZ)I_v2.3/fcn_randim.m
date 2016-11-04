function [imagelist,nmax] = fcn_randim(imagelist,inpath,userid,sep)
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
randomlistfile = sprintf('%s%s_annotations%srandomlist.txt',inpath,userid,sep);
if exist(randomlistfile,'file')==2
    fid = fopen(randomlistfile,'r');
    Data = textscan(fid,'%s','delimiter','\n');
    randomlist = Data{1};
    fclose(fid);
    clear('fid'); % for some reason, the previous line does not reset fid.
    
    % images of 'imagelist' that are not in 'randomlist'
    [~,id2add] = setdiff(imagelist,randomlist);
    if ~isempty(id2add)
        randid = randperm(numel(id2add));
        id2add = id2add(randid); % permute additional images
        
        randomlist = [randomlist ; imagelist(id2add)];
        
        fid = fopen(randomlistfile,'a');
        fprintf(fid,'%s\r\n',imagelist{id2add});
        fclose(fid);
        clear('fid'); % for some reason, the previous line does not reset fid.
    end
    
    % remove images of 'randomlist' that are not in 'imagelist'
    [~,id2remove] = setdiff(randomlist,imagelist);
    if ~isempty(id2remove)
        randomlist(id2remove) = [];
        randomlist = randomlist(~cellfun('isempty',randomlist));
    end
    
    imagelist = randomlist;
    
else
    randomflag = questdlg('Do you want to randomize the image order?',...
        'Randomize images?','Yes','No','Yes');
    if strcmpi(randomflag,'yes')
        randid = randperm(numel(imagelist));
        imagelist = imagelist(randid); % permute images
        
        fid = fopen(randomlistfile,'w');
        fprintf(fid,'%s\r\n',imagelist{:});
        fclose(fid);
        clear('fid'); % for some reason, the previous line does not reset fid.
    end
end
nmax = numel(imagelist); % refresh max number of images

end
