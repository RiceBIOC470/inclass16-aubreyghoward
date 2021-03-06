% Inclass16
clear all
x = 1
%GB comments
1 100
2 100
3 100 
overall 100


%The folder in this repository contains code implementing a Tracking
%algorithm to match cells (or anything else) between successive frames. 
% It is an implemenation of the algorithm described in this paper: 
%
% Sbalzarini IF, Koumoutsakos P (2005) Feature point tracking and trajectory analysis 
% for video imaging in cell biology. J Struct Biol 151:182?195.
%
%The main function for the code is called MatchFrames.m and it takes three
%arguments: 
% 1. A cell array of data called peaks. Each entry of peaks is data for a
% different time point. Each row in this data should be a different object
% (i.e. a cell) and the columns should be x-coordinate, y-coordinate,
% object area, tracking index, fluorescence intensities (could be multiple
% columns). The tracking index can be initialized to -1 in every row. It will
% be filled in by MatchFrames so that its value gives the row where the
% data on the same cell can be found in the next frame. 
%2. a frame number (frame). The function will fill in the 4th column of the
% array in peaks{frame-1} with the row number of the corresponding cell in
% peaks{frame} as described above.
%3. A single parameter for the matching (L). In the current implementation of the algorithm, 
% the meaning of this parameter is that objects further than L pixels apart will never be matched. 

% Continue working with the nfkb movie you worked with in hw4. 

% Part 1. Use the first 2 frames of the movie. Segment them any way you
% like and fill the peaks cell array as described above so that each of the two cells 
% has 6 column matrix with x,y,area,-1,chan1 intensity, chan 2 intensity

reader = bfGetReader('nfkb_movie1.tif');
z = 1; c = 1; t = 1;

ind = reader.getIndex(z-1,c-1,t-1)+1;
frameT1_C1 = bfGetPlane(reader,ind);
imwrite(frameT1_C1,'nfkb_Frame1_C1.tif','tif');
ind = reader.getIndex(z-1,c,t-1)+1;
frameT1_C2 = bfGetPlane(reader,ind);
imwrite(frameT1_C2,'nfkb_Frame1_C2.tif','tif');
ind = reader.getIndex(z-1,c-1,t)+1;
frameT2_C1 = bfGetPlane(reader,ind);
imwrite(frameT2_C1,'nfkb_Frame2_C1.tif','tif');
ind = reader.getIndex(z-1,c,t)+1;
frameT2_C2 = bfGetPlane(reader,ind);
imwrite(frameT2_C2,'nfkb_Frame2_C2.tif','tif');


%mask generation performed in ilastik


masks = readIlastikFile('nfkb_Frame1_Simple Segmentation.h5');
maskT1 = masks(:,:,1);
masks = readIlastikFile('nfkb_Frame2_Simple Segmentation.h5');
maskT2 = masks(:,:,1);

%Check the cell populaiton via histogram
cellstats = regionprops(maskT1,'area');
%figure(1);hist([cellstats.Area],40);
%xlabel('Cell Area','FontSize',24);ylabel('Frequency','FontSize',24);

%Cell size is most likely greater than 500 pixels. 
minarea = 500;
maskT1 = imfill(maskT1,'holes');
maskT1 = bwareaopen(maskT1,minarea);
maskT2 = imfill(maskT2,'holes');
maskT2 = bwareaopen(maskT2,minarea);
%x = x+1;figure(x);imshowpair(maskT1,maskT2);%used to check cell overlap

stats1 = regionprops(maskT1, frameT1_C1, 'Centroid','area','Meanintensity');
stats1_C2 = regionprops(maskT1, frameT1_C2, 'Meanintensity');
stats2 = regionprops(maskT2, frameT2_C1, 'Centroid','area','Meanintensity');
stats2_C2 = regionprops(maskT2, frameT2_C2, 'Meanintensity');

xy1 = cat(1,stats1.Centroid);
a1 = cat(1,stats1.Area);
avgInt1 = cat(1,stats1.MeanIntensity);
avgInt1_C2 = cat(1,stats1_C2.MeanIntensity);
tmp = -1*ones(size(a1));
peaks{1} = [xy1, a1, tmp, avgInt1,avgInt1_C2];

xy2 = cat(1,stats2.Centroid);
a2 = cat(1,stats2.Area);
avgInt2 = cat(1,stats2.MeanIntensity);
avgInt2_C2 = cat(1,stats2_C2.MeanIntensity);
tmp = -1*ones(size(a2));
peaks{2} = [xy2, a2, tmp, avgInt2,avgInt2_C2];


% Part 2. Run match frames on this peaks array. ensure that it has filled
% the entries in peaks as described above. 

PeaksMatched = MatchFrames(peaks,2,50);

% Part 3. Display the image from the second frame. For each cell that was
% matched, plot its position in frame 2 with a blue square, its position in
% frame 1 with a red star, and connect these two with a green line. 
figure(2);imshow(frameT2_C1,[]); hold on;
c = 'r*';
i = 1 ;
for ii = 1:length(PeaksMatched{i})
        if PeaksMatched{i}(ii,4) > 0
            PeakSpot = PeaksMatched{i}(ii,4);
            %PeakSpot = ii;
            PlottedPeaks{1}(PeakSpot,:) = [PeaksMatched{i}(ii,1:2)];
            plot(PeaksMatched{i}(ii,1),PeaksMatched{i}(ii,2),...
                c,'MarkerSize',15);
            hold on;
        end
end


c = 'bs';
i = 2;
for ii = 1:length(PeaksMatched{i})
           PlottedPeaks{i}(ii,:) = [PeaksMatched{i}(ii,1),PeaksMatched{i}(ii,2)];
            plot(PeaksMatched{i}(ii,1),PeaksMatched{i}(ii,2),...
                c,'MarkerSize',15);
            hold on;
end


for ii = 1:length(PeaksMatched{1})
    if sum(PlottedPeaks{1}(ii,1:2)) > 0
    plot([PlottedPeaks{1}(ii,1),PlottedPeaks{2}(ii,1)],[PlottedPeaks{1}(ii,2),PlottedPeaks{2}(ii,2)],'-g','LineWidth',1);
    hold on;
    end
end
hold off;
