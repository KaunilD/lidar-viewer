function create_ijrr_dataset(folder_out, numFiles)
%% This function creates the data set as mentioned in the paper
tic
offset = 0;
dbFile = 'db.xml';
timestampLog = [folder_out '/Timestamp.log'];
poselog = [folder_out '/Pose-Applanix.log'];

%if pose log is present
Pose = load_pose_applanix(poselog);

paramFile = sprintf('%s/PARAM.mat',folder_out);
load(paramFile);

intensityCalibFile = sprintf('%s/intensity_calibration.conf',folder_out);
%load(intensityCalibFile);

Db = hdl_newloaddb(dbFile);
Calib = hdl_lasergeom(Db);
% read timestamp file
fptr = fopen(timestampLog, 'r');
tline = fgetl(fptr)
%timestamp_matrix = fscanf(fptr, '%d %g', [2 inf]); % [frameNumber timeStamp]
timestamp_matrix = fscanf(fptr, '%d %g %g %g', [4 inf]); % [frameNumber timeStamp]
fclose(fptr);

fptr = fopen(intensityCalibFile, 'r');
CalibIntensity = fscanf(fptr, '%d', [256, 64])';
fclose(fptr);

for fileIndex = 0:numFiles-1

    pcapFile = sprintf('%s/VELODYNE/velodyne-data-%02d.pcap', folder_out, fileIndex);
    
    [M, GlobalHeader] = hdl_fopenpcap(pcapFile);
    Scan = hdl_fgetscan(M,1,'bof');
    start_index = 1;
    end_index = Scan.Meta.K;
    
    numScans = start_index - end_index + 1;

    i = 1;
    for p = start_index:end_index
        Scan = hdl_fgetscan(M,p,'bof');
        j = 1;
        Laser_timestamp(i) = Scan.Data.ts_iunix(1)*1e6; %it was "end"
        i = i+1;
    end

    n = size(timestamp_matrix,2);
    deltat = 0.085*ones(1,n);
    timestamp_camera2 = timestamp_matrix(3,:) - deltat*1e6;
    [ii,jj] = findcind(timestamp_camera2, Laser_timestamp);

    fprintf(' The corresponding camera frames are -: \n');
    %Frame_Number = ii
    Frame_Number = [ones(jj(1)-1,1); ii];
    n = length(ii);

    scanStartIndex = start_index + offset;
    scanEndIndex = end_index + offset;
    i = 1;
    for scanindex = scanStartIndex:scanEndIndex
        Scan1 = hdl_fgetscan(M,scanindex - offset,'bof');
        im_index = Frame_Number(i);
        [XYZ_l, x_ws, REFC] = motion_compensate_scan(Scan1, Pose, Calib, 1, CalibIntensity);
        SCAN.XYZ = XYZ_l;
        SCAN.reflectivity = REFC;
        SCAN.timestamp_laser = Laser_timestamp(i);
        SCAN.timestamp_camera = timestamp_camera2(im_index);
        SCAN.image_index = im_index;
        SCAN.X_ws = x_ws;
        
        % interpolation for camera
        [ii_pose,jj_pose] = findcind(Pose.utime,timestamp_camera2(im_index));
        diff_time = (timestamp_camera2(im_index) - Pose.utime(ii_pose))*(1e-6);
        xyz = Pose.pos(ii_pose,:)';
        rph = Pose.rph(ii_pose,:)';
        uvw = Pose.vel(ii_pose,:)';
        pqr = Pose.rotation_rate(ii_pose,:)';
        xyz = xyz + diff_time.*uvw;
        rph = rph + diff_time.*pqr;
        x_wv = [xyz;rph]; %vehicle pose in world/local refrence frame when the image was captured
        SCAN.X_wv = x_wv;
        
        for camindex = 0:4

            R = PARAM(camindex+1).R;
            t = PARAM(camindex+1).t;
            K = PARAM(camindex+1).K;
            pointcloud = [SCAN.XYZ' ones(size(SCAN.XYZ,2),1)];
            points_in_camera_ref = [R t] * pointcloud';

            points_infront_cam = find(points_in_camera_ref(3,:) > 0);
            pointcloud = pointcloud(points_infront_cam,:);
            points_in_camera_ref = points_in_camera_ref(:,points_infront_cam);
            %K(2,3) = K(2,3)/2; %for half res images ([1616 x 616])
            %K(2,2) = K(2,2)/2;
            %K
            image_points = K * [R t] * pointcloud';
            tempX = image_points(1,:)./ image_points(3,:);
            tempY = image_points(2,:)./ image_points(3,:);

            index = find((tempX(1,:) > 1) & (tempX(1,:) < 1616) & (tempY(1,:) > 1) & (tempY(1,:) < 1232));
            tempX = tempX(index);
            tempY = tempY(index);
            pixels = [tempX' tempY'];

            SCAN.Cam(camindex+1).points_index = points_infront_cam(index); %These are the points in XYZ that belong to this camera
            SCAN.Cam(camindex+1).xyz = points_in_camera_ref(:,index);
            SCAN.Cam(camindex+1).pixels = pixels';

            clear pointcloud point_in_camera_ref;
        end
        
        outFile = sprintf('%s/SCANS/Scan%04d.mat',folder_out,scanindex)
        save(outFile, 'SCAN');
        
        clear SCAN
        fclose('all');
        i = i + 1;
    end
    offset = offset + Scan.Meta.K;
    clear M;
    toc
end
end
