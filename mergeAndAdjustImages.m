function [adjustedImage] = mergeAndAdjustImages()

% Read the names of the .tif files in the folder
files = dir('*.tif');

% Check if there are exactly three .tif files in the folder
if numel(files) ~= 3
    error('There should be exactly three .tif files in the folder.');
end

% Load the images
image1 = imread(files(1).name);
image2 = imread(files(3).name);
image3 = imread(files(2).name);

% Check if the images are of the same size
if ~isequal(size(image1), size(image2), size(image3))
    error('Images must be of the same size.');
end

% Create a blank image to store the merged result
mergedImage = cat(3, image1, image2, image3);

% Display the merged image with an initial brightness and contrast
initialBrightness = 0;
initialContrast = 1;
adjustedImage = adjustBrightnessAndContrast(mergedImage, initialBrightness, initialContrast);
hFig = imshow(adjustedImage);
title('Merged Image with Manual Brightness and Contrast Adjustment');

% Continue adjusting until the user clicks "Apply"
while true
    % Create a dialogue box for the user to adjust brightness and contrast
    prompt = {'Enter brightness (integer from -255 to 255):', 'Enter contrast (float value greater than 0):'};
    dlgTitle = 'Brightness and Contrast Adjustment';
    numLines = 1;
    defaultValues = {num2str(initialBrightness), num2str(initialContrast)};
    userInput = inputdlg(prompt, dlgTitle, numLines, defaultValues);

    % Extract user input for brightness and contrast
    newBrightness = str2double(userInput{1});
    newContrast = str2double(userInput{2});

    % Apply the user-defined brightness and contrast to the merged image
    adjustedImage = adjustBrightnessAndContrast(mergedImage, newBrightness, newContrast);

    % Display the intermediate image with the current brightness and contrast
    set(hFig, 'CData', adjustedImage);
    title('Intermediate Image with Current Brightness and Contrast');

    % Check if the user clicked "Apply" or "Discard"
    option = questdlg('Are you happy with the adjustments?', 'Confirmation', 'Apply', 'Discard', 'Apply');

    if strcmp(option, 'Apply')
        % User clicked "Apply," update the brightness and contrast and break the loop
        brightness = newBrightness;
        contrast = newContrast;
        break;
    else
        % User clicked "Discard," reset to the initial brightness and contrast
        rightness = 0;
        contrast = 1;
    end
end

% Apply the user-defined brightness and contrast to the merged image
adjustedImage = adjustBrightnessAndContrast(mergedImage, brightness, contrast);

% Display the final adjusted image
imshow(adjustedImage);
title('Final Adjusted Image');
end
