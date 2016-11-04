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
n = str2double(get(h_val,'String'));
aflag = '';
im = [];
loopn = 1;
if exist('ninc','var')~=1, ninc = 0; end
switch isempty(filterlist)
    case 1 % normal behavior
        nold = n;
        while n + ninc >= 1 && n + ninc <= nmax && exist(im,'file')~=2
            n = n + ninc;
            im = [inpath imagelist{n}];
        end
        if n < 1 || n > nmax || exist(im,'file')~=2
            n = nold;
            im = [];
        end
        
    case 0
        % Disable all buttons and toolbars of the GUI (to prevent double-clicks)
        fcn_freeze_fig('off',gcf,'Button-containing panel');
        drawnow;

        if ninc == 0
            im = [inpath imagelist{n}];
        else
            nold = n;
            while isempty(im) && exist(im,'file')~=2 && n + ninc >= 1 && n + ninc <= nmax
                n = n + ninc;
                if n < 1 || n > nmax || exist([inpath imagelist{n}],'file')~=2, continue; end % check if image exists
                
                if exist('fid','var')==1 && ~isempty(fopen(fid)), fclose(fid); end;
                
                % Get image dimensions
                infostr = imfinfo([inpath imagelist{n}]);
                imw = infostr.Width;
                imh = infostr.Height;
                
                % Read existing annotations
                [~,iname,~] = fileparts(imagelist{n});
                hToolbar = findall(gcf,'Tag','FigureToolBar');
                hPoints  = findobj(hToolbar,'Tag','Toolbar_Points');
                onoff = get(hPoints,'State');
                switch onoff
                    case 'on' % display generated points
                        pointpath = [inpath userid '_generatedpoints' sep];
                        txtfile = sprintf('%s%s_%lix%li_%li%s.txt',pointpath,iname,imw,imh,pointmax,pointtype);
                        
                    case 'off' % display annotations
                        annopath = [inpath userid '_annotations' sep];
                        txtfile = sprintf('%s%s_%lix%li.txt',annopath,iname,imw,imh);
                        
                end
                fid = fopen(txtfile,'r');
                
                strlist = {};
                if fid ~= -1
                    while ~feof(fid)
                        tline = fgetl(fid);
                        if tline ~= -1
                            strline = textscan(tline,'%s', 'delimiter', '\t');
                            
                            if ismember(strline{1}(3),filterlist)==1 || ...
                                    ( ismember('Filter keywords that are not in this list',filterlist)==1 && ...
                                    ismember(strline{1}(3),kwlist)==0 )
                                im = [inpath imagelist{n}];
                                break;
                            end
                        end
                    end
                    fclose(fid);
                end
                clear fid
            end
            
            if isempty(im)
                n = nold;
                im = [inpath imagelist{n}];
                msg = sprintf('%s','No further selected keywords found. Turn the filter off.');
                h_msg = msgbox(msg,'Selected keywords not found','modal');
                uiwait(h_msg);
                drawnow; pause(1); % prevents dialog box from freezing
            end
            
        end
        
        % Enable all buttons and toolbars of the GUI
        fcn_freeze_fig('on',gcf,'Button-containing panel');
end

ninc = 0; % reset n-increment
set(h_val,'String',n);
if exist('fid','var')==1 && ~isempty(fopen(fid)), fclose(fid); clear('fid'); end;
switch get(hPoints,'State')
    case 'off'
        [him,fid,sc,annotype,rectfile] = fcn_disp_image(n,imagelist,inpath,h,h_sc,h_ds,h_ppi,dsflag,aflag,...
            userid,sep,kwlist,filterlist,infotxt);
    case 'on'
        [him,fid,sc,annotype,rectfile] = fcn_disp_image(n,imagelist,inpath,h,h_sc,h_ds,h_ppi,dsflag,aflag,...
            userid,sep,kwlist,filterlist,infotxt,pointtype,pointmax);
end
[selec,fid] = list_callback(fid,hlist,him,infotxt,annotype);