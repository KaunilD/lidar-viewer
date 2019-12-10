function [ Db, V ] = hdl_newloaddb(filename)
%HDL_NEWLOADDB 
%   This is a new version of hdl_loaddb. hdl_loaddb used xml-toolbox which 
%   works only with Matlab 2007 and older versions.
%   DB = HDL_LOADDB(FILENAME) parses a db.xml DSR calibration file
%   specified by FILENAME and returns a Matlab data structure.
%
%   [DB,V] = HDL_LOADDB(FILENAME) returns a xml_parseany() data structure,
%   V, in addition to the DB data structure.
%
%   (c) 2016 Nikhil Mehta
%            Indian Institute of Technology, Kanpur
%            nikhilm@iitk.ac.in
%  
%-----------------------------------------------------------------
%    History:
%    Date            Who          What
%    -----------     -------      -----------------------------
%    10-26-2016      NM          Created and written.

% load and convert the DSR db.xml file to a matlab data structure using the

V = xmltools(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reorganize the raw matlab data structure into something more manageable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lidar range conversion factor
% DB Tag -> V.child(2).child(1)

V_DB = V.child(2).child(1);
Db.distLSB = str2double(V_DB.child(1).value); 

% lidar vehicle to sensor xyz offset
v = V_DB.child(2).child(1);
n = str2num(v.child(1).value);

Db.xyz = zeros(1,n);
for k=1:n
   Db.xyz(k) = str2double(v.child(k+1).value); 
end

% lidar vehicle to sensor rpy offset
v = V_DB.child(3).child(1);
n = str2num(v.child(1).value);

Db.rpy = zeros(1,n);
for k=1:n
   Db.rpy(k) = str2double(v.child(k+1).value); 
end

% lidar laser color used by DSR
v = V_DB.child(4);
n = str2num(v.child(1).value);

Db.colors = zeros(n,3);
for k=1:n
    for m=1:3
        Db.colors(k,m) = str2double(v.child(k+1).child(1).child(m+1).value);
    end
end

% lidar range enabled in DSR
v = V_DB.child(5);
n = str2num(v.child(1).value);

Db.enabled = zeros(n,1);
for k=1:n
    Db.enabled(k) = str2double(v.child(k+1).value);
end

% lidar intensity enabled in DSR
v = V_DB.child(6);
n = str2num(v.child(1).value);

Db.intensity = zeros(n,1);
for k=1:n
    Db.intensity(k) = str2double(v.child(k+1).value);
end

% lidar min intensity setting in DSR
v = V_DB.child(7);
n = str2num(v.child(1).value);

Db.minIntensity= zeros(n,1);
for k=1:n
    Db.minIntensity(k) = str2double(v.child(k+1).value);
end

% lidar max intensity setting in DSR
v = V_DB.child(8);
n = str2num(v.child(1).value);

Db.maxIntensity= zeros(n,1);
for k=1:n
    Db.maxIntensity(k) = str2double(v.child(k+1).value);
end;

% lidar calibration data
v = V_DB.child(9);
n = str2double(v.child(1).value);
Db.id = zeros(n,1);
Db.rotCorrection = zeros(n,1);
Db.vertCorrection = zeros(n,1);
Db.distCorrection = zeros(n,1);
Db.vertOffsetCorrection = zeros(n,1);
Db.horizOffsetCorrection = zeros(n,1);
for k=1:n
    Db.id(k) = str2double(v.child(k+1).child(1).child(1).value);
    Db.rotCorrection(k) = str2double(v.child(k+1).child(1).child(2).value);
    Db.vertCorrection(k) = str2double(v.child(k+1).child(1).child(3).value);
    Db.distCorrection(k) = str2double(v.child(k+1).child(1).child(4).value);
    Db.vertOffsetCorrection(k) = str2double(v.child(k+1).child(1).child(5).value);
    Db.horizOffsetCorrection(k) = str2double(v.child(k+1).child(1).child(6).value);
end