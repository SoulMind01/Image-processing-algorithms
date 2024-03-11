function E = myEnergyFunc(Img)
    % Convert image to double precision for computation
    Img = im2double(Img);
    
    % Pre-allocate the gradient magnitude image
    gradMag = zeros(size(Img, 1), size(Img, 2));
    
    % Apply a Gaussian filter to smooth the image and reduce noise
    ImgSmooth = imgaussfilt(Img, 1);
    
    % Compute gradients for each color channel and add them together
    for c = 1:3 % Loop over the color channels (R, G, B)
        [Gx, Gy] = imgradientxy(ImgSmooth(:, :, c), 'Sobel');
        
        % Compute the gradient magnitude for the current channel
        Gmag = sqrt(Gx.^2 + Gy.^2);
        
        % Sum the magnitudes across color channels
        gradMag = gradMag + Gmag;
    end
    
    % Normalize the energy
    E = gradMag / max(gradMag(:));
end

