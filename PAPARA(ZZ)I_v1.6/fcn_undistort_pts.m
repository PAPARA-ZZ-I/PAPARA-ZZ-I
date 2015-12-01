function pts = fcn_undistort_pts(pts,camera_intrinsics,ImageWidthPXL,ImageHeightPXL)
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
    fieldlist = fieldnames(camera_intrinsics);
    for str = fieldlist'
        tmpval = camera_intrinsics.(str{1});
        if ~isempty(tmpval)
            eval([str{1} ' = tmpval;']);
        else
            eval([str{1} ' = 0;']);
        end
    end

    if exist('ImageWidthPXL','var')~=1, ImageWidthPXL = SensorWidthPXL; end % image width [pxl]
    if exist('ImageHeightPXL','var')~=1, ImageHeightPXL = SensorHeightPXL; end % image height [pxl]
    if isempty(OpticalCentreX), OpticalCentreX = ImageWidthPXL/2; end % optical centre
    if isempty(OpticalCentreY), OpticalCentreY = ImageHeightPXL/2; end % optical centre
    
    fx = FocalMM * ImageWidthPXL / SensorWidthMM; % focal length [pxl]
    fy = FocalMM * ImageHeightPXL / SensorHeightMM; % focal length [pxl]
    

    %% pixel coordinates
    x = pts(:,1);
    y = pts(:,2);
    
    
    %% normalized pixel coordinates and distance maps
    % Normalized image pixel coordinates
    x = ( x - OpticalCentreX ) / fx;
    y = ( y - OpticalCentreY ) / fy;
    r = sqrt( x.^2 + y.^2 );
    
    
    
    %% Radial distortion
    % x_distorted = x_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )
    % y_distorted = y_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )
    
    [x,y] = fcn_undist_radial(x,y,r,k1,k2,k3);
    
    
    %% Tangential distortion
    % x_distorted = x + ( 2 * p1 * x * y + p2 * (r^2 + 2 * x^2) )
    % y_distorted = y + ( p1 * (r^2 + 2 * y^2) + 2 * p2 * x * y )
    
    [x,y] = fcn_undist_tangential(x,y,r,p1,p2);
    

    %% Un-normalise the coordinates
    x = (x .* fx) + OpticalCentreX;
    y = (y .* fy) + OpticalCentreY;
    pts = [x,y];
    
end