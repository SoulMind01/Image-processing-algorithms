function rImg = mySeamCarveResize(Img,rC,rR)
%rC: number of columns to be removed
%rR: number of row to be removed
    % Copy the original image to start the seam carving process
    rImg = Img;
    
    % Remove vertical seams rC times
    for i = 1:rC
        % Calculate the energy map of the current image
        EMap = myEnergyFunc(rImg);
        
        % Find the vertical seam with the lowest energy
        [~, S] = mySeamCarve_V(EMap);
        
        % Remove the found seam from the image
        rImg = removeVerticalSeam(rImg, S);
    end
    
    % Remove horizontal seams rR times
    for i = 1:rR
        % Calculate the energy map of the current image
        EMap = myEnergyFunc(rImg);
        
        % Find the horizontal seam with the lowest energy
        [~, S] = mySeamCarve_H(EMap);
        
        % Remove the found seam from the image
        rImg = removeHorizontalSeam(rImg, S);
    end
end

function imgWithoutSeam = removeVerticalSeam(img, seam)
    [rows, ~, numChannels] = size(img);
    for c = 1:numChannels
        for r = 1:rows
            img(r, seam(r):end-1, c) = img(r, seam(r)+1:end, c);
        end
    end
    imgWithoutSeam = img(:, 1:end-1, :); % Remove the last column
end

function imgWithoutSeam = removeHorizontalSeam(img, seam)
    [~, cols, numChannels] = size(img);
    for c = 1:numChannels
        for col = 1:cols
            img(seam(col):end-1, col, c) = img(seam(col)+1:end, col, c);
        end
    end
    imgWithoutSeam = img(1:end-1, :, :); % Remove the last row
end
