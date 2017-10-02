function camera_intrinsics = fcn_intrinsics(imagelist,inpath)
%% Copyright 2015-2017 Yann Marcon and Autun Purser

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

if exist(inpath,'dir')==7
    infile = [ inpath , 'camera_intrinsics.pap' ];
    if exist(infile,'file')~=2, camera_intrinsics = []; return; end
elseif exist(inpath,'file')==2
    infile = inpath;
else
    camera_intrinsics = [];
    return;
end


% remove extension from imagelist names
nmax = numel(imagelist); % max number of images
for n=1:nmax
    [~,iname,~] = fileparts(imagelist{n});
    imagelist{n} = iname;
end


paramlist = {'OpticalCentreX','OpticalCentreY','FocalMM',...
    'SensorWidthMM','SensorHeightMM','SensorWidthPXL','SensorHeightPXL',...
    'SkewCoeff','k1','k2','k3','p1','p2'};
camera_intrinsics(nmax) = struct('OpticalCentreX',[],'OpticalCentreY',[],'FocalMM',[],...
    'SensorWidthMM',[],'SensorHeightMM',[],'SensorWidthPXL',[],'SensorHeightPXL',[],...
    'SkewCoeff',[],'k1',[],'k2',[],'k3',[],'p1',[],'p2',[]);

fid = fopen(infile,'r');
while ~feof(fid)
    tline = fgetl(fid);
    if tline ~= -1
        strline = textscan(tline,'%s','delimiter',',');
        strline = lower(strline{1}');
        switch upper(strline{1})
            case 'DEFAULT'
                for k=2:numel(strline)
                    if ismember(strline{k},lower(paramlist))
                        [~,locb] = ismember(strline{k},lower(paramlist));
                        locb = locb(locb~=0);
                        id = locb(1);
                        for n=1:nmax
                            camera_intrinsics(n).(paramlist{id}) = str2double(strline{k+1});
                        end
                        
                    elseif strcmpi(strline{k},'OpticalCenterX') % American spelling
                        for n=1:nmax
                            camera_intrinsics(n).OpticalCentreX = str2double(strline{k+1});
                        end
                    elseif strcmpi(strline{k},'OpticalCenterY') % American spelling
                        for n=1:nmax
                            camera_intrinsics(n).OpticalCentreY = str2double(strline{k+1});
                        end
                    end
                end
                
            case {'%','COMMENT'}
                continue;
                
            otherwise
                [~,cname,~] = fileparts(strline{1});
                idC = strfind(upper(imagelist),upper(cname));
                id = find(~cellfun('isempty',idC), 1);
                if ~isempty(id)
                    for n = id
                        if numel(cname)==numel(imagelist{n}) % ensure you don't update other images with similar names
                            for k=2:numel(strline)
                                if ismember(strline{k},lower(paramlist))
                                    [~,locb] = ismember(strline{k},lower(paramlist));
                                    locb = locb(locb~=0);
                                    id = locb(1);
                                    camera_intrinsics(n).(paramlist{id}) = str2double(strline{k+1});
                                    
                                elseif strcmpi(strline{k},'OpticalCenterX') % American spelling
                                    camera_intrinsics(n).OpticalCentreX = str2double(strline{k+1});
                                elseif strcmpi(strline{k},'OpticalCenterY') % American spelling
                                    camera_intrinsics(n).OpticalCentreY = str2double(strline{k+1});
                                end
                            end
                        end
                        
                    end
                end
                
        end
    end
end
fclose(fid);

end





