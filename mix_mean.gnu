##set term pngcairo size 1024, 768
##set output 'mix_mean.png'

set samples 21, 21
set isosamples 21, 21
set xyplane at 0
set title "Moyenne"
set xlabel "Échantillon 1" 
set xrange [ -1 : 1 ] noreverse nowriteback
set ylabel "Échantillon 2" 
set yrange [ -1 : 1 ] noreverse nowriteback
set zlabel "Mixage" 
set zrange [ -1 : 1 ] noreverse nowriteback
set key off # no legend

mix_mean(x, y) = (x + y) / 2

set view 60, 10
splot mix_mean(x, y)
