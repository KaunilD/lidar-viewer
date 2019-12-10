function [Pts x_ws J_ws] = scan2world(Scan,Calib,VehiclePose, ~)

% Vehicle pose is in local or world frame
% Local frame is X(Fwd), Y(left), Z(up) at the position where we start the
% IMU, therefore the transformation to bring the sensor frame to this local
% frame is given by
% Sensor Frame --> Vehicle Frame
% [X(Right), Y(Fwd), Z(Up)] ---> [X(Fwd), Y(Left), Z(Up)]
x_vb = [0; 0; 0; -pi; 0; 0]; %body frame to vehicle Pose frame
x_vs = ssc_head2tail (x_vb, Calib.x_vs);

t = VehiclePose.utime'*(1e-6);
[ii,jj] = findcind(t,Scan.Data.ts_iunix);
xyz = VehiclePose.pos(ii,:)';
rph = VehiclePose.rph(ii,:)';
uvw = VehiclePose.vel(ii,:)';
pqr = VehiclePose.rotation_rate(ii,:)'; % this is in local/world frame
x_wv = [xyz; rph];
x_wv_dot = [uvw; pqr];%[6 x Nshots]

% transform point cloud
[Pts] = hdl_scan2sensor(Scan,Calib);    %[32 x Nshots]

% causal linear interpolation of vehicle pose to scan times
dt = Scan.Data.ts_iunix(jj) - t(ii);
Pts.xi_wv = x_wv + repmat(dt,[6 1]).*x_wv_dot;%[6 x Nshots]
Pts.xi_ws = ssc_head2tail(Pts.xi_wv,x_vs);%[6 x Nshots]

R_ws = rotxyz(Pts.xi_ws(4,:),Pts.xi_ws(5,:),Pts.xi_ws(6,:));%[3 x 3 x Nshots]
t_ws_w = reshape(Pts.xi_ws(1:3,:),3,1,[]);                  %[3 x 1 x Nshots]

xyz_s = reshape([Pts.x_s(:), Pts.y_s(:), Pts.z_s(:)]',3,1,[]);%[3 x 1 x 32*Nshots]
xyz_w = zeros(size(xyz_s));
for k=1:32
    xyz_w(:,1,k:32:end) = multiprod(R_ws,xyz_s(:,1,k:32:end)) + t_ws_w;
end

Pts.x_w = reshape(xyz_w(1,1,:),32,[]);%[32 x Nshots]
Pts.y_w = reshape(xyz_w(2,1,:),32,[]);%[32 x Nshots]
Pts.z_w = reshape(xyz_w(3,1,:),32,[]);%[32 x Nshots]
Pts.rngc = Scan.Data.rngc;
Pts.refc = Scan.Data.refc;
Pts.x_wv = x_wv(:,1);
%Return the pose of sensor wrt first shot.
%Laser in local frame
 
[x_ws J_ws] = ssc_head2tail(x_wv(:,1),x_vs);%Pts.xi_ws(:,end);
end