function [x,y] = fcn_undist_lens(x,y,r,k1,k2,k3,p1,p2)
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




%% Lens distortion
% x_distorted = x_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )
%                             + ( 2 * p1 * x * y + p2 * (r^2 + 2 * x^2) )
% y_distorted = y_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )
%                             + ( p1 * (r^2 + 2 * y^2) + 2 * p2 * x * y )


% the conditions are intended to avoid unnecessary calculations
if k1==0, k1poly = 0; else k1poly = k1*(r.^2); end
if k2==0, k2poly = 0; else k2poly = k2*(r.^4); end
if k3==0, k3poly = 0; else k3poly = k3*(r.^6); end
if p1==0
    p1polyX = 0;
    p1polyY = 0;
else
    p1polyX = 2 * p1 * x .* y;
    p1polyY = p1 * (r.^2 + 2 * y.^2);
end
if p2==0
    p2polyX = 0;
    p2polyY = 0;
else
    p2polyX = p2 * (r.^2 + 2 * x.^2);
    p2polyY = 2 * p2 * x .* y;
end

x = x .* ( 1 + k1poly + k2poly + k3poly ) + p1polyX + p2polyX;
y = y .* ( 1 + k1poly + k2poly + k3poly ) + p1polyY + p2polyY;

end