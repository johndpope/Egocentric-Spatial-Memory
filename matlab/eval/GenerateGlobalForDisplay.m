clear all; close all; clc;
im = {};

W=1500;
A=32;
scale = 0.06;
tfGM = affine2d();
FW = 250;
M = zeros(W,W);
w=5;
load(['pose/poseTBWorld' num2str(w) '.mat']);
%prefixGMP = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/World' num2str(w) '/map_global/map_'];
prefixGMPR = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(w) '/map_global_all_converted/map_'];
prefixGMPR1 = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(w) '/map_global_all_converted/Mmap_'];

px = pose(:,2)/scale;
py = pose(:,3)/scale;
pw = pose(:,4); 

displayflag = 1; %1 for display; 0 for writing image

for i  =1:3027
    i
    tempM = zeros(W,W);
    
    if  displayflag == 1
    subplot(2,3,1);
    oriimgname = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld5/camera_wd/camera_' num2str(i) '.jpg'];
    oriimg = imread(oriimgname);
    oriimg = imresize(oriimg, [300 300]);
    imshow(oriimg);
    title('camera view');
%     %imwrite(imresize(oriimg,[100 100]), ['/media/mengmi/MimiDrive/Publications/NIPS_Nav/raw/local_ori_' num2str(i) '_' num2str(z) '.jpg']);
    
    subplot(2,3,2);
    oriimgname = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld5/map_global_all_converted/map_1_' num2str(i) '.jpg'];
    oriimg = imread(oriimgname);
    oriimg = imresize(oriimg, [300 300]);
    imshow(oriimg);
    hold on;
    plot(150,150, 'r*');
    hold off;
    title('GT')
    
    subplot(2,3,3);
    oriimgname = ['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld5/map_global_all_converted/Mmap_1_' num2str(i) '.jpg'];
    oriimg = imread(oriimgname);
    oriimg = imresize(oriimg, [300 300]);
    imshow(oriimg);
    hold on;
    plot(150,150, 'r*');
    hold off;
    title('GT')
    
    end
    
    load(['/media/mengmi/TOSHIBA EXT/3DGAN/IROSresults/TBworld5/predicted_ucb20g_' num2str(i) '.mat']);
    img = x;
    img = squeeze(img(1,:,:));
    
    %localM = img(122:250,186:186+128);
    localM = img(7:16,11:23); %img(1:16,8:24);
    localM = imresize(localM, [300 300]);
    
    if  displayflag == 1
    subplot(2,3,5);
    imshow(mat2gray(localM));
    title(['pred: ' num2str(i)]);
    %imagesc(img);
    %hold on;
    %plot(150,150, 'y*');
    %set(gca,'XTick',[]);
    %set(gca,'YTick',[]);
%     %title('pred with gt pose');
    hold off;
    end
    
    imwrite(mat2gray(localM), ['../results/IROSvis/local' num2str(i) '.jpg']);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%5 do my stitch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    localM = imresize(localM, [100 100]);
    localM = mat2gray(localM);
    %localM = im2bw(localM, 0.6);
    
    tform = [cos(pw(i)) -sin(pw(i)) px(i); sin(pw(i)) cos(pw(i)) py(i); 0 0 1];
    

%     subplot(2,2,4);
%     imshow(localM);
%     hold on;
%     plot(50,100,'r*');
%     hold off;
%     title('gt: local map');
    %pause;

    %recover coordinate in local map
    index = find(localM>0.5);
    val = localM(index);
    [cx,cy] = ind2sub(size(localM),index);
    cx = cx- 100;
    cy = cy - 50;    
    cx = floor(cx);
    cy = floor(cy);
    cxy = [cx cy ones(length(cx),1)];            

    %% occupied
    Gx = [];
    Gy = [];
    for k = 1: length(cx)
        temp = tform * (cxy(k,:)');
        Gx = [Gx; temp(1)];
        Gy = [Gy; temp(2)];
    end

    Gxp = ceil(Gx + W/2);
    Gyp = ceil(Gy + W/2);
    Gxy = Gxp*W + Gyp;    
    tempM(Gxy) = val;
    M = M+tempM;
    
    %M1 is used for display purpose
    M1 = M;
    M1(find(M1>=1)) = 1;
    M1 = mat2gray(M1);

    %% plot only 
    if  displayflag == 1
    subplot(2,3,6);
    imshow(imresize(mat2gray(M1),[W W]));
    hold on;
    plot(W/2,W/2,'r*');
    hold off;
    title('pred global map');
    drawnow;    
    end
    imwrite(imresize(mat2gray(M1),[W W]), ['../results/IROSvis/global' num2str(i) '.jpg']);
    %%%%%%%%%%%%%%%%%%%%%%%%%%5 done storing global %%%%%%%%%%%%%%%%%%%%%%%
    
    if  displayflag == 1
    img = imread(['/media/mengmi/TOSHIBA EXT/3DGAN/Nav3D_dataset/TBworld' num2str(5) '/map_converted/map_' num2str(i) '_1.jpg']);            
    img = imresize(img, [300 300]);
    img = mat2gray(img);
    img = im2bw(img, 0.6);
    subplot(2,3,4);
    imshow(img);
    title('map converted');
    
    pause(0.010);
     
    end
end
% filename = 'm20_gt_w10.gif'; % Specify the output file name
% nImages = 300;
% for idx = 1:nImages
%     [A,map] = rgb2ind(im{idx},256);
%     if idx == 1
%         imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.05);
%     else
%         imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.05);
%     end
% end 