function [XYZ_s, x_ws, REFC] = motion_compensate_scan(Scan, Pose, Calib, dosampling, CalibIntensity)
[Pts, x_ws] = scan2world(Scan, Calib, Pose, 0);
rngc_col = reshape(Pts.rngc, size(Pts.rngc,1)*size(Pts.rngc,2), 1);
x_sw = ssc_inverse(x_ws);

%Reflectivity Calibration

uprInd = Scan.Data.uprInd;
lwrInd = Scan.Data.lwrInd;
uprN = length(uprInd);
lwrN = length(lwrInd);

for (k = 1:64) 
    if (k<33)
        
        for (rIndex = 1:uprN)
            Pts.refc(k, uprInd(rIndex)) = CalibIntensity(k, 1+Pts.refc(k, uprInd(rIndex)));
        end
        
    else
        
       for (rIndex = 1:lwrN)
            Pts.refc(k-32, lwrInd(rIndex)) = CalibIntensity(k, 1+Pts.refc(k-32, lwrInd(rIndex)));
        end
        
    end
end

% Project the scan back to sensor frame
r_s = rotxyz(x_sw(4:6));
t_s = x_sw(1:3);

 X_col = reshape(Pts.x_w, size(Pts.x_w,1)*size(Pts.x_w,2), 1);
 Y_col = reshape(Pts.y_w, size(Pts.y_w,1)*size(Pts.y_w,2), 1);
 Z_col = reshape(Pts.z_w, size(Pts.z_w,1)*size(Pts.z_w,2), 1);
 
 REFC =  reshape(Pts.refc, size(Pts.refc,1)*size(Pts.refc,2), 1);

if(dosampling)
    minRange = 800;
    maxRange = max(rngc_col) - 200;
    thresh = min(Z_col);
    temp_index = find(rngc_col(:) > minRange & rngc_col(:) < maxRange); %& Z_col(:) > thresh);
    X_col = X_col(temp_index);
    Y_col = Y_col(temp_index);
    Z_col = Z_col(temp_index);
    REFC = REFC(temp_index);
end
% Make a matrix XYZ (nPts X 3) of the points in a single frame.
% These are cordinates of points in world's reference frame as calculated
% from IMU readings.
XYZ_1 = [X_col Y_col Z_col];

XYZ_s = r_s*XYZ_1';
XYZ_s = [XYZ_s(1,:)+ t_s(1); XYZ_s(2,:)+t_s(2); XYZ_s(3,:)+t_s(3)];

end