files = dir("C:\Users\dhruv\Development\git\lidar-viewer\Code\IJRR-Dataset-1-subset\SCANS\*.mat");
for idx = 1:length(files)
    disp(strcat(files(idx).folder, '\', files(idx).name))
    data = load(strcat(files(idx).folder, '\', files(idx).name))
    struct2csv(data.SCAN, strcat(files(idx).name, '.csv'))
end