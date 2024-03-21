function segmented_image = watershedWithMarkers(binary_image, min_distance_threshold, area_threshold)
    % Step 1: Compute the distance transform
    distance_transform = bwdist(~binary_image);

    % Step 2: Threshold the distance transform to get regional maxima
    regional_maxima = imregionalmax(distance_transform);
    
    % Step 3: Use morphological operations to separate closely located markers
    marker_dilated = imdilate(regional_maxima, strel('disk', min_distance_threshold));

    % Step 4: Compute the watershed transform using regional maxima as markers
    labels = watershed(-distance_transform, 8);

    % Step 5: Post-process the watershed result to merge small regions
    segmented_image = binary_image;
    for label_val = 1:max(labels(:))
        % Extract each region from the watershed result
        region_mask = labels == label_val;
        
        % Compute the area of the region
        region_area = sum(region_mask(:));
        
        % If the region area is smaller than the threshold, merge it with the background
        if region_area < area_threshold
            segmented_image(region_mask) = 0;
        end
    end
end
