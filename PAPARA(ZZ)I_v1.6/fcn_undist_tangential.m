function [x,y] = fcn_undist_tangential(x,y,r,p1,p2)
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




%% Tangential distortion
% x_distorted = x + ( 2 * p1 * x * y + p2 * (r^2 + 2 * x^2) )
% y_distorted = y + ( p1 * (r^2 + 2 * y^2) + 2 * p2 * x * y )

% the conditions are intended to avoid unnecessary calculations
if p1~=0 && p2~=0
    x = x + ( 2 * p1 * x .* y + p2 * (r.^2 + 2 * x.^2) );
    y = y + ( p1 * (r.^2 + 2 * y.^2) + 2 * p2 * x .* y );
elseif p1~=0
    x = x + ( 2 * p1 * x .* y );
    y = y + ( p1 * (r.^2 + 2 * y.^2) );
elseif p2~=0
    x = x + ( p2 * (r.^2 + 2 * x.^2) );
    y = y + ( 2 * p2 * x .* y );
end

end