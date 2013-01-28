##set term pngcairo size 1024, 768
##set output 'vtt.png'

set contour base
set cntrparam levels 20
set samples 101, 101
set isosamples 21, 21
set xyplane at 0
set title "vtt pour x et y positifs"
set xlabel "Échantillon 1" 
set xrange [ 0 : 1 ] noreverse nowriteback
set ylabel "Échantillon 2" 
set yrange [ 0 : 1 ] noreverse nowriteback
set zlabel "Mixage" 
set zrange [ 0 : 1 ] noreverse nowriteback
set key off # no legend
min(x, y) = x < y ? x : y
max(x, y) = x > y ? x : y

vtt(x, y) = x + y - x * y

set view 60, 10
splot vtt(x,y)
