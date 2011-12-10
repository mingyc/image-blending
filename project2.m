%
% Starter function of Project #2
%
% Parameters:
% method - 'poisson': poisson image blending; 'MVC': mean value coordinate
% srcPath - path of source image
% maskPath - path of mask image
% tarPath - path of target image
% dstPath - path of destination image
% posTar - the upper-left corner in target image where the source should  be pasted to
%
%
function project2(method, srcPath, maskPath, tarPath, dstPath, posTar)


  imsrc = double(imread(srcPath));
  immask = im2bw(imread(maskPath), 0.5);
  imtar = double(imread(tarPath));

  if strcmp(method, 'poisson')
    % poisson blending
    blended = zeros(size(imtar));

    blended(:,:,1) = PoissonClone(imsrc(:,:,1), immask, imtar(:,:,1), posTar);
    blended(:,:,2) = PoissonClone(imsrc(:,:,2), immask, imtar(:,:,2), posTar);
    blended(:,:,3) = PoissonClone(imsrc(:,:,3), immask, imtar(:,:,3), posTar);

    imwrite(uint8(blended), dstPath, 'JPG');
  else if strcmp(method, 'MVC')
    % mean-value coordinate 
    blended = MVCClone(imsrc, immask, imtar, posTar);

    imwrite(uint8(blended), dstPath, 'JPG');
  end


end
