% Script for quantitative analysis of foci on a single image
% This script is designed to analyze foci in a single image, the folder should
% contain a composite of three 8-bit, single-channel, maximum projections in .tif format.
% The output is a .csv file containing a table with foci data.

% Before running the script:
% 1. Ensure you have three 8-bit, single-channel, maximum projection images in .tif format.
% 2. Adjust the 'pxSize' variable with the appropriate pixel size for the image.
% 3. Manually delineate the ROIs (cells) in the image using the 'CROIEditor' function.

% Note:
% - The 'mergeAndAdjustImages' function should be defined to merge and adjust the three channels.
% - The 'CROIEditor' function is used for manual delineation of ROIs (cells).
% - The 'watershedWithMarkers' function performs watershed transform.

% Authors:
% Colette Emery (2022)
% Julia Garcia Baucells (2023)

close all
clc
clear

pxSize = 9.2733; % ?

% Load, merge & adjust brightness & contrast for the 3 channels
adjustedImage = mergeAndAdjustImages();

% ROI all cells - manual delineation of each cell
roiwindow = CROIEditor(adjustedImage);
waitfor(roiwindow,'roi');
if ~isvalid(roiwindow)
    disp('You closed the window without applying ROI');
    return
end
[mask, labels, n] = roiwindow.getROIData;
delete(roiwindow);

% Input results file name & select images
data_conditions = input('Enter condition type: ', 's');

FolderName = cd;
if exist([cd(FolderName),'/' data_conditions]) == 7
    % do nothing
else
    mkdir(data_conditions);
    disp('Results folder created')
end
ResultsPath =([FolderName,'/', data_conditions]);

% Create an empty table to store foci data
fociData = table('Size', [0, 10], ...
    'VariableNames', {'Image', 'Cell', 'CellArea', 'CellBackgroundIntensity', 'x', 'y', 'FociArea', 'MaxIntensity', 'MeanIntensity', 'FociIntegratedIntensity'}, ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double'});
num_foci_total = 0; 

%% Analysis

% Load in .png image previously thresholded using Ilastik
[file_list, path_n] = uigetfile('.png', 'Select file');
count = 0;
if iscell(file_list) == 0
    file_list = (file_list);
end
filename = file_list;
data_in = imread([path_n filename]);
disp(['Image' file_list] )
filename = convertCharsToStrings(filename);
fullImage = data_in; fullImage(fullImage>0) = 1;
binImage = ~fullImage; binImage = 1-binImage; binImage = (binImage == 0);

% Loops through each ROI(cell) for data
for i = 1:n
    soloMask = (labels==i);
    solo = double(binImage).*double(soloMask);
    close all
    %     figure(); imshow(solo)

    % Watershed transform
    min_distance_threshold = 1;
    area_threshold = 3;
    segmented_image = watershedWithMarkers(solo, min_distance_threshold, area_threshold);
    %     figure(); imshow(segmented_image)

    count = count + 1; % cell count

    CC2 = bwconncomp(segmented_image,4);
    labelfoci = labelmatrix(CC2); % Labels each foci in selected cell

    folder_path = cd;
    [imageQ, imageQ_name] = loadSingleTiffWithoutKeywords(folder_path);
    fociIntensityImage = segmented_image.*double(imageQ);

    % Extracting foci data
    fociProps = regionprops(labelfoci, fociIntensityImage, {'Area', 'Centroid', 'MaxIntensity', 'MeanIntensity', 'PixelValues'});
    num_foci = length(fociProps);
    num_foci_total = num_foci_total + num_foci;

    % Check if fociProps is empty (no foci detected in the cell)
    if isempty(fociProps)
        continue; % Skip this cell and proceed to the next one
    end

    % Calculate the area of the cell from the soloMask
    cellArea = sum(soloMask(:)) * pxSize^2; % in square micrometers

    % Calculate the background intensity of the cell (excluding foci regions)
    cellBackgroundIntensity = mean(imageQ(soloMask & ~segmented_image));

    % Assign foci data to a temporary table for this cell
    cellFociData = table(...
        repmat(filename, num_foci, 1), ... % Image
        ones(num_foci, 1) * i, ...         % Cell
        ones(num_foci, 1) * cellArea, ...  % CellArea
        ones(num_foci, 1) * cellBackgroundIntensity, ... % CellBackgroundIntensity
        cell2mat(arrayfun(@(x) x.Centroid(1), fociProps, 'UniformOutput', false)), ... % x
        cell2mat(arrayfun(@(x) x.Centroid(2), fociProps, 'UniformOutput', false)), ... % y
        [fociProps.Area]'*pxSize^2, ...   % FociArea
        [fociProps.MaxIntensity]', ...    % MaxIntensity
        [fociProps.MeanIntensity]', ...   % MeanIntensity
        cellfun(@(x) sum(x(:)), {fociProps.PixelValues})' ... % FociIntegratedIntensity
        );

    % Set the variable names of cellFociData to match fociData
    cellFociData.Properties.VariableNames = fociData.Properties.VariableNames;

    % Append the temporary table to the main fociData table
    fociData = [fociData; cellFociData];

    figure(); imagesc(fociIntensityImage); axis image; c = colorbar; axis off
    c.Label.String = 'Fluorescence intensity [a.u.]'; set(gca,'FontSize', 12)
    c.Label.Rotation = 270; c.Label.VerticalAlignment = "bottom"; c.Label.FontSize = 12; 
    pause(1.5)
    close()
end

% Save the foci data table to CSV
cd(ResultsPath);
writetable(fociData, [data_conditions '_Focidata.csv']);
