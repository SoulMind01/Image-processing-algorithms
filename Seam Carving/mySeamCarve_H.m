function [E,S] = mySeamCarve_H(EMap)
%find the vertical seam with lowest energy
%return: E: the energy of the choosen seam, S: the choosen seam
    % Transpose the energy map to reuse the vertical seam carving logic
    EMapT = EMap';
    [cols, rows] = size(EMapT); % Note: cols and rows are swapped due to transpose
    
    % Pre-allocate the cumulative energy map for the transposed map
    M = zeros(size(EMapT));
    M(1, :) = EMapT(1, :);
    
    % Pre-allocate the backtrack matrix to store the path
    backtrack = zeros(size(EMapT), 'int32');
    
    % Populate the cumulative energy map and the backtrack matrix
    for i = 2:cols
        for j = 1:rows
            if j == 1
                [~, idx] = min([M(i-1, j), M(i-1, j+1)]);
                offset = idx - 1;
            elseif j == rows
                [~, idx] = min([M(i-1, j-1), M(i-1, j)]);
                offset = idx - 2;
            else
                [~, idx] = min([M(i-1, j-1), M(i-1, j), M(i-1, j+1)]);
                offset = idx - 2;
            end
            
            M(i, j) = EMapT(i, j) + M(i-1, j+offset);
            backtrack(i, j) = j+offset;
        end
    end
    
    % Find the end of the seam with the minimum energy in the transposed map
    [~, idx] = min(M(cols, :));
    
    % Trace back the seam from right to left in the transposed map
    S = zeros(cols, 1);
    S(cols) = idx;
    for i = cols:-1:2
        S(i-1) = backtrack(i, S(i));
    end
    
    % Calculate the energy of the chosen seam
    E = sum(EMapT(sub2ind(size(EMapT), (1:cols)', S)));
    
    % Adjust S to correspond to the original (non-transposed) dimensions
    S = S';
end
