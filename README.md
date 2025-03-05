## Overview
This script performs a quantitative analysis of foci on a single image. It processes a composite of three 8-bit, single-channel, maximum projection images in `.tif` format. The analysis results are stored in a `.csv` file containing a table with foci data.

## Prerequisites
Before running the script, ensure the following:
1. You have three 8-bit, single-channel, maximum projection images in `.tif` format.
2. The `pxSize` variable is correctly adjusted to match the pixel size of the images.
3. The `CROIEditor` function is used for manually delineating the ROIs (cells) in the image.

## Required Functions
The script depends on the following functions:
- `mergeAndAdjustImages`: Merges and adjusts the brightness & contrast of the three image channels.
- `CROIEditor`: Used for manual delineation of ROIs (cells).
- `watershedWithMarkers`: Performs the watershed transform for segmentation.

## Usage Instructions
1. Place the script (`fociAnalysis_single.m`) and the required `.tif` images in the same folder.
2. Run the script in MATLAB.
3. Input the condition type when prompted.
4. Manually delineate the ROIs (cells) using the `CROIEditor` tool.
5. Select the thresholded `.png` image processed using Ilastik when prompted.
6. The script will analyze the segmented images, extract foci properties, and save the results in a `.csv` file.

## Output
- A `.csv` file containing foci data, including:
  - Image name
  - Cell number
  - Cell area
  - Background intensity
  - Foci coordinates (x, y)
  - Foci area
  - Maximum and mean intensities
  - Foci integrated intensity
  - The results are saved in a subfolder named after the input condition type.
 
Details of the analysis can be found in the Methods section under 'Quantification of number of foci' of the manuscript Pachinger et al. (2025).

## Repository
The full analysis script can be accessed at:
[GitHub Repository](https://github.com/jugarbau/Pachinger-et-al.-2025)

The `CROIEditor` function is available at:
[GitHub Repository](https://github.com/aether-lab/prana/blob/master/CROIEditor.m)

## License
This script is provided under an open-source license. Please cite appropriately.
