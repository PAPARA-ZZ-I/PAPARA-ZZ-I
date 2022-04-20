function pts = fcn_undistort_pts(pts,camera_intrinsics,ImageWidthPXL,ImageHeightPXL)
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
        return;
    end
    

    if exist('ImageWidthPXL','var')~=1, ImageWidthPXL = SensorWidthPXL; end % image width [pxl]
    if exist('ImageHeightPXL','var')~=1, ImageHeightPXL = SensorHeightPXL; end % image height [pxl]
    if isempty(OpticalCentreX), OpticalCentreX = ImageWidthPXL/2; end % optical centre
    if isempty(OpticalCentreY), OpticalCentreY = ImageHeightPXL/2; end % optical centre
    
    fx = FocalMM * ImageWidthPXL / SensorWidthMM; % focal length [pxl]
    fy = FocalMM * ImageHeightPXL / SensorHeightMM; % focal length [pxl]
    

    %% pixel coordinates
    x = pts(1,:);
    y = pts(2,:);
    
    
    %% Normalised image pixel coordinates
    if SkewCoeff==0
        x = ( x - OpticalCentreX ) / fx;
        y = ( y - OpticalCentreY ) / fy;
    else
        % Matrix of intrinsic parameters
        Mi = [ fx SkewCoeff OpticalCentreX ; 0 fy OpticalCentreY ; 0 0 1 ];
        
        % pixel coordinates in vectors
        pvec = [ x ; y ; ones(size(x)) ];
        
        % Normalisation
        pvec = fcn_inv(Mi) * pvec;
        x = pvec(1,:);
        y = pvec(2,:);
    end
    r = sqrt( x.^2 + y.^2 );
    
    
    
    %% Lens distortion (radial and tangential)
    [x,y] = fcn_undist_lens(x,y,r,k1,k2,k3,p1,p2);
    
    

    %% Un-normalise the coordinates
    if SkewCoeff==0
        x = (x .* fx) + OpticalCentreX;
        y = (y .* fy) + OpticalCentreY;
        pts = [x;y];
    else
        % pixel coordinates in vectors
        pvec = [ x ; y ; ones(size(x)) ];
        
        % Un-normalisation
        pvec = Mi * pvec;
        
        pts = pvec(1:2,:);
    end
    
end