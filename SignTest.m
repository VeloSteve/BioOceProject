% Random sign speed test
n = 8;
pm = sign(0.5-rand(10^n,1)); % a matrix of randomly generated positve
pm2 = sign(randn(10^n, 1));

mean(pm)
mean(pm2)

std(pm)
std(pm2)
