function output = fcn_field2array(structure,fieldpath,classtype)
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
% Converts a field of a n-by-m data structure to either a n-by-m matrix or
% a n-by-m cell array.

%%
if nargin < 3, classtype = 'cell'; end

switch classtype
    case 'cell'
        output = cell(size(structure));
    case 'matrix'
        output = zeros(size(structure));
    case 'structure'
        output = struct;
end


for n = 1:size(structure,1)
    for m = 1:size(structure,2)
        switch classtype
            case 'cell'
                fieldval = structure(n,m).(fieldpath);
                output{n,m} = fieldval;
                
            case 'matrix'
                fieldval = structure(n,m).(fieldpath);
                if isempty(fieldval), fieldval = NaN; end % avoids errors
                output(n,m) = fieldval;
                
            case 'structure'
                subfields = fieldnames(structure(n,m).(fieldpath));
                for k = 1:length(subfields)
                    fieldval = structure(n,m).(fieldpath).(subfields{k});
                    output(n,m).(subfields{k}) = fieldval;
                end
        end
    end
end
    
end