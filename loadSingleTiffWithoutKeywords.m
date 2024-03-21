function [imageQ, imageQ_name] = loadSingleTiffWithoutKeywords(folder_path)
    % Get a list of all .tif files in the folder
    tif_files = dir(fullfile(folder_path, '*.tif'));

    % Initialize variables to store the image and its name
    imageQ = [];
    imageQ_name = '';

    % Loop through each .tif file
    for i = 1:numel(tif_files)
        file_name = tif_files(i).name;

        % Check if the file name does not contain 'pcm1' or 'dapi'
        if ~contains(file_name, 'pcm1', 'IgnoreCase', true) && ~contains(file_name, 'dapi', 'IgnoreCase', true)
            % Load the image
            imageQ = imread(fullfile(folder_path, file_name));
            imageQ_name = file_name;
            break; % Stop searching after finding the first matching image
        end
    end
end
