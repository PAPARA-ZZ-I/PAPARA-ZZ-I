function [rectarea,NewMaps] = fcn_undistort_area(RectangleArea,camera_intrinsics,ImageWidthPXL,ImageHeightPXL,PrecomputedMaps)
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
    if isempty(RectangleArea), RectangleArea = [1,1,ImageWidthPXL,ImageHeightPXL]; end


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
    
    if nargout > 1
        NewMaps.camera_intrinsics = camera_intrinsics;
        NewMaps.image_parameters.ImageWidthPXL = ImageWidthPXL;
        NewMaps.image_parameters.ImageHeightPXL = ImageHeightPXL;
    end
    
    %% Check if camera parameters and image dimensions are identical as in previous images
    % (this step saves lots of computation time if images have the same
    % calibration parameters).
    actionflag = 'Run all';
    if exist('PrecomputedMaps','var')==1
        PcM.ci = PrecomputedMaps.camera_intrinsics; % simplifies notation
        PcM.ip = PrecomputedMaps.image_parameters;
        
        cnt = 0;
        if OpticalCentreX == PcM.ci.OpticalCentreX, cnt = cnt + 1; end
        if OpticalCentreY == PcM.ci.OpticalCentreY, cnt = cnt + 1; end
        if FocalMM == PcM.ci.FocalMM, cnt = cnt + 1; end
        if SensorWidthMM == PcM.ci.SensorWidthMM, cnt = cnt + 1; end
        if SensorHeightMM == PcM.ci.SensorHeightMM, cnt = cnt + 1; end
        if SensorWidthPXL == PcM.ci.SensorWidthPXL, cnt = cnt + 1; end
        if SensorHeightPXL == PcM.ci.SensorHeightPXL, cnt = cnt + 1; end
        if ImageWidthPXL == PcM.ip.ImageWidthPXL, cnt = cnt + 1; end
        if ImageHeightPXL == PcM.ip.ImageHeightPXL, cnt = cnt + 1; end
        if cnt == 9
            actionflag = 'Run lens correction';
            x_map = PrecomputedMaps.before_LensCorrection.x_map;
            y_map = PrecomputedMaps.before_LensCorrection.y_map;
            r = PrecomputedMaps.before_LensCorrection.r;
            
            if nargout > 1
                NewMaps.before_LensCorrection = PrecomputedMaps.before_LensCorrection;
            end
        end
        
        if k1==PcM.ci.k1 && k2==PcM.ci.k2 && k3==PcM.ci.k3, cnt = cnt + 1; end
        if cnt == 10
            actionflag = 'Run tangential correction';
            x_map = PrecomputedMaps.after_RadialCorrection.x_map;
            y_map = PrecomputedMaps.after_RadialCorrection.y_map;
            r = PrecomputedMaps.before_LensCorrection.r;
            
            if nargout > 1
                NewMaps.after_RadialCorrection = PrecomputedMaps.after_RadialCorrection;
            end
        end
        
        if p1==PcM.ci.p1 && p2==PcM.ci.p2, cnt = cnt + 1; end
        if cnt == 11
            actionflag = 'Skip all';
            x_map = PrecomputedMaps.after_LensCorrection.x_map;
            y_map = PrecomputedMaps.after_LensCorrection.y_map;
            r = PrecomputedMaps.before_LensCorrection.r;
            
            if nargout > 1
                NewMaps.after_LensCorrection = PrecomputedMaps.after_LensCorrection;
            end
        end
    end
    
    
    %% Add a row and a column (on left and top sides)
    tmpWidth = ImageWidthPXL + 1;
    tmpHeight = ImageHeightPXL + 1;
    cx = OpticalCentreX + 1;
    cy = OpticalCentreY + 1;
    
    
    %% Normalized image pixel coordinates of image
    actionlist = {'Run all'};
    if ismember(actionflag,actionlist)==1
        x_map = ( ones(tmpHeight,1)*(1:tmpWidth) - cx ) ./ fx;
        y_map = ( ones(tmpWidth,1)*(1:tmpHeight) - cy )' ./ fy;
        r = sqrt( x_map.^2 + y_map.^2 );
        
        if nargout > 1
            NewMaps.before_LensCorrection.x_map = x_map;
            NewMaps.before_LensCorrection.y_map = y_map;
            NewMaps.before_LensCorrection.r = r;
        end
    end
    
    
    %% Radial distortion
    % x_distorted = x_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )
    % y_distorted = y_undistorted * ( 1 + k1*(r^2) + k2*(r^4) + k3*(r^6) )
    
    actionlist = [ actionlist , {'Run lens correction'} ];
    if ismember(actionflag,actionlist)==1
        % the conditions below are intended to avoid unnecessary calculations
        [x_map,y_map] = fcn_undist_radial(x_map,y_map,r,k1,k2,k3);
        
        if nargout > 1
            NewMaps.after_RadialCorrection.x_map = x_map;
            NewMaps.after_RadialCorrection.y_map = y_map;
        end
    end
    
    
    %% Tangential distortion
    % x_distorted = x + ( 2 * p1 * x * y + p2 * (r^2 + 2 * x^2) )
    % y_distorted = y + ( p1 * (r^2 + 2 * y^2) + 2 * p2 * x * y )
    
    actionlist = [ actionlist , {'Run tangential correction'} ];
    if ismember(actionflag,actionlist)==1
        [x_map,y_map] = fcn_undist_tangential(x_map,y_map,r,p1,p2);
    end
    

    %% Un-normalise the coordinates
    % same actionlist as for tangential correction
    if ismember(actionflag,actionlist)==1
        x_map = x_map .* fx;
        y_map = y_map .* fy;
        
        if nargout > 1
            NewMaps.after_LensCorrection.x_map = x_map;
            NewMaps.after_LensCorrection.y_map = y_map;
        end
    end
    
    
    %% Compute area of selected rectangle
    x1 = RectangleArea(1,1); x2 = RectangleArea(1,1)+RectangleArea(1,3);
    y1 = RectangleArea(1,2); y2 = RectangleArea(1,2)+RectangleArea(1,4);
    x_subset = x_map(y1:y2,x1:x2);
    y_subset = y_map(y1:y2,x1:x2);
    x_diff = x_subset(2:end,2:end) - x_subset(2:end,1:end-1);
    y_diff = y_subset(2:end,2:end) - y_subset(1:end-1,2:end);
    pxl_areas = x_diff .* y_diff;
    rectarea = sum(sum(pxl_areas));
    
end