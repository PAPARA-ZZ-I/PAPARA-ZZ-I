function [usable_area_in_PXL,NewMaps] = fcn_undistort_area(UsableAreaCell,camera_intrinsics,ImageWidthPXL,ImageHeightPXL,PrecomputedMaps)
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
    if isempty(UsableAreaCell) || ~iscell(UsableAreaCell)
        UsableAreaType = 'rectangle';
        UsableAreaRect = [[1 , ImageWidthPXL] ; [1 , ImageHeightPXL]];
    else
        UsableAreaType = UsableAreaCell{1};
        UsableAreaRect = UsableAreaCell{2}; % corner coordinates of (bounding) rectangle. If 'UsableAreaType' is 'polygon', the rectangle is the smallest rectangle that contains the polygon.
        if strcmpi(UsableAreaType,'polygon')==1
            polygon_sel = UsableAreaCell{3}; % logical array (of same size as the bounding rectangle) with '1' values inside the polygon and '0' outside.
        end
    end


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
    
    
    % Avoid calculations if not necessary
    if (exist('k1','var')~=1 || k1==0) ...
            && (exist('k2','var')~=1 || k2==0) ...
            && (exist('k3','var')~=1 || k3==0) ...
            && (exist('p1','var')~=1 || p1==0) ...
            && (exist('p2','var')~=1 || p2==0)
        usable_area_in_PXL = [];
        if exist('PrecomputedMaps','var')==1
            NewMaps = PrecomputedMaps;
        else
            NewMaps = [];
        end
        return;
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
    if exist('PrecomputedMaps','var')==1 && ~isempty(PrecomputedMaps)
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
        
        if k1==PcM.ci.k1 && k2==PcM.ci.k2 && k3==PcM.ci.k3 ...
                && p1==PcM.ci.p1 && p2==PcM.ci.p2
            cnt = cnt + 1;
        end
        if cnt == 10
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
    
    
    %% Normalised image pixel coordinates of image
    actionlist = {'Run all'};
    if ismember(actionflag,actionlist)==1
        x_map = ones(tmpHeight,1) * (1:tmpWidth);
        y_map = (1:tmpHeight)' * ones(1,tmpWidth);
        
        if SkewCoeff==0
            x_map = ( x_map - cx ) ./ fx;
            y_map = ( y_map - cy ) ./ fy;
        else
            % Matrix of intrinsic parameters
            Mi = [ fx SkewCoeff OpticalCentreX ; 0 fy OpticalCentreY ; 0 0 1 ];
            
            % pixel coordinates in vectors
            pvec = [ x_map(:)' ; y_map(:)' ; ones(size(x_map(:)')) ];
            
            % Normalisation
            pvec = fcn_inv(Mi) * pvec;
            x_map = reshape(pvec(1,:)',size(x_map));
            y_map = reshape(pvec(2,:)',size(y_map));
        end
        r = sqrt( x_map.^2 + y_map.^2 );
        
        if nargout > 1
            NewMaps.before_LensCorrection.x_map = x_map;
            NewMaps.before_LensCorrection.y_map = y_map;
            NewMaps.before_LensCorrection.r = r;
        end
    end
    
    
    %% Lens distortion (radial and tangential)
    
    actionlist = [ actionlist , {'Run lens correction'} ];
    if ismember(actionflag,actionlist)==1
        % the conditions below are intended to avoid unnecessary calculations
        [x_map,y_map] = fcn_undist_lens(x_map,y_map,r,k1,k2,k3,p1,p2);
        
        % un-normalise the coordinates
        if SkewCoeff==0
            x_map = (x_map .* fx) + cx;
            y_map = (y_map .* fy) + cy;
        else
            % pixel coordinates in vectors
            pvec = [ x_map(:)' ; y_map(:)' ; ones(size(x_map(:)')) ];
            
            % Un-normalisation
            pvec = Mi * pvec;
            x_map = reshape(pvec(1,:)',size(x_map));
            y_map = reshape(pvec(2,:)',size(y_map));
        end
        
        
        if nargout > 1
            NewMaps.after_LensCorrection.x_map = x_map;
            NewMaps.after_LensCorrection.y_map = y_map;
        end
    end
    
    
    %% Compute area of usable area
    x1 = UsableAreaRect(1,1); x2 = UsableAreaRect(1,2) + 1; % +1 because the 'x_map' and 'y_map' have one extra row and column.
    y1 = UsableAreaRect(2,1); y2 = UsableAreaRect(2,2) + 1; % +1 because the 'x_map' and 'y_map' have one extra row and column.
    x_subset = x_map(y1:y2,x1:x2);
    y_subset = y_map(y1:y2,x1:x2);
    x_diff = x_subset(2:end,2:end) - x_subset(2:end,1:end-1);
    y_diff = y_subset(2:end,2:end) - y_subset(1:end-1,2:end);
    switch UsableAreaType
        case 'rectangle'
            pxl_areas = x_diff .* y_diff;
        case 'polygon'
            pxl_areas = x_diff(polygon_sel) .* y_diff(polygon_sel);
    end
    usable_area_in_PXL = sum(sum(pxl_areas));
    
end