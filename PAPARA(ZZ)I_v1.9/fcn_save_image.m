function fcn_save_image(n,imagelist,inpath,userid,sep,h,imformat,annotype,pointtype,pointmax)
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
hwb = waitbar(pg,'Exporting image data...','CreateCancelBtn','return;');

% image name
[~,iname,ext] = fileparts([inpath imagelist{n}]);

% Load the image
im = imread([inpath imagelist{n}]);
imh = size(im,1);
imw = size(im,2);

% creates folder for saved images
imoutpath = [inpath userid '_exported_images' sep];
switch annotype
    case 'Annotation'
        imoutpath = [imoutpath 'free_annotations' sep];
    case 'GeneratedPoint'
        imoutpath = sprintf('%s%s_%lipoints%s',imoutpath,pointtype,pointmax,sep);
end
if isdir(imoutpath)==0, mkdir(imoutpath); end


%% Quick export (upsized frame)

% get frame from axes
f = getframe(h);
f = f.cdata;

% save screenshot
% screenshotfile = [ imoutpath 'screenshot_' iname ext ];
% imwrite(f,screenshotfile);

% frame size
fh = size(f,1);
fw = size(f,2);


% %%%%%%%%%%%%%%%%%%%%%%%%%%%
% crop frame to remove the background colour [240 240 240]
midc = round(fw/2); % middle column
midr = round(fh/2); % middle row

r1 = 1;
while (f(r1,midc,1)==240 && f(r1,midc,2)==240 && f(r1,midc,3)==240) ...
        || (f(r1+1,midc,1)==240 && f(r1+1,midc,2)==240 && f(r1+1,midc,3)==240) ...
        || (f(r1+2,midc,1)==240 && f(r1+2,midc,2)==240 && f(r1+2,midc,3)==240) ...
        || (f(r1+3,midc,1)==240 && f(r1+3,midc,2)==240 && f(r1+3,midc,3)==240) ...
        || (f(r1+4,midc,1)==240 && f(r1+4,midc,2)==240 && f(r1+4,midc,3)==240) ...
        || (f(r1+5,midc,1)==240 && f(r1+5,midc,2)==240 && f(r1+5,midc,3)==240)
    r1 = r1 + 1;
end

r2 = fh;
while (f(r2,midc,1)==240 && f(r2,midc,2)==240 && f(r2,midc,3)==240) ...
        || (f(r2-1,midc,1)==240 && f(r2-1,midc,2)==240 && f(r2-1,midc,3)==240) ...
        || (f(r2-2,midc,1)==240 && f(r2-2,midc,2)==240 && f(r2-2,midc,3)==240) ...
        || (f(r2-3,midc,1)==240 && f(r2-3,midc,2)==240 && f(r2-3,midc,3)==240) ...
        || (f(r2-4,midc,1)==240 && f(r2-4,midc,2)==240 && f(r2-4,midc,3)==240) ...
        || (f(r2-5,midc,1)==240 && f(r2-5,midc,2)==240 && f(r2-5,midc,3)==240)
    r2 = r2 - 1;
end

c1 = 1;
while (f(midr,c1,1)==240 && f(midr,c1,2)==240 && f(midr,c1,3)==240) ...
        || (f(midr,c1+1,1)==240 && f(midr,c1+1,2)==240 && f(midr,c1+1,3)==240) ...
        || (f(midr,c1+2,1)==240 && f(midr,c1+2,2)==240 && f(midr,c1+2,3)==240) ...
        || (f(midr,c1+3,1)==240 && f(midr,c1+3,2)==240 && f(midr,c1+3,3)==240) ...
        || (f(midr,c1+4,1)==240 && f(midr,c1+4,2)==240 && f(midr,c1+4,3)==240) ...
        || (f(midr,c1+5,1)==240 && f(midr,c1+5,2)==240 && f(midr,c1+5,3)==240)
    c1 = c1 + 1;
end

c2 = fw;
while (f(midr,c2,1)==240 && f(midr,c2,2)==240 && f(midr,c2,3)==240) ...
        || (f(midr,c2-1,1)==240 && f(midr,c2-1,2)==240 && f(midr,c2-1,3)==240) ...
        || (f(midr,c2-2,1)==240 && f(midr,c2-2,2)==240 && f(midr,c2-2,3)==240) ...
        || (f(midr,c2-3,1)==240 && f(midr,c2-3,2)==240 && f(midr,c2-3,3)==240) ...
        || (f(midr,c2-4,1)==240 && f(midr,c2-4,2)==240 && f(midr,c2-4,3)==240) ...
        || (f(midr,c2-5,1)==240 && f(midr,c2-5,2)==240 && f(midr,c2-5,3)==240)
    c2 = c2 - 1;
end

f = f(r1:r2,c1:c2,:);

% new frame size
fh = size(f,1);
fw = size(f,2);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%



% crop the axis area around the image if still needed
% if fw/fh < imw/imh % axis width is too long
%     fh = fw * imh/imw;
%     id1 = ceil( (size(f,1)-fh)/2 );
%     id2 = floor( (size(f,1)-fh)/2 + fh );
%     f = f(id1:id2,:,:);
% elseif fw/fh > imw/imh % axis width is too long
%     fw = fh * imw/imh;
%     id1 = ceil( (size(f,2)-fw)/2 );
%     id2 = floor( (size(f,2)-fw)/2 + fw );
%     f = f(:,id1:id2,:);
% else % axis width/height ratio is correct
%     % do nothing
% end

sizefactor = imw / fw; % scale factor between original and axis images
% res = sizefactor * get(0,'ScreenPixelsPerInch');

pg = .25; waitbar(pg,hwb,'Resizing image...');

switch imformat
    case 'JPG'
        % does not work for 16bit images but output files are not too large
        imout = fcn_resize(f,sizefactor,'uint8');
        pg = .75; waitbar(pg,hwb,'Saving image...');
        outfile = [ imoutpath iname '.jpg' ];
        imwrite(imout,outfile);
        
    case 'TIF'
        imout = fcn_resize(f,sizefactor);
        pg = .75; waitbar(pg,hwb,'Saving image...');
        outfile = [ imoutpath iname '.tif' ];
        imwrite(imout,outfile,'Compression','deflate');
end

pg = 1; waitbar(pg,hwb,'Finished.');
delete(hwb);



%% Full resolution export (NOT READY)

% % file names
% rectfile = [ inpath userid '_rectangle' sep iname '.txt' ];
% scfile = [ inpath userid '_scale' sep iname '.txt' ];
% 
% datapath = [inpath userid '_' lower(annotype) 's' sep];
% switch annotype
%     case 'Annotation'
%         datafile = sprintf('%s%s_%lix%li.txt',datapath,iname,imw,imh);
%     case 'GeneratedPoint'
%         datafile = sprintf('%s%s_%lix%li_%li%s.txt',datapath,iname,imw,imh,pointmax,pointtype);
% end
% 
% 
% % Makes sure it works with greyscale images
% if numel(size(im))==2 || size(im,3)==1, im = cat(3,im,im,im); end
% 
% 
% % Rectangle
% if exist(rectfile,'file')==2
%     rect = importdata(rectfile,'\t');
%     if ~isempty(rect) && numel(rect)==4
%         rect = round(rect);
%         pixRect = [ (rect(2):(rect(2)+rect(4))) ; ones(1,rect(4)+1)*rect(1) ];
%         pixRect = [ pixRect , [(rect(2):(rect(2)+rect(4))) ; ones(1,rect(4)+1)*(rect(1)+rect(3))] ];
%         pixRect = [ pixRect , [ones(1,rect(3)+1)*rect(2) ; rect(1):(rect(1)+rect(3))] ];
%         pixRect = [ pixRect , [ones(1,rect(3)+1)*(rect(2)+rect(4)) ; rect(1):(rect(1)+rect(3))] ];
%         xRect = pixRect(1,:)';
%         yRect = pixRect(2,:)';
%         xRect(xRect<1) = 1;
%         yRect(yRect<1) = 1;
%         xRect(xRect>imh) = imh;
%         yRect(yRect>imw) = imw;
%         for c = 1:size(im,3)
%             ch = im(:,:,c);
%             id = sub2ind(size(ch),xRect,yRect);
%             ch(id) = intmax(class(im)); % ensure it works with 16bit too
%             im(:,:,c) = ch;
%         end
%     end
% end
% 
% imwrite(im,outfile);
% 
% 

%  BELOW HERE: NOT READY
%
% % Scale
%
% 
% % Size measurements
% 
% 
% % Annotations
% [x,y,strlist,meas1,meas2,CStr] = fcn_read_annotations(txtfile)
%     


end
