%
% Starter function of Project #2
%
% Parameters:
% poissonMethod - On/Off
% coordinateMethod - On/Off
% srcPath - path of source image
% maskPath - path of mask image
% tarPath - path of target image
% dstPath - path of destination image
% posTar - the upper-left corner in target image where the source should  be pasted to
%
%
function project2(poissonMethod, coordinateMethod, srcPath, maskPath, tarPath, dstPath, posTar)


  imsrc = double(imread(srcPath));
  immask = im2bw(imread(maskPath), 0.5);
  imtar = double(imread(tarPath));

  if poissonMethod
    %SeamlessCloning(imsrc, immask, imdst, posDst);

    blended = zeros(size(imtar));

    blended(:,:,1) = PoissonClone(imsrc(:,:,1), immask, imtar(:,:,1), posTar);
    blended(:,:,2) = PoissonClone(imsrc(:,:,2), immask, imtar(:,:,2), posTar);
    blended(:,:,3) = PoissonClone(imsrc(:,:,3), immask, imtar(:,:,3), posTar);

    %
    %[h w] = size(imsrc);
    %rect = [1 w 1 h];
    %r = poissonSolverMask(imsrc(:,:,1), imdst(:,:,1), rect, posDst, immask);
    %g = poissonSolverMask(imsrc(:,:,2), imdst(:,:,2), rect, posDst, immask);
    %b = poissonSolverMask(imsrc(:,:,3), imdst(:,:,3), rect, posDst, immask);
    %blended = zeros(h, w, 3);
    %fprintf('%d \n', [h w]);
    %fprintf('%d \n', size(r));
    %fprintf('%d \n', size(g));
    %fprintf('%d \n', size(b));

    %blended(:,:,1) = r;
    %blended(:,:,2) = g;
    %blended(:,:,3) = b;
    %

    imwrite(uint8(blended), dstPath, 'JPG');
  end

  if coordinateMethod
  end


end
