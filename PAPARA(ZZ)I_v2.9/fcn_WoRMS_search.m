function [results,recordcell,recordstruct] = fcn_WoRMS_search(objWoRMS,searchstr,selstr1,selstr2,selstr3,htxtleft,htxtright,first_match,oldresults,oldrecordcell,oldrecordstruct)
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
if iscell(searchstr), searchstr = searchstr{1}; end % prevents errors
if isempty(searchstr), searchstr = ''; end % prevents errors

searchstr = strtrim(searchstr); % remove leading and trailing spaces

hwb = waitbar(0,'Please wait...','Name','Searching through WoRMS database...');

if exist('first_match','var')~=1 || isempty(first_match), first_match = 1; end


switch selstr3
    case 'Marine only'
        marine_only = 1;
    otherwise
        marine_only = 0;
end

if ismember(selstr1,{'Scientific Name','Common Name'})~=0
    switch selstr2
        case 'contains'
            like = 0;
            searchstr = [ '%' searchstr '%' ];
        case 'is in full'
            like = 0;
        case 'begins with'
            like = 0;
            searchstr = [ searchstr '%' ];
        case 'ends with'
            like = 0;
            searchstr = [ '%' searchstr ];
    end
end

switch selstr1
    case 'Scientific Name'
        recordstruct = getAphiaRecordsByNames(objWoRMS,{searchstr},like,0,marine_only);
        % recordstruct = matchAphiaRecordsByNames(objWoRMS,{searchstr},marine_only);
        
    case 'Common Name'
        recordstruct = getAphiaRecordsByVernacular(objWoRMS,{searchstr},like,first_match);
        
    case 'AphiaID'
        recordstruct = getAphiaRecordByID(objWoRMS,searchstr);
        
    case 'Children from AphiaID'
        recordstruct = getAphiaChildrenByID(objWoRMS,searchstr,first_match,marine_only);
        
    otherwise
        pos1 = strfind(selstr1,'['); pos1 = pos1(1) + 1;
        pos2 = strfind(selstr1,']'); pos2 = pos2(1) + 1;
        extID = lower(selstr1(pos1:pos2));
        recordstruct = getAphiaRecordByExtID(objWoRMS,searchstr,extID);
        
end
waitbar(.8,hwb);

% Create list of results
if ~isempty(recordstruct)
    results = {};
    recordcell = cell(numel(recordstruct),1);
    for k = 1:numel(recordstruct)
        % Get the scientific name with the AphiaID
        sNameAphiaID = [recordstruct(k).scientificname,' [',...
            sprintf('%g',recordstruct(k).AphiaID),']'];
        
        % Create list of results
        results = [ results ; {sNameAphiaID} ];
        
        
        % Convert the records structure into a cell array for display in
        % listboxes
        strlist = fieldnames(recordstruct(k));
        for str = strlist'
            if ischar(recordstruct(k).(str{1}))
                recordcell{k,1} = [ recordcell{k,1} ; { [str{1},': ',recordstruct(k).(str{1})] } ];
            else
                recordcell{k,1} = [ recordcell{k,1} ; { [str{1},': ',sprintf('%g',recordstruct(k).(str{1}))] } ];
            end
        end
    end
end


% Prevent errors
if exist('results','var')~=1 || isempty(results)==1
    results = {''};
    recordcell = {''};
end

% Concatenate previous reults if they exist
if ~isempty(results{1}) && ismember(selstr1,{'Common Name';'Children from AphiaID'})
    if exist('oldresults','var')==1, results = [ oldresults ; results ]; end
    if exist('oldrecordcell','var')==1, recordcell = [ oldrecordcell ; recordcell ]; end
    if exist('oldrecordstruct','var')==1, recordstruct = [ oldrecordstruct ; recordstruct ]; end
else
    if exist('oldresults','var')==1, results = oldresults; end
    if exist('oldrecordcell','var')==1, recordcell = oldrecordcell; end
    if exist('oldrecordstruct','var')==1, recordstruct = oldrecordstruct; end
end

if ~isempty(htxtleft), set(htxtleft,'Value',1); set(htxtleft,'String',results); end
if ~isempty(htxtright), set(htxtright,'Value',1); set(htxtright,'String',''); end % clears the right list box

% select the first of the "new" results (if "old" results were provided)
if exist('oldresults','var')==1 && numel(results)>numel(oldresults)
    set(htxtleft,'Value',numel(oldresults)+1);
end

waitbar(1,hwb);
delete(hwb);

end
