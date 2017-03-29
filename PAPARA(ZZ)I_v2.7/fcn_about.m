function fcn_about(cversion,cdate)
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
msg = 'Program for Annotation of Photographs And Rapid Analysis';
msg = [ msg ; {'(of Zillions and Zillions) of Images'} ];
msg = [ msg ; {''} ];
msg = [ msg ; {''} ];
msg = [ msg ; {''} ];
msg = [ msg ; {'**********************'} ];
msg = [ msg ; {sprintf('PAPARA(ZZ)I v.%s (%s)',cversion,cdate)} ];
msg = [ msg ; {''} ];
msg = [ msg ; {'Created by Yann Marcon'} ];
msg = [ msg ; {sprintf('Contact: %s','yann.marcon@awi.de')} ];
msg = [ msg ; {''} ];
msg = [ msg ; {'Artwork by Autun Purser'} ];
msg = [ msg ; {sprintf('Contact: %s','autun.purser@awi.de')} ];
msg = [ msg ; {'Website: www.apillustration.co.uk'} ];
msg = [ msg ; {''} ];
msg = [ msg ; {''} ];
msg = [ msg ; {'PAPARA(ZZ)I team:'} ];
msg = [ msg ; {'- Yann Marcon (yann.marcon@awi.de)'} ];
msg = [ msg ; {'- Autun Purser (autun.purser@awi.de)'} ];
msg = [ msg ; {''} ];
msg = [ msg ; {''} ];
msg = [ msg ; {''} ];


% License
lic = '**********************';
lic = [ lic ; {'PAPARA(ZZ)I'} ];
lic = [ lic ; {['Copyright (C) 2015-',cdate(end-3:end),'  Yann Marcon and Autun Purser']} ];
lic = [ lic ; {''} ];
lic = [ lic ; {'This program is free software: you can redistribute it and/or modify'} ];
lic = [ lic ; {'it under the terms of the GNU General Public License as published by'} ];
lic = [ lic ; {'the Free Software Foundation, either version 3 of the License, or'} ];
lic = [ lic ; {'(at your option) any later version.'} ];
lic = [ lic ; {''} ];
lic = [ lic ; {'This program is distributed in the hope that it will be useful,'} ];
lic = [ lic ; {'but WITHOUT ANY WARRANTY; without even the implied warranty of'} ];
lic = [ lic ; {'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the'} ];
lic = [ lic ; {'GNU General Public License for more details.'} ];
lic = [ lic ; {''} ];
lic = [ lic ; {'You should have received a copy of the GNU General Public License'} ];
lic = [ lic ; {'along with this program.  If not, see <http://www.gnu.org/licenses/>.'} ];
lic = [ lic ; {''} ];


%%
msg = [ msg ; lic ];
msgbox(msg,'About PAPARA(ZZ)I','help','modal');


end
