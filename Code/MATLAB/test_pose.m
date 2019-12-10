Pose = load_pose_applanix('/home/gaurav/Desktop/IJRR-Code/IJRR-Dataset-1-subset/Pose-Applanix.log')

X_wv1 = [Pose.pos(1,:), Pose.rph(1,:)];
X_v1v2 = zeros(length(Pose.utime), 6);
for i = 2:length(Pose.utime)
    X_wv2 = [Pose.pos(i,:), Pose.rph(i,:)];
    X_v1v2(i,:) = ssc_tail2tail(X_wv1', X_wv2');
end

subplot (1, 3, 1); plot (X_v1v2(:,1), X_v1v2(:, 2), '*')
subplot (1, 3, 2); plot(X_v1v2(:,1), '*');
subplot (1, 3, 3); plot(X_v1v2(:,2), 'o');