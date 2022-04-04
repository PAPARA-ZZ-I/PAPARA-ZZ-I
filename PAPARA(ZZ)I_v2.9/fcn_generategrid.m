function pts = fcn_generategrid(pointmax,imw,imh)
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

imratio = imw / imh;
r = 0; % rows
c = 0; % columns
while r * c < pointmax
    r = r + 1;
    c = round(r * imratio);
end
% At this point, r*c is equal or larger than 'pointmax', so
% we look for what number of rows and columns is closest to
% the number of points (comparing r and r-1 and their
% corresponding c values)
d1 = pointmax - ((r-1) * round((r-1) * imratio));
d2 = (r * c) - pointmax;
if d1 < d2 % we take the r*c that are just below pointmax
    d = d1;
    r = r-1;
    c = round(r * imratio);
    inc = 1;
else  % we take the r*c that are just above pointmax
    d = d2;
    inc = -1;
end

% looking for the best row and column lengths distribution
allrows = ones(r,1) .* c;
allcols = ones(c,1) .* r;
rowIDs = 1:r;
colIDs = 1:c;
oddRowIDs = rowIDs(mod(rowIDs,2)~=0);
evenRowIDs = rowIDs(mod(rowIDs,2)==0);
oddColIDs = colIDs(mod(colIDs,2)~=0);
evenColIDs = colIDs(mod(colIDs,2)==0);
switch d
    case numel(oddRowIDs)
        selIDs1 = oddRowIDs;
        str = 'rows';
    case numel(evenRowIDs)
        selIDs1 = evenRowIDs;
        str = 'rows';
    case numel(oddColIDs)
        selIDs1 = oddColIDs;
        str = 'cols';
    case numel(evenColIDs)
        selIDs1 = evenColIDs;
        str = 'cols';
    otherwise
        selIDs1 = oddRowIDs;
        selIDs2 = evenRowIDs;
        str = 'rows';
end

while d > 0
    for k=selIDs1
        if d > 0
            eval(['all',str,'(k,1) = all',str,'(k,1) + inc;']); % add increment to this row or column
            d = d - 1;
        end
    end
    if d > 0 && exist('selIDs2','var')==1
        for k=selIDs2
            if d > 0
                eval(['all',str,'(k,1) = all',str,'(k,1) + inc;']); % add increment to this row or column
                d = d - 1;
            end
        end
    end
end

% Compute point coordinates
x = [];
y = [];
switch str
    case 'rows'
        rowMax = r;
        spacingY = imh / rowMax;
        yval = ( 1:rowMax ) .* spacingY - spacingY/2;
        for r=1:numel(allrows)
            spacingX = imw / allrows(r,1);
            xval = ( 1:allrows(r,1) ) .* spacingX - spacingX/2;
            x = [ x ; xval'];
            y = [ y ; yval(1,r)*ones(size(xval')) ];
        end
        
    case 'cols'
        colMax = c;
        spacingX = imw / colMax;
        xval = ( 1:colMax ) .* spacingX - spacingX/2;
        for c=1:numel(allcols)
            spacingY = imh / allcols(c,1);
            yval = ( 1:allcols(c,1) ) .* spacingY - spacingY/2;
            y = [ y ; yval'];
            x = [ x ; xval(1,c)*ones(size(yval')) ];
        end
        
end

pts = [x,y];

end

