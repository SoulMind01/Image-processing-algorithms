% computes the NNF between patches in the target image and those in the source image
function NNF = bruteForceNNF(target_image, source_image)
    global patch_size;
    
    fprintf("Computing NNF using brute force...\n");
    
    target_image = target_image(1:32, 1:32, :);
    source_image = source_image(1:32, 1:32, :);
    imwrite(target_image,"target_32.png");
    imwrite(source_image,"source_32.png");
    target_size = size(target_image);
    source_size = size(source_image);

    % initialize the NNF
    NNF = zeros(target_size(1), target_size(2), 2);
    
    tic
    % Pad the source image to handle patches near the edges
    pad_size = floor(patch_size / 2);
    source_padded = padarray(source_image, [pad_size pad_size], 'symmetric');
    target_padded = padarray(target_image, [pad_size pad_size], 'symmetric');
    
    % Initialize NNF with zeros. The third dimension contains the x and y coordinates
    target_rows = size(target_image, 1);
    target_cols = size(target_image, 2);
    source_rows = size(source_image, 1);
    source_cols = size(source_image, 2);
    NNF = zeros(target_rows, target_cols, 2);
    
    % Loop through each pixel in the target image
    for i = 1 + pad_size : target_rows + pad_size
        for j = 1 + pad_size : target_cols + pad_size
            min_distance = inf; % Initialize min_distance with infinity
            for x = 1 + pad_size : source_rows + pad_size
                for y = 1 + pad_size : source_cols + pad_size
                    % Extract the patch
                    source_patch = source_padded(x - pad_size : x + pad_size, y - pad_size : y + pad_size, :);
                    target_patch = target_padded(i - pad_size : i + pad_size, j - pad_size : j + pad_size, :);

                    % Create valid_mask for the target patch
                    valid_mask = ones(size(source_patch));
                    for a = 1 : patch_size
                        for b = 1 : patch_size
                            % evaluate the validity of each potision
                            % centered at (i, j) and (x, y) respectively
                            % (i, j) in target
                            % (x, y) in source
                            flag = 1;
                            if i - pad_size + (a - 1) <= pad_size || i + (a - 1) > target_rows + pad_size
                                flag = 0;
                            end
                            if j - pad_size + (b - 1) <= pad_size || j + (b - 1) > target_cols + pad_size
                                flag = 0;
                            end
                            if x - pad_size + (a - 1) <= pad_size || x + (a - 1) > source_rows + pad_size
                                flag = 0;
                            end
                            if y - pad_size + (b - 1) <= pad_size || y + (b - 1) > source_cols + pad_size
                                flag = 0;
                            end
                            valid_mask(a, b, :) = flag;
                        end
                    end
                    
                    % Compute the distance with the valid_mask
                    distance = patchDistance(source_patch, target_patch, valid_mask);
                    if distance < min_distance
                        min_distance = distance;
                        NNF(i - pad_size, j - pad_size, :) = [x - pad_size, y - pad_size]; % Store the position relative to the original source image
                    end
                end
            end
        end
    end
    toc
    fprintf("Done!\n");
end
function distance = patchDistance(patch1, patch2, valid_mask)
    assert(all(size(patch1) == size(patch2)) & all(size(patch2) == size(valid_mask)));
    % Compute the squared differences only for valid pixels
    diff = (patch1 - patch2).^2;
    diff = diff .* valid_mask; % Apply the mask to exclude invalid pixels
    distance = sum(diff(:)); % Sum all the differences
end