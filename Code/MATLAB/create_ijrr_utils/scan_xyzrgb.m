function scan_xyzrgb(folder_dir, offset, count)

for scanIndex = offset:count

    scanName = sprintf('%s/SCANS/Scan%04d.mat',folder_dir,scanIndex);
    load(scanName);
    
    RGB = zeros(3, size(SCAN.XYZ, 2));
    
    for i = 1:5
        
        im_name = sprintf('%s/IMAGES/Cam%i/image%04d.ppm', folder_dir,i-1,SCAN.image_index); 
        I = imread(im_name);
        I = imresize(I, [1232,1616]);
        rgb = impixel(I,SCAN.Cam(i).pixels(1,:), SCAN.Cam(i).pixels(2,:));
        
        for pointIndex=1:size(SCAN.Cam(i).points_index, 2)
            
            if (all(rgb(pointIndex,:)) ~= 0 && all(RGB(:,SCAN.Cam(i).points_index(pointIndex))) == 0)
                RGB(:,SCAN.Cam(i).points_index(pointIndex)) = rgb(pointIndex, :)';
%             else
%                 RGB(:,SCAN.Cam(i).points_index(pointIndex)) = 0.5 * (RGB(:,SCAN.Cam(i).points_index(pointIndex)) + rgb(pointIndex, :)');
            end
        end
        
        %xyz = SCAN.XYZ(:, SCAN.Cam(i).points_index);
        
    end
    
    formatSpec = '%4.4f   %4.4f   %4.4f   %3d   %3d   %3d\n';
    fileId = sprintf('%s/XYZRGB/xyzrgb_%04d.txt', folder_dir, scanIndex); 
    outfile = fopen(fileId, 'w');
    fprintf(outfile, formatSpec,[SCAN.XYZ;RGB]);
    %outFile = sprintf('%s/XYZRGB/xyzrgb_%04d.mat',folder_dir,scanIndex);
    %save(outFile, 'XYZRGB');
    fclose(outfile);
    clear SCAN
    
end

end

