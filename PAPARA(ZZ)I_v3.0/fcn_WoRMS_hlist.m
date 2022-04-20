function [WoRMSlist,WoRMSrecords] = fcn_WoRMS_hlist(hlist,objWoRMS,searchstr,searchtype,WoRMSlist,WoRMSrecords,first_match)
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

if first_match==1 % no need to concatenate results
    [NEWlist,~,NEWrecords] = fcn_WoRMS_search(objWoRMS,{searchstr},...
        searchtype,'is in full','All taxa',[],[],first_match);
else
    [NEWlist,~,NEWrecords] = fcn_WoRMS_search(objWoRMS,{searchstr},...
        searchtype,'is in full','All taxa',[],[],first_match,WoRMSlist,[],WoRMSrecords);
end

if iscell(NEWlist) && ~isempty(strtrim(NEWlist{1}))
    WoRMSlist = NEWlist;
    WoRMSrecords = NEWrecords;
    set(hlist,'Value',1); % prevents display errors
    set(hlist,'String',WoRMSlist);
end
    
    
end


