# Watermarking using DWT-SVD in MATLAB

## Screenshots
### Initial Window
![Initial](https://snag.gy/9TFJgn.jpg)
### Output
![Output](https://snag.gy/TjcURi.jpg)


Usage - 
---------

1. Run gui.m
2. gui.m & logic.m must be in same dir.
3. Sample images are provided in sample dir.
4. Grayscale or RGB images are supported.
5. Click on "Embed" to Embed the watermark in source.
6. Click on "Save" to save the watermarked image.
7. Click on "Extract" to extract back watermark.

Features - 
------------

1. Select source, watermark image using filen dialog.
2. Save watermarked image on disk using file dialog.
3. In case of RGB image, select either R/G/B component or convert to Grayscale using dropdown.
4. Provide embedding strength in inpox box. (Default: 0.75)
5. Different stages of actions on image are displayed.
6. Watermark extraction is provided.

Note - 
--------

Program uses DWT+SVD technique to embed and extract watermark. Works fine on Matlab 2017.
