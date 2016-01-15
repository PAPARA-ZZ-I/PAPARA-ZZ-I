function fid = fcn_annotate(fid,h,CP,str,annotype,colorcode)
%% Copyright 2015, 2016 Yann Marcon and Autun Purser

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
if exist('colorcode','var')~=1, colorcode = 'y'; end % default color is yellow

% Write annotation
if isempty(str) || strcmp(str,' ')==1, return; end
fprintf(fid,'%f\t%f\t%s\r\n',CP(1,1),CP(1,2),str);

switch annotype
    case 'Annotation'
        cbfun = ['fid = fcn_seldelA(fid,gcbf,gcbo,infotxt,''',str,''');'];
        plot(h,CP(1,1),CP(1,2),'o','Color',colorcode,'Tag','Annotation',...
            'ButtonDownFcn',cbfun);
        
    case 'GeneratedPoint' % not needed at the moment
        
%         if iscell(colorcode)
%             ms = 6; % default marker size
%             for k=1:numel(colorcode)
%                 hplot = plot(h,CP(1,1),CP(1,2),'o','Color',colorcode{k},...
%                     'MarkerSize',ms,'Tag','GeneratedPoint');
%                 ms = ms + 4;
%                 
%                 if k==1,
%                     cbfun = ['fid = fcn_seldelGP(fid,gcbf,gcbo,infotxt,''',str,''');'];
%                     set(hplot,'ButtonDownFcn',cbfun);
%                 end
%             end
%         end
end


end
