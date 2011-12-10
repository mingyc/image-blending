%
% Mean-Value Coordinate Cloning
%
% Parameters:
% imSrc - source image (could be single/multiple channel)
% imMask - mask image (must be binary)
% imTar - target image (could be single/multiple channel)
% offset - the upper-left corner in target image where the source should be pasted to
%
function [imDst] = MVCClone(imSrc, imMask, imTar, offset)

  [H W ch] = size(imSrc);
  if size(imMask) ~= [H W]
    fprintf('Error - Size of mask MUST be the same as size of source image');
    exit;
  end
  clear H, W;

  % Find the bounding box of mask
  mask_stat = regionprops(imMask, 'BoundingBox');
  bbox = floor(mask_stat.BoundingBox);
  x_min = bbox(1);          y_min = bbox(2);
  x_max = bbox(1)+bbox(3);  y_max = bbox(2)+bbox(4);
  clear mask_stat, bbox;

  % Find the boundary of mask
  [bound label] = bwboundaries(imMask, 'noholes');
  % P: 2*m matrix indicates m boundary points
  P = bound{1}';
  m = size(P, 2);
  clear bound, label;

  coord = zeros(y_max, x_max, m);

  % Preprocessing stage
  % Compute the mean-value coordinate for each selected pixel in source image
  for y = y_min:y_max
    for x = x_min:x_max
      if imMask(y, x) == 0
        continue;
      end

      Prel = P - repmat([y;x], [1 m]);
      r = zeros(1, m);
      A = zeros(1, m);
      B = zeros(1, m);

      % Compute distance from (y,x) to each boundary vertex
      for i = 1:m
        r(i) = norm(Prel(:, i));
      end

      % Compute numerator of equation (2)
      left = cross([Prel; zeros(1, m)], [Prel(:, 2:end), Prel(:, 1); zeros(1, m)]);
      A(:) = left(3, :) / 2;
      right = cross([Prel(:, end), Prel(:, 1:end-1); zeros(1, m)], [Prel(:, 2:end), Prel(:, 1); zeros(1, m)]);
      B(:) = right(3, :) / 2;
      clear left, right;

      % Compute mean-value coordinate of (y, x)
      coord(y, x, :) = [(r(end)*A(1)-r(1)*B(1)+r(2)*A(end))/(A(end)*A(1)), ... % elem #1
                        (r(1:end-2).*A(2:end-1)-r(2:end-1).*B(2:end-1)+r(3:end).*A(1:end-2))./(A(1:end-2).*A(2:end-1)),... % elem #2 to #end-1
                        (r(end-1)*A(end)-r(end)*B(end)+r(1)*A(end-1))/(A(end-1)*A(end))]; % last elem

      coord(y, x, :) = coord(y, x, :) / sum(coord(y, x, :));
    end
  end
  
  % Compute the difference along the boundary
  diff = zeros(m, ch);
  for p = 1:m
    diff(p, :) = imTar(P(1,p), P(2,p), :) - imSrc(P(1,p), P(2,p), :);
  end

  imDst = imTar;
  for y = y_min:y_max
    for x = x_min:x_max
      if imMask(y, x) == 1
        % Evaluate the mean-value interpolant at (y, x)
        for i = 1:ch
          imDst(offset(2) + (y-y_min), offset(1) + (x-x_min), i) = imSrc(y, x, i) + sum(reshape(coord(y, x, :), m,1).*diff(:, i));
        end
      end
    end
  end

end
