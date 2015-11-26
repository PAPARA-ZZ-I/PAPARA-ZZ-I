function cdata = fcn_icon(icon,TP)
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
% TP = Transparent Color

%%
% Load the icon
[cdata,map] = imread(icon);
 
% Convert into 3D RGB-space
cdata = ind2rgb(cdata,map);

% Some color needs to be transparent
for k=1:size(cdata,3)
    stmp = cdata(:,:,k)*255==TP(k);
    if k>1
        s = s .* stmp;
    else
        s = stmp;
    end
end
s = logical(s);
for k=1:size(cdata,3)
    cdtmp = cdata(:,:,k);
    cdtmp(s) = NaN;
    cdata(:,:,k) = cdtmp;
end

end
