% computes the NNF between patches in the target image and those in the source image
function NNF = patchMatchNNF(target_image, source_image)
    global patch_size;
    
    fprintf("Computing NNF using PatchMatch...\n");
    
    trg_sz = size(target_image);
    src_sz = size(source_image);

    % initialize the NNF
    NNF = zeros(trg_sz(1), trg_sz(2), 2);
    
    tic
    % write your code here to do the PatchMatch search
    max_iterations = 4;
    w = (patch_size - 1) / 2;
    target_padded = zeros(trg_sz(1) + 2 * w, trg_sz(2) + 2 * w, 3);
    target_padded(1 + w : trg_sz(1) + w, 1 + w : trg_sz(2) + w, :) = target_image;
    source_padded = zeros(src_sz(1) + 2 * w, src_sz(2) + 2 * w, 3);
    source_padded(1 + w : src_sz(1) + w, 1 + w : src_sz(2) + w, :) = source_image;
    % NNF(:, :, 1) is the x axis mapping
    % NNF(:, :, 2) is the y axis mapping
    NNF(:, :, 1) = randi([1, src_sz(1)], trg_sz(1), trg_sz(2));
    NNF(:, :, 2) = randi([1, src_sz(2)], trg_sz(1), trg_sz(2));

    % initialize
    dist = zeros(trg_sz(1), trg_sz(2));
    for i = 1 : trg_sz(1)
        for j = 1 : trg_sz(2)
            x = NNF(i, j, 1);
            y = NNF(i, j, 2);
            dist(i, j) = comparePatch(x + w, y + w, source_padded, i + w, j + w, target_padded, patch_size);
        end
    end

    for iter = 1 : max_iterations
        if mod(iter, 2) == 1
            i_seq = 1 : trg_sz(1);
            j_seq = 1 : trg_sz(2);
        else
            i_seq = trg_sz(1) : (-1) : 1;
            j_seq = trg_sz(2) : (-1) : 1;
        end

        for i = i_seq
            for j = j_seq
                if mod(iter, 2) == 1 % propagate from left and top
                    ofs_prp(1) = dist(i, j);
                    ofs_prp(2) = dist(max(1, i - 1), j);
                    if i - 1 < 1
                        ofs_prp(2) = inf;
                    end
                    ofs_prp(3) = dist(i, max(1, j - 1));
                    if j - 1 < 1
                        ofs_prp(3) = inf;
                    end
                    [~, idx] = min(ofs_prp);
                    
                    switch idx
                        case 2 % top is smaller
                            NNF(i, j, :) = NNF(i - 1, j, :);
                            x = NNF(i, j, 1);
                            y = NNF(i, j, 2);
                            dist(i, j) = comparePatch(x + w, y + w, source_padded, i + w, j + w, target_padded, patch_size);
                        case 3 % left is smaller
                            NNF(i, j, :) = NNF(i, j - 1, :);
                            x = NNF(i, j, 1);
                            y = NNF(i, j, 2);
                            dist(i, j) = comparePatch(x + w, y + w, source_padded, i + w, j + w, target_padded, patch_size);
                    end
                    
                else % propagate from right and bottom
                    ofs_prp(1) = dist(i, j);
                    ofs_prp(2) = dist(min(trg_sz(1), i + 1), j);
                    if i + 1 > trg_sz(1)
                        ofs_prp(2) = inf;
                    end
                    ofs_prp(3) = dist(i, min(trg_sz(2), j + 1));
                    if j + 1 > trg_sz(2)
                        ofs_prp(3) = inf;
                    end
                    [~, idx] = min(ofs_prp);
                    
                    switch idx
                        case 2 % bottom is smaller
                            NNF(i, j, :) = NNF(i + 1, j, :);
                            x = NNF(i, j, 1);
                            y = NNF(i, j, 2);
                            dist(i, j) = comparePatch(x + w, y + w, source_padded, i + w, j + w, target_padded, patch_size);
                        case 3 % right is smaller
                            NNF(i, j, :) = NNF(i, j + 1, :);
                            x = NNF(i, j, 1);
                            y = NNF(i, j, 2);
                            dist(i, j) = comparePatch(x + w, y + w, source_padded, i + w, j + w, target_padded, patch_size);
                    end
                end
            end
        end
    end
    toc

    fprintf("Done!\n");
end

function dist = comparePatch(sx, sy, img_src, tx, ty, img_trg, patch_size)
    pad_size = (patch_size - 1) / 2;
    patch_src = constructPatch(sx, sy, img_src, pad_size);
    patch_trg = constructPatch(tx, ty, img_trg, pad_size);
    mask = constructMask(sx, sy, img_src, patch_size);
    mask2 = constructMask(tx, ty, img_trg, patch_size);
    mask = mask .* mask2;
    dist = patchDistance(patch_src, patch_trg, mask);
end

function patch = constructPatch(x, y, img, pad_size)
    patch = img(x - pad_size : x + pad_size, y - pad_size : y + pad_size, :);
end

function mask = constructMask(i, j, img, width)
    [rows, cols] = size(img);
    half_width = floor(width / 2);
    mask = ones(width, width, size(img, 3));
    for a = 1 : width
        for b = 1 : width
            % evaluate the validity of position (i, j)
            flag = 1;
            if i - half_width + (a - 1) <= half_width || i + (a - 1) > rows + half_width
                flag = 0;
            end
            if j - half_width + (b - 1) <= half_width || j + (b - 1) > cols + half_width
                flag = 0;
            end
            mask(a, b, :) = flag;
        end
    end
end

function distance = patchDistance(patch1, patch2, valid_mask)
    assert(all(size(patch1) == size(patch2)) & all(size(patch2) == size(valid_mask)));
    % Compute the squared differences only for valid pixels
    diff = (patch1 - patch2).^2;
    diff = diff .* valid_mask; % Apply the mask to exclude invalid pixels
    distance = sum(diff(:)); % Sum all the differences
end