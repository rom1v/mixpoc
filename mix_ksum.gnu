##set term pngcairo size 1024, 768
##set output 'mix_ksum.png'

set samples 21, 21
set isosamples 21, 21
set xyplane at 0
set title "0.7 × somme"
set xlabel "Échantillon 1" 
set xrange [ -1 : 1 ] noreverse nowriteback
set ylabel "Échantillon 2" 
set yrange [ -1 : 1 ] noreverse nowriteback
set zlabel "Mixage" 
set zrange [ -1 : 1 ] noreverse nowriteback
set key off # no legend

set label 1 "clipping" at .9, .9, 1.6 center tc rgb "blue"
set arrow 1 from .9, .9, 1.5 to .85, .85, 1 lc rgb "blue"
set label 2 "clipping" at -.9, -.9, -0.4 center tc rgb "blue"
set arrow 2 from -.9, -.9, -0.5 to -0.85, -0.85, -1 lc rgb "blue"

min(x, y) = x < y ? x : y
max(x, y) = x > y ? x : y

mix_ksum(k, x, y) = max(-1, min(1, k * (x + y)))

set view 60, 10
splot mix_ksum(.7, x, y)
