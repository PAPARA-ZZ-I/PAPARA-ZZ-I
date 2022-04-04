function [parent_name,parent_rank] = fcn_WoRMS_parent(WoRMSrecords,TaxoRanking)
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
k = 0;
current_record = [];
while isempty(current_record) && k < numel(WoRMSrecords)
    k = k + 1;
    if ~isempty(WoRMSrecords(k).rank)
        current_record = WoRMSrecords(k);
    end
end


parent_name = [];
if isempty(current_record), parent_rank = []; return; end % exit function
pos = strfind(TaxoRanking,current_record.rank);
pos = find(not(cellfun('isempty',pos)));
while isempty(parent_name) && pos >= 1
    pos = pos - 1;
    if pos < 1, parent_rank = []; continue; end % exit loop
    parent_rank = lower(TaxoRanking{pos});
    if isfield(current_record,parent_rank)
        parent_name = current_record.(parent_rank);
    end
end
    
    
end


