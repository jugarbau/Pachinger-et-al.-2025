function adjustedImage = adjustBrightnessAndContrast(image, brightness, contrast)
    % Adjust the brightness and contrast of the input image
    adjustedImage = image + brightness;
    adjustedImage = adjustedImage * contrast;

    % Clip the pixel values to be within [0, 255]
    adjustedImage = max(adjustedImage, 0);
    adjustedImage = min(adjustedImage, 255);

    % Convert the adjusted image to uint8 (8-bit) data type
    adjustedImage = uint8(adjustedImage);
end