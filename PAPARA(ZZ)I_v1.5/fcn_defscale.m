function aflag = fcn_defscale(aflag,scfile,h,CP,sc,annotype)
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
switch aflag
    case 'scale1'
        % Disable all buttons and toolbars
        fcn_freeze_fig('off',gcf,'Button-containing panel');
        fcn_freeze_ZoomPan('on',gcf);
        
        % Delete any existing scale bar
        delete(findobj(h,'Tag','scalebar'));
        
        % Open text file for writing
        fid = fopen(scfile,'w');
        fprintf(fid,'%f\t%f\t',CP(1,1),CP(1,2));
        plot(h,CP(1,1),CP(1,2),'o','Color','g','Tag','scalebar');
        aflag = 'scale2';
        
    case 'scale2'
        % read first point
        fid = fopen(scfile,'r');
        scdata = importdata(scfile,'\t');
        fclose(fid);
        
        % Open text file for appending
        fid = fopen(scfile,'a');
        fprintf(fid,'%f\t%f\t%f\r\n',CP(1,1),CP(1,2),sc);
        plot(h,CP(1,1),CP(1,2),'o','Color','g','Tag','scalebar');
        plot([scdata(1) CP(1,1)],[scdata(2) CP(1,2)],'-','Color','g','Tag','scalebar');
        aflag = '';
        
        % Enable all buttons and toolbars
        fcn_freeze_fig('on',gcf,'Button-containing panel');
        
        % Enable selection of annotations
        set(findobj(gca,'Tag',annotype),'HitTest','on');
        
end
fclose(fid);

end
