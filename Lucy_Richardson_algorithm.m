Step 1: Read Image
I = imread('board.tif');
I = I(50+(1:256),2+(1:256),:);
figure;
imshow(I);
title('Original Image');
text(size(I,2),size(I,1)+15, ...
    'Image courtesy of courtesy of Alexander V. Panasyuk, Ph.D.', ...
    'FontSize',7,'HorizontalAlignment','right');
text(size(I,2),size(I,1)+25, ...
    'Harvard-Smithsonian Center for Astrophysics', ...
    'FontSize',7,'HorizontalAlignment','right');

Step 2: Simulate a Blur and Noise

PSF = fspecial('gaussian',5,5);
Blurred = imfilter(I,PSF,'symmetric','conv');
figure;
imshow(Blurred);
title('Blurred');
V = .002;
BlurredNoisy = imnoise(Blurred,'gaussian',0,V);
figure;
imshow(BlurredNoisy);
title('Blurred & Noisy');

Step 3: Restore the Blurred and Noisy Image

luc1 = deconvlucy(BlurredNoisy,PSF,5);
figure;
imshow(luc1);
title('Restored Image, NUMIT = 5');

Step 4: Iterate to Explore the Restoration

luc1_cell = deconvlucy({BlurredNoisy},PSF,5);
luc2_cell = deconvlucy(luc1_cell,PSF);
luc2 = im2uint8(luc2_cell{2});
figure;
imshow(luc2);
title('Restored Image, NUMIT = 15');

Step 5: Control Noise Amplification by Damping

DAMPAR = im2uint8(3*sqrt(V));
luc3 = deconvlucy(BlurredNoisy,PSF,15,DAMPAR);
figure;
imshow(luc3);
title('Restored Image with Damping, NUMIT = 15');

Step 6: Create Sample Image

I = zeros(32);
I(5,5) = 1;
I(10,3) = 1;
I(27,26) = 1;
I(29,25) = 1;
figure;
imshow(1-I,[],'InitialMagnification','fit');
ax = gca;
ax.Visible = 'on';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.XTick = [7 24];
ax.XGrid = 'on';
ax.YTick = [5 28];
ax.YGrid = 'on';
title('Data');

Step 7: Simulate a Blur

PSF = fspecial('gaussian',15,3);
Blurred = imfilter(I,PSF,'conv','sym');

WT = zeros(32);
WT(6:27,8:23) = 1;
CutImage = Blurred.*WT;

CutEdged = edgetaper(CutImage,PSF);
figure;
imshow(1-CutEdged,[],'InitialMagnification','fit');
ax = gca;
ax.Visible = 'on';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.XTick = [7 24];
ax.XGrid = 'on';
ax.YTick = [5 28];
ax.YGrid = 'on';
title('Observed');

Step 8: Provide the WEIGHT Array

luc4 = deconvlucy(CutEdged,PSF,300,0,WT);
figure;
imshow(1-luc4,[],'InitialMagnification','fit');
ax = gca;
ax.Visible = 'on';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.XTick = [7 24];
ax.XGrid = 'on';
ax.YTick = [5 28];
ax.YGrid = 'on';
title('Restored');

Step 9: Provide a finer-sampled PSF

Binned = squeeze(sum(reshape(Blurred,[2 16 2 16])));
BinnedImage = squeeze(sum(Binned,2));
Binned = squeeze(sum(reshape(PSF(1:14,1:14),[2 7 2 7])));
BinnedPSF = squeeze(sum(Binned,2));
figure;
imshow(1-BinnedImage,[],'InitialMagnification','fit');
ax = gca;
ax.Visible = 'on';
ax.XTick = [];
ax.YTick = [];
title('Binned Observed');

luc5 = deconvlucy(BinnedImage,BinnedPSF,100);
figure;
imshow(1-luc5,[],'InitialMagnification','fit');
ax = gca;
ax.Visible = 'on';
ax.XTick = [];
ax.YTick = [];
title('Poor PSF');
luc6 = deconvlucy(BinnedImage,PSF,100,[],[],[],2);
figure;
imshow(1-luc6,[],'InitialMagnification','fit');
ax = gca;
ax.Visible = 'on';
ax.XTick = [];
ax.YTick = [];
title('Fine PSF');