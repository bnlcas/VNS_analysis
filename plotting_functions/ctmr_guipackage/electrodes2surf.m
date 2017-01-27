function [out_els,out_els_ind]=electrodes2surf(subject,index,checkdistance,elecselection,elecfname,gsfname,mrfname)
% function
% [out_els,out_els_ind]=electrodes2surf(subject,index,checkdistance,elecselection)
% [out_els,out_els_ind]=electrodes2surf(subject,index,checkdistance,elecselection,elecfname,gsfname)

% input:
% subject - for saving
% index - 
    % 0 fo global
    % other for nr of electrodes for local 
% checkdistance - 
    % 0, always project, 
    % 1 - if electrode within 2 mm of mask, do not project
    % 2 - for strips, project all to closest distance
% electselection - selection of the electrodes in els [0] for all
% elecfname - if not specified select with spmselect - otherwise string: /data/blabla.mat
% gsfname - if not specified select with spmselect - otherwise string: /data/blabla.img
%
%
% select graymatter and electrodes file (generated by electSelect)
% uses p_zoom for plotting electrodes on surface
% returns out_els from p_zoom and genarates img and hdr with electrodes on
% surface

%     Copyright (C) 2009  D. Hermes & K.J. Miller, Dept of Neurology and Neurosurgery, University Medical Center Utrecht
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
%   Version 1.1.0, released 26-11-2009

%load .mat file with electrode positions
if ~exist(elecfname)
    [data.elecName]=spm_select(1,'mat','select .mat file with electrode positions');
    %load gray matter surface
    [data.gsName]=spm_select(1,'image','select image with gray matter surface');
else
    data.elecName=elecfname;
    data.gsName=gsfname;
end

data.elecs=load(data.elecName);
els=data.elecs.elecmatrix;

if elecselection>0
    els=els(elecselection,:);
end

data.gsStruct=spm_vol(data.gsName);
% from structure to data matrix and xyz matrix (voxel coordinates)
data.gs=spm_read_vols(data.gsStruct);
[x,y,z]=ind2sub(size(data.gs),find(data.gs>0)); 
% from indices 2 native
gs=([x y z]*data.gsStruct.mat(1:3,1:3)')+repmat(data.gsStruct.mat(1:3,4),1,length(x))'; 

clear x y z;

out_els=p_zoom(els,gs,index,checkdistance);
% data.gs=[];
% data.gsStruct=[];
% data.gsName=[];
% clear gs;

disp('electrode projected, now putting back in image');

% put back in image:
if ~exist(mrfname)
    [datawithnewelec,out_els,out_els_ind]=position2reslicedImage(out_els);
else
    [datawithnewelec,out_els,out_els_ind]=position2reslicedImage(out_els,mrfname);
end

data.newelec=datawithnewelec;
clear datawithnewelec;

%% -------------------------------------------
% and save new data:
dataOut=data.gsStruct;
%outputdir= spm_select(1,'dir','select output directory');
outputdir=['./RW/'];
for filenummer=1:100
    outputnaam=strcat([outputdir subject '_electrodesOnsurface' int2str(filenummer)...
        '_' int2str(index) '.img']);
    dataOut.fname=outputnaam;

    if ~exist(dataOut.fname,'file')>0
        disp(strcat(['saving ' outputnaam]));
        % save the data
        spm_write_vol(dataOut,data.newelec);
        save(outputnaam(1:end-4),'out_els');
        break
    end
end
