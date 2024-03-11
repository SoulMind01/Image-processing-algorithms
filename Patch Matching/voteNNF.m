% use the NNF to vote the source patches
function output = voteNNF(NNF, source_image)
    global patch_size;
    
    fprintf("Voting to reconstruct the final result...\n");
    
    source_size = size(source_image);
    target_size = size(NNF);
    
    output = zeros(target_size(1), target_size(2), 3);
    
    % write your code here to reconstruct the output using source image
    % patches
     % Initialize output and count matrices
    [target_height, target_width, ~] = size(NNF(:,:,1));
    accumulator = zeros(target_height, target_width, 3); % For accumulating color values
    counts = zeros(target_height, target_width); % For counting contributions per pixel

    pad_size = floor(patch_size / 2);
    source_padded = padarray(source_image, [pad_size pad_size], 'symmetric', 'both');
    
    % Loop over each entry in the NNF
    for i = 1 : target_height
        for j = 1 : target_width
            % Determine the top-left corner of the source patch
            src_x = NNF(i, j, 1) + pad_size;
            src_y = NNF(i, j, 2) + pad_size;
            
            % Extract the patch from the padded source image
            patch = source_padded(src_x - pad_size : src_x + pad_size, src_y - pad_size : src_y + pad_size, :);
            
            % Add the patch to the accumulator and increment the counts
            for dx = -pad_size : pad_size
                for dy = -pad_size : pad_size
                    x_index = i + dx;
                    y_index = j + dy;
                    if x_index >= 1 && x_index <= target_height && y_index >= 1 && y_index <= target_width
                        accumulator(x_index, y_index, :) = accumulator(x_index, y_index, :) + double(patch(dx+pad_size+1, dy+pad_size+1, :));
                        counts(x_index, y_index) = counts(x_index, y_index) + 1;
                    end
                end
            end
        end
    end
    
    % Calculate the average for each pixel
    for k = 1:3 % For each color channel
        output_channel = accumulator(:,:,k) ./ counts;
        output_channel(isnan(output_channel)) = 0; % Handle division by zero for pixels without contributions
        output(:,:,k) = output_channel;
    end
    fprintf("Done!\n");
end