function outImg = myRichardsonLucy(Img,PSF,iter)
    % Convert the image and PSF to double precision for calculations
    Img = double(Img);
    PSF = double(PSF);
    
    % Initialize the estimate of the original image
    estimate = ones(size(Img));
    
    % Create a flipped version of the PSF for the convolution
    PSF_flip = rot90(PSF, 2);
    
    % Richardson-Lucy algorithm loop
    for i = 1:iter
        % Convolve the current estimate with the PSF
        convolved = conv2(estimate, PSF, 'same');
        
        % Calculate ratio of observed image to convolved image
        ratio = Img ./ convolved;
        
        % Convolve the ratio with the flipped PSF
        correction = conv2(ratio, PSF_flip, 'same');
        
        % Update estimate
        estimate = estimate .* correction;
    end
    
    % Return the estimate as the output image, converting back to the original image type
    outImg = uint8(estimate);
end
