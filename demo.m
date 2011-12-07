DO_POISSON = true;
DO_COORDINATE = false;



src = './img/src_img01.jpg';
mask = './img/mask_img01.jpg';
tar = './img/tar_img01.jpg';
dst = './result/dst_img01.jpg';
post = [80 130];

project2(DO_POISSON, DO_COORDINATE, src, mask, tar, dst, post);
