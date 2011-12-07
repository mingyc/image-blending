%
% Seamlessly clone the masked area of source image to target image
%
% Parameters:
% imSrc - source image
% imMask - mask image (must be binary)
% imTar - target image
% offset - the upper-left corner in target image where the source should be pasted to
%
function [imDst] = PoissonClone(imSrc, imMask, imTar, offset)

  if size(imSrc) ~= size(imMask)
    fprintf('Error - Size of mask MUST be the same as size of source image');
    exit;
  end

  % Define Constants
  LAPLACIAN = [0 1 0; 1 -4 1; 0 1 0];

  [dstH dstW] = size(imTar);

  % Calculate Bounding box of mask
  mask_stat = regionprops(imMask, 'BoundingBox');
  bbox = floor(mask_stat.BoundingBox);
  x0 = bbox(1); y0 = bbox(2);
  x1 = bbox(1)+bbox(3); y1 = bbox(2)+bbox(4);
  clear mask_stat, bbox;


  n = 1; px2count = containers.Map(0,0);
  for y = y0:y1
    for x = x0:x1
      if imMask(y, x) == 1
        px2count((y-1)*x1+x) = n;
        n = n+1;
      end
    end
  end
  n = n-1;

  A = spalloc(n, n, 5*n);
  b = zeros(1, n);
  LCoef = conv2(imSrc, -LAPLACIAN, 'same');


  pxCount = 1;
  for y = y0:y1
    for x = x0:x1
      % Don't need to handle black region of mask
      if imMask(y, x) == 0
        continue;
      end

      px = (y-1)*x1 + x;
      dstX = offset(1) + (x-x0);
      dstY = offset(2) + (y-y0);

      % on the top margin
      if y == 1 || imMask(y-1, x) == 0
        b(pxCount) = b(pxCount) + imTar(dstY-1, dstX);
      else
        A(pxCount, px2count(px-x1)) = -1;
      end

      % on the bottom margin
      if y == y1 || imMask(y+1, x) == 0
        b(pxCount) = b(pxCount) + imTar(dstY+1, dstX);
      else
        A(pxCount, px2count(px+x1)) = -1;
      end

      % on the left margin
      if x == 1 || imMask(y, x-1) == 0
        b(pxCount) = b(pxCount) + imTar(dstY, dstX-1);
      else
        A(pxCount, px2count(px-1)) = -1;
      end

      % on the right margin
      if x == x1 || imMask(y, x+1) == 0
        b(pxCount) = b(pxCount) + imTar(dstY, dstX+1);
      else
        A(pxCount, px2count(px+1)) = -1;
      end

      A(pxCount, px2count(px)) = 4;
      b(pxCount) = b(pxCount) + LCoef(y, x);

      pxCount = pxCount+1;
    end
  end

  % bi-conjugate gradient method to solve the linear system
  %X = bicg(A, b', [], 400);
  %X = lsconv(A, b');
  X = A\b';

  % reshape to original region
  imDst = imTar;
  n = 1;
  for y = y0:y1
    for x = x0:x1
      if imMask(y, x) == 1
        imDst(offset(2)+(y-y0), offset(1)+(x-x0)) = X(n);
        n = n+1;
      end
    end
  end

end
