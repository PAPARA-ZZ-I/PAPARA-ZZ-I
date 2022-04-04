function fcn_ignim(n,imagelist,inpath,userid,sep)
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
% Disable every button in the interface
fcn_freeze_fig('off',gcf,'Button-containing panel');
drawnow;

% Determine action based on the status of the button
ignorelist = sprintf('%s%s_annotations%signorelist.txt',inpath,userid,sep);
onoff = get(findall(gcf,'Tag','Toolbar_Ignore'),'State');
switch onoff
    case 'on' % the button has just been activated
        fid = fopen(ignorelist,'a');
        fprintf(fid,'%s\r\n',imagelist{n});
        fclose(fid);
        
    case 'off' % the button has just been de-activated
        fid = fopen(ignorelist,'r');
        if fid ~= -1
            Data = textscan(fid,'%s','delimiter','\n');
            CStr = Data{1};
            fclose(fid);
            
            idC = strfind(CStr,imagelist{n});
            id = find(~cellfun('isempty',idC), 1);
            
            if ~isempty(id)
                CStr(id) = [];
                CStr = CStr(~cellfun('isempty',CStr));
            end
            
            % Create a new file and save it again:
            fid = fopen(ignorelist,'w');
            if fid == -1, error('Cannot open file'), end
            fprintf(fid,'%s\r\n',CStr{:});
            fclose(fid);
            
        end
end

end
