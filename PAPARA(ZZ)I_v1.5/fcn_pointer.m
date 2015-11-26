function fcn_pointer(h)
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
iptPointerManager(h,'enable');

switch get(h,'Pointer')
    case {'cross','fullcross','crosshair','fullcrosshair'}
        % define custom pointer
        P = ones(16)+1;
        P(1,:) = 1; P(16,:) = 1;
        P(:,1) = 1; P(:,16) = 1;
        P(1:3,8:9) = 1; P(13:16,8:9) = 1;
        P(8:9,1:3) = 1; P(8:9,13:16) = 1;
        P(4:12,4:12) = NaN;  % Create a transparent region in the center
        
        pointerBehavior.enterFcn = @(h, currentPoint) set(h,...
            'Pointer','custom','PointerShapeCData',P,'PointerShapeHotSpot',[8 8]);
        
    case 'custom'
        pointerBehavior.enterFcn = @(h, currentPoint) set(h,'Pointer','cross');
        
end

pointerBehavior.exitFcn = [];
pointerBehavior.traverseFcn = [];
iptSetPointerBehavior(gca,pointerBehavior);

end