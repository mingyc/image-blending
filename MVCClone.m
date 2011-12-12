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
  % P: a 2*m matrix indicates m boundary points [x;y]
  P = fliplr(flipud(bound{1}'));
  m = size(P, 2);
  clear bound, label;

  coord = zeros(y_max, x_max, m);
  clamp = @(v)max(min(v,1),-1);

  % Preprocessing stage
  % Compute the mean-value coordinate for each selected pixel in source image
  for y = y_min:y_max
    for x = x_min:x_max
      if imMask(y, x) == 0
        continue;
      end

      Prel = P - repmat([x;y], [1 m]);
      r = zeros(1, m);

      % Compute distance from (x,y) to each boundary vertex
      for i = 1:m
        r(i) = norm(Prel(:, i));
      end

      theta = acos(clamp(dot(circshift(Prel, [0 1]), Prel) ./ (circshift(r, [0 1]) .* r)));
      w = (tan(theta/2) + tan(circshift(theta, [0 -1])/2)) ./ r;

      coord(y, x, :) = w / sum(w);

      clear Prel; clear r; clear theta; clear w;

    end
  end
  
  % Compute the difference along the boundary
  diff = zeros(m, ch);
  for p = 1:m
    diff(p, :) = imTar(P(2,p), P(1,p), :) - imSrc(P(2,p), P(1,p), :);
  end

  imDst = imTar;
  for y = y_min:y_max
    for x = x_min:x_max
      if imMask(y, x) == 1
        if imMask(y-1, x-1) == 0 || imMask(y-1, x) == 0 || imMask(y-1, x+1) == 0 || imMask(y, x-1) == 0 || imMask(y, x+1) == 0 || imMask(y+1, x-1) == 0 || imMask(y+1, x) == 0 || imMask(y+1, x+1) == 0
          continue;
        end

        % Evaluate the mean-value interpolant at (x, y)
        for i = 1:ch
          imDst(offset(2) + (y-y_min), offset(1) + (x-x_min), i) = imSrc(y, x, i) + sum(reshape(coord(y, x, :), m,1).*diff(:, i));
        end
      end
    end
  end

end
