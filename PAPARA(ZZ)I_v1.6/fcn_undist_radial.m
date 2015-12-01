function [x,y] = fcn_undist_radial(x,y,r,k1,k2,k3)
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




%% Radial distortion
% x_distorted = x_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )
% y_distorted = y_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )

% the conditions are intended to avoid unnecessary calculations
if k3~=0
    x = x .* ( 1 + k1*(r.^2) + k2*(r.^4) + k3*(r.^6) );
    y = y .* ( 1 + k1*(r.^2) + k2*(r.^4) + k3*(r.^6) );
elseif k2~=0
    x = x .* ( 1 + k1*(r.^2) + k2*(r.^4) );
    y = y .* ( 1 + k1*(r.^2) + k2*(r.^4) );
elseif k1~=0
    x = x .* ( 1 + k1*(r.^2) );
    y = y .* ( 1 + k1*(r.^2) );
end

end