
%USE_METHOD = 'poisson';
USE_METHOD = 'MVC';

src = './img/src_img01.jpg';
mask = './img/mask_img01.jpg';
tar = './img/tar_img01.jpg';
%dst = './img/dst_img01_poisson.jpg';
dst = './img/dst_img01_mvc.jpg';
post = [80 130];

project2(USE_METHOD, src, mask, tar, dst, post);
