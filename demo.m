
USE_METHOD = 'poisson';

src = './img/src_img01.jpg';
mask = './img/mask_img01.jpg';
tar = './img/tar_img01.jpg';
dst = './result/dst_img01_poisson.jpg';
post = [80 130];

project2(USE_METHOD, src, mask, tar, dst, post);
