function display_multiple_3D_scans_intensity(folder, scanId, numScans, offset)

% check if numScans + offset exists in SCAN folder
dbFile = sprintf('db.xml');

% getting sensor to vehicle transformation
Db = hdl_newloaddb(dbFile);
Calib = hdl_lasergeom(Db);

%initialize the figure window
fig = figure(...
    'Name','3D Pointcloud',...
    'NumberTitle','off',...
    'IntegerHandle','off',...
    'Units','normalized',...
    'Position',[0.2 0.1 0.6 0.7],...
    'Visible','on',...
    'Toolbar','figure',...
    'Tag','hdl_player');

whitebg(fig,'black');
cameratoolbar(fig,'show');
cameratoolbar('SetMode','orbit');

% setup axis for animation
axe = gca;
set(axe,...
    'NextPlot','replaceChildren',...
    'Projection','perspective');
grid(axe,'off');
axis(axe,'xy');
axis(axe,'vis3d');
set(axe,...
    'XTickLabelMode','manual','XTickLabel','',...
    'YTickLabelMode','manual','YTickLabel','',...
    'ZTickLabelMode','manual','ZTickLabel','');

set(axe,'ColorOrder',gray(256));
lasersAll = plot3(ones(2,256),ones(2,256),ones(2,256),'.');

set(lasersAll,'MarkerSize',1);
set(lasersAll,'Visible','off');

TOTAL_POINTS = [];
REFC = [];

% Code
for (k = scanId:offset:numScans+scanId)
    
    scanName = sprintf('%s/SCANS/Scan%04d.mat', folder, k)
    load(scanName);
    
    if (k == scanId)
        X_sw_ref = ssc_inverse(SCAN.X_ws);
        TOTAL_POINTS = SCAN.XYZ;
        REFC = SCAN.reflectivity;
    else
        
        % transform all the points to X_ws_ref
        [X_S1S2, J] = ssc_head2tail(X_sw_ref, SCAN.X_ws);
        r_S1S2 = rotxyz(X_S1S2(4), X_S1S2(5), X_S1S2(6)); % 3X3
        t_S1S2 = X_S1S2(1:3); % 3X1
        
        t = repmat(t_S1S2, 1, size(SCAN.XYZ, 2));
        XYZ = r_S1S2 * SCAN.XYZ + t;
        TOTAL_POINTS = [TOTAL_POINTS XYZ];
        REFC = [REFC;SCAN.reflectivity];
        
    end
 end

 % With Reflectivity 
 X = TOTAL_POINTS(1,:);
 Y = TOTAL_POINTS(2,:);
 Z = TOTAL_POINTS(3,:);
 
 for k = 1:256
     
     ind = find(REFC == (k-1));
     set(lasersAll((k)),'Visible','on');
     set(lasersAll((k)),...
         'Xdata', X(ind),'Ydata', Y(ind),'Zdata', Z(ind));
     
 end
 
end


