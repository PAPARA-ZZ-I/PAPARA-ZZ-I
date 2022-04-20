function [B, detA] = fcn_inv(A)
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


%% Function:
% Computes the inverse of a 3x3 matrix using the cofactors.
%
% [B, detA] = fcn_inv(A);


% Input variable:
% --------------
%
% A : 3x3 or 4x4 matrix


% Output variable:
% ---------------
%
% B :    3x3 or 4x4 matrix, inverse of A
% detA : determinant of A




%%
switch length(A)
    case 3
        a = A(1,1);
        b = A(1,2);
        c = A(1,3);
        d = A(2,1);
        e = A(2,2);
        f = A(2,3);
        g = A(3,1);
        h = A(3,2);
        i = A(3,3);
        
        % calculates the matrix determinant
        detA = a * (e*i - h*f) - b * (d*i - g*f) + c * (d*h - g*e);
        
        % matrix of cofactors
        cofactors = [ e*i - f*h , f*g - d*i , d*h - e*g ; ...
            c*h - b*i , a*i - c*g , b*g - a*h ; ...
            b*f - c*e , c*d - a*f , a*e - b*d ];
    
    case 4
        a11 = A(1,1);
        a12 = A(1,2);
        a13 = A(1,3);
        a14 = A(1,4);
        
        a21 = A(2,1);
        a22 = A(2,2);
        a23 = A(2,3);
        a24 = A(2,4);
        
        a31 = A(3,1);
        a32 = A(3,2);
        a33 = A(3,3);
        a34 = A(3,4);
        
        a41 = A(4,1);
        a42 = A(4,2);
        a43 = A(4,3);
        a44 = A(4,4);
        
        % calculates the matrix determinant
        detA = a11*a22*a33*a44 + a11*a23*a34*a42 + a11*a24*a32*a43 ...
            + a12*a21*a34*a43 + a12*a23*a31*a44 + a12*a24*a33*a41 ...
            + a13*a21*a32*a44 + a13*a22*a34*a41 + a13*a24*a31*a42 ...
            + a14*a21*a33*a42 + a14*a22*a31*a43 + a14*a23*a32*a41 ...
            - a11*a22*a34*a43 - a11*a23*a32*a44 - a11*a24*a33*a42 ...
            - a12*a21*a33*a44 - a12*a23*a34*a41 - a12*a24*a31*a43 ...
            - a13*a21*a34*a42 - a13*a22*a31*a44 - a13*a24*a32*a41 ...
            - a14*a21*a32*a43 - a14*a22*a33*a41 - a14*a23*a31*a42;
        
        % matrix of cofactors
        cofactors = zeros(4,4);
        
        cofactors(1,1) = a22*a33*a44 + a23*a34*a42 + a24*a32*a43 - a22*a34*a43 - a23*a32*a44 - a24*a33*a42;
        cofactors(1,2) = a21*a34*a43 + a23*a31*a44 + a24*a33*a41 - a21*a33*a44 - a23*a34*a41 - a24*a31*a43;
        cofactors(1,3) = a21*a32*a44 + a22*a34*a41 + a24*a31*a42 - a21*a34*a42 - a22*a31*a44 - a24*a32*a41;
        cofactors(1,4) = a21*a33*a42 + a22*a31*a43 + a23*a32*a41 - a21*a32*a43 - a22*a33*a41 - a23*a31*a42;
        
        cofactors(2,1) = a12*a34*a43 + a13*a32*a44 + a14*a33*a42 - a12*a33*a44 - a13*a34*a42 - a14*a32*a43;
        cofactors(2,2) = a11*a33*a44 + a13*a34*a41 + a14*a31*a43 - a11*a34*a43 - a13*a31*a44 - a14*a33*a41;
        cofactors(2,3) = a11*a34*a42 + a12*a31*a44 + a14*a32*a41 - a11*a32*a44 - a12*a34*a41 - a14*a31*a42;
        cofactors(2,4) = a11*a32*a43 + a12*a33*a41 + a13*a31*a42 - a11*a33*a42 - a12*a31*a43 - a13*a32*a41;
        
        cofactors(3,1) = a12*a23*a44 + a13*a24*a42 + a14*a22*a43 - a12*a24*a43 - a13*a22*a44 - a14*a23*a42;
        cofactors(3,2) = a11*a24*a43 + a13*a21*a44 + a14*a23*a41 - a11*a23*a44 - a13*a24*a41 - a14*a21*a43;
        cofactors(3,3) = a11*a22*a44 + a12*a24*a41 + a14*a21*a42 - a11*a24*a42 - a12*a21*a44 - a14*a22*a41;
        cofactors(3,4) = a11*a23*a42 + a12*a21*a43 + a13*a22*a41 - a11*a22*a43 - a12*a23*a41 - a13*a21*a42;
        
        cofactors(4,1) = a12*a24*a33 + a13*a22*a34 + a14*a23*a32 - a12*a23*a34 - a13*a24*a32 - a14*a22*a33;
        cofactors(4,2) = a11*a23*a34 + a13*a24*a31 + a14*a21*a33 - a11*a24*a33 - a13*a21*a34 - a14*a23*a31;
        cofactors(4,3) = a11*a24*a32 + a12*a21*a34 + a14*a22*a31 - a11*a22*a34 - a12*a24*a31 - a14*a21*a32;
        cofactors(4,4) = a11*a22*a33 + a12*a23*a31 + a13*a21*a32 - a11*a23*a32 - a12*a21*a33 - a13*a22*a31;
        
end
    
    % inverse matrix
    B = cofactors' / detA;
    
    
end