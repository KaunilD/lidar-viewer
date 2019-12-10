function display_3D_pointcloud(folder, scanIndex, varargin)
%% This function renders the 3D pointcloud of the scans in a MATLAB figure window
% Input-:
% folder-: Directory where the dataset is unzipped. This folder should have
% the folders SCANS, IMAGES, LCM, VELODYNE
% scanIndex-: Index of the scan to be displayed
% displayMode:- displayMode (Defaults to 1) can take values 1, 2 or 3
% 1 for simply displaying the pointCloud
% 2 for displaying it in grey scale on the basis of reflectivity
% 3 for displaying it on the basis of z-index of points

%Get the name of scan
scanName = sprintf('%s/SCANS/Scan%04d.mat',folder,scanIndex);

%load the scan
load(scanName);

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

displayMode = 1;
if (nargin > 2)
    displayMode = varargin{1};
end

if (displayMode == 1)
    
    %set color of the pointcloud to be 'red'
    set(axe,'ColorOrder',[1 0 0]);
    lasersAll = plot3(ones(1,3),ones(1,3),ones(1,3),'.');
    set(lasersAll,'MarkerSize',1);

    set(lasersAll,'Visible','on');

    %set the data 
    set(lasersAll(1),'Xdata', SCAN.XYZ(1,:),...
        'Ydata', SCAN.XYZ(2,:),...
        'Zdata', SCAN.XYZ(3,:));

    
elseif (displayMode == 2)

    % With Reflectivity
    [refc,ii] = sort(SCAN.reflectivity(:));

    X = SCAN.XYZ(1,:);
    X = X(ii);
    Y = SCAN.XYZ(2,:);
    Y = Y(ii);
    Z = SCAN.XYZ(3,:);
    Z = Z(ii);

    jj = find(diff(refc));
    uref = refc(jj); % unique reflectivity values

    set(axe,'ColorOrder',gray(256));
    lasersAll = plot3(ones(2,256),ones(2,256),ones(2,256),'.');
    
    set(lasersAll,'MarkerSize',1);
    set(lasersAll,'Visible','off');

    for k = 1:length(uref)
        if k > 1
            ind = jj(k-1)+1:jj(k);
        else
            ind = 1:jj(1);
        end
    
        set(lasersAll(uref(k)),'Visible','on');
        set(lasersAll(uref(k)),...
            'Xdata', X(ind),'Ydata', Y(ind),'Zdata', Z(ind));
    
    end

else
    
    set(axe,'ColorOrder',hsv(35));
    lasersAll = plot3(ones(2,35),ones(2,35),ones(2,35),'.');
    set(lasersAll,'MarkerSize',1);
    set(lasersAll,'Visible','off');
    
    x_1 = deal(SCAN.XYZ(1,:));
    y_1 = deal(SCAN.XYZ(2,:));
    z_1 = deal(SCAN.XYZ(3,:));
                
    [range, ii] = sort(z_1(:));
    x = x_1(ii);
    y = y_1(ii);
    z = z_1(ii);

    ii = find(z > -3);
    x = x(ii);
    y = y(ii);
    z = z(ii);
    
    jj = find(diff(z));
    len = length(jj);
    urange = range(jj); % unique z values values
    l = length(urange);
    n = floor(l/35);
    lower_bound = -3;
    upper_bound = -2.8;
    
    set(lasersAll,'Visible','off');
    for k = 1:35
        
        ind = find(z < upper_bound & z > lower_bound);
        lower_bound = upper_bound;
        disp(length(ind))
        upper_bound = upper_bound + 0.2;
        
        set(lasersAll(k),'Visible','on');
        set(lasersAll(k),...
            'Xdata', x(ind),'Ydata', y(ind),'Zdata', z(ind));
    end
    
end
    
 

end