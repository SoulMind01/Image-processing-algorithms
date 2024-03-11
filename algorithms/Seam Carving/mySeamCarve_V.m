function [E,S] = mySeamCarve_V(EMap)
%find the vertical seam with lowest energy
%return: E: the energy of the choosen seam, S: the choosen seam
    % Initialize the size of the energy map
    [rows, cols] = size(EMap);
    
    % Pre-allocate the cumulative energy map
    M = zeros(size(EMap));
    M(1, :) = EMap(1, :);
    
    % Pre-allocate the backtrack matrix to store the path
    backtrack = zeros(size(EMap), 'int32');
    
    % Populate the cumulative energy map and the backtrack matrix
    for i = 2:rows
        for j = 1:cols
            % Edge cases for the first and last column
            if j == 1
                [~, idx] = min([M(i-1, j), M(i-1, j+1)]); % idx=1 if M(i-1,j) is smaller, otherwise 2, mapping offset to {0, 1}
                offset = idx - 1;
            elseif j == cols
                [~, idx] = min([M(i-1, j-1), M(i-1, j)]);
                offset = idx - 2;
            else
                [~, idx] = min([M(i-1, j-1), M(i-1, j), M(i-1, j+1)]);
                offset = idx - 2;
            end
            
            M(i, j) = EMap(i, j) + M(i-1, j+offset);
            backtrack(i, j) = j+offset;
        end
    end
    
    % Find the end of the seam with the minimum energy
    [~, idx] = min(M(rows, :));
    
    % Trace back the seam from bottom to top
    S = zeros(rows, 1);
    S(rows) = idx;
    for i = rows:-1:2
        S(i-1) = backtrack(i, S(i));
    end
    
    % Calculate the energy of the chosen seam
    E = sum(EMap(sub2ind(size(EMap), (1:rows)', S)));
end
