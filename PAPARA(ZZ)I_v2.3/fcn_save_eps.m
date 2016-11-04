function fcn_save_eps(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax)
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
% progress bar
pg = 0; % progress
hwb = waitbar(pg,'Preparing image data...','CreateCancelBtn','return;');

% image name
[~,iname,~] = fileparts([inpath imagelist{n}]);

% creates folder for saved images
imoutpath = [inpath userid '_exported_images' sep];
switch annotype
    case 'Annotation'
        imoutpath = [imoutpath 'free_annotations' sep];
    case 'GeneratedPoint'
        imoutpath = sprintf('%s%s_%lipoints%s',imoutpath,pointtype,pointmax,sep);
end
if isdir(imoutpath)==0, mkdir(imoutpath); end

switch imformat
    case 'EPS2'
        fmt = 'epsc2';
    case 'EPS3'
        fmt = 'epsc';
end



pg = .5; waitbar(pg,hwb,'Saving image...');

outfile = [ imoutpath iname ]; % no extension here
tmpfig = figure('MenuBar','none','NumberTitle','off',...
    'Name','Invisible figure','Units','normalized',...
    'Position',[0,0,1,1],'Visible','off');
tmpaxis = copyobj(h,tmpfig);
saveas(tmpfig,outfile,fmt);

delete(tmpfig);

pg = 1; waitbar(pg,hwb,'Finished.');
delete(hwb);

end