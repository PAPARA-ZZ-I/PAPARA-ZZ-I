function imout = fcn_resize(im,s,outputclass)
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

% size of output image
imh = floor(s*size(im,1));
imw = floor(s*size(im,2));
if numel(size(im))==2, imc = 1; else imc = size(im,3); end

% positions of input pixels in output image
imrows = ( (1:imh) - .5)./s + .5;
imcols = ( (1:imw) - .5)./s + .5;

imdbl = double(im)./double(intmax(class(im))); % convert to double precision

if imc==1 % image is greyscale
    imout = interp2(imdbl,imcols,imrows','cubic');
else
    imout = zeros(imh,imw,imc);
    for c=1:imc
        imout(:,:,c) = interp2(imdbl(:,:,c),imcols,imrows','cubic');
    end
end

if exist('outputclass','var')~=1 || isempty(outputclass)
    imout = eval([class(im) '( imout .* double(intmax(class(im))) )']);
else
    imout = eval([outputclass '( imout .* double(intmax(outputclass)) )']);
end

end
