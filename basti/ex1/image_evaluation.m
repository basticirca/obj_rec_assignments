function image_evaluation(image_path)
  % load image package
  pkg load image;
  
  % load image, plot and show histogram
  I = load_greyscale(image_path);
  figure(1), imshow(I);
  figure(2), imhist(I);
  %% NOTES TO HISTOGRAM:
  % - spectrum of color values very narrow
  % - mostly values lie between 150 - 215 of intesity 
  % - global maximum is approximately 160
  
  % stretch coontrast and plot result
  I_stretched = stretch_contrast(I);
  figure(3), imshow(I_stretched);
  figure(4), imhist(I_stretched);
  %% CHANGES NOTED
  % - the spectrum of intensity values has been enhanced
  % - histogram stretched
  % - image now makes full use of possible color encodings
  % - details pop out more and appearance is generally more crisp
  
  % convert to bw mask
  I_bw = ~apply_threshold(I_stretched, 0.3);
  figure(5), imshow(I_bw);
  %% TOWARDS DIFFERENT THRESHOLDS
  % - very low values ([0, 0.1]) tend to convert most features to white color
  % - very high values ([0.9, 1.0]) convert most features to black color
  % - a mid ranged value ([0.45, 0.55]) shows a fairly evenly distributed 
  %   amount of black and white colors
  % - Regardless of the threshold chosen, the multiple small features located in
  %   the areas around the lake, seem to have a partially overlapping intensity
  %   value range. Thus excluding coloring for these areas, while uniformly 
  %   coloring the lake area is impossible using only linear black-white conversion
  % - additionally we had to invert the resulting image mask to produce a result
  %   comparable to the example shown in the exercise slides (see slide 18)
  % - This is due to the fact that, for threshold values chosen to result the lake
  %   in white color, most surrounding areas will be converted to white as well.
  % - any approaches of using the graythresh function to automatically compute 
  %   a threshold did not produce maximally useful masks
  
  % sucessive opening and closing
  I_bw_mod = open_close_successive(I_bw, 3);
  figure(6), imshow(I_bw_mod);

  % !!!!!
  % TODO: implement function for erosion or dilation
  % !!!!!
  
  % in-built erosion
  I_bw_erode_alt = erode_alt(I_bw);
  figure(7), imshow(I_bw_erode_alt);
  
  % in-built dilation
  I_bw_dilate_alt = dilate_alt(I_bw);
  figure(8), imshow(I_bw_dilate_alt);
  
  % overlay computation
  I_bw_gray = uint8(I_bw_erode_alt*255);
  I_combined = imadd(I, I_bw_gray);
  figure(9), imshow(I_combined);
  
  % !!!!!!!!
  % TODO:
  % E. Discussion: Are the results satisfactory? What are the limitations of this
  %    approach for separating background and foreground (code comments)?
  % !!!!!!!!
  
end

%--------------------------------------------------------------------

function image = load_greyscale(image_path)

  % how to include mean??
  image = rgb2gray(imread(image_path));
  
end

%--------------------------------------------------------------------

% stretches the contrast of the input image along some thresholds
function new_image = stretch_contrast(image_src)

    min_value = double(min(image_src(:)));
    max_value = double(max(image_src(:)));
    
    s = size(image_src);
    
    result = zeros(s(1), s(2));
    % calculcate contrast ratio for each pixel
    for i = 1:s(1) % loop over x
        for j = 1:s(2) % loop over y
          pixel_value = (double(image_src(i,j)) - min_value) / (max_value - min_value);                    
          result(i,j) = pixel_value;
        end
    end
   
    new_image = result;

end

%--------------------------------------------------------------------

% Alternative contrast stretching function.
% Uses in-built implementation.
function new_image = stretch_contrast_alt(image_src)

  new_image = imadjust(image_src, stretchlim(image_src),[]);

end

%--------------------------------------------------------------------

function bw_image = apply_threshold(image_src, value)

  bw_image = im2bw (image_src, im2double(value));
  % automatic computation of the threshold value
  %bw_image = im2bw (image_src, graythresh (image_src(:), "concavity"));

end

%--------------------------------------------------------------------

function mod_image = open_close_successive(image_src, times)

  % Create a disk-shaped structuring element with a radius of 5 pixels.
  % (see https://de.mathworks.com/help/images/ref/imopen.html)
  se = strel('disk', 5, 0);
  
  mod_image = image_src;
  for i = 1:times
    mod_image = imclose(imopen(mod_image, se), se);
  end 
  
end

%--------------------------------------------------------------------

% utilizes in-built erosion function (see imerode)
function mod_image = erode_alt(image_src)
  
  % Create a disk-shaped structuring element with a radius of 5 pixels.
  % (see https://de.mathworks.com/help/images/ref/imopen.html)
  se = strel('disk', 5, 0);
  mod_image = imerode(image_src, se);

end

%--------------------------------------------------------------------

% utilizes in-built erosion function (see imdilate)
function mod_image = dilate_alt(image_src)
  
  % Create a disk-shaped structuring element with a radius of 5 pixels.
  % (see https://de.mathworks.com/help/images/ref/imopen.html)
  se = strel('disk', 5, 0);
  mod_image = imdilate(image_src, se);
  
end

