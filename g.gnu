##set term pngcairo size 640, 480
##set output 'g.png'

set contour base
set cntrparam levels 20
set samples 101, 101
set isosamples 21, 21
set xyplane at 0
set title "g, compromis entre la somme et la moyenne"
set xlabel "(x+y)/2"
set xrange [ -1 : 1 ] noreverse nowriteback
set ylabel "Mixage" 
set yrange [ -1 : 1 ] noreverse nowriteback
set key right bottom

min(x, y) = x < y ? x : y
max(x, y) = x > y ? x : y

ksum(k, z) = max(-1, min(1, 2 * k * z))
sum(z) = ksum(1, z)
mean(z) = ksum(0.5, z)
g(z) = z * (2 - abs(z))

plot mean(x), sum(x), g(x)
