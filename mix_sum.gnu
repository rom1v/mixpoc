##set term pngcairo size 1024, 768
##set output 'mix_sum.png'

set samples 21, 21
set isosamples 21, 21
set xyplane at 0
set title "Somme tronquée"
set xlabel "Échantillon 1 (x)"
set xrange [ -1 : 1 ] noreverse nowriteback
set ylabel "Échantillon 2 (y)"
set yrange [ -1 : 1 ] noreverse nowriteback
set zlabel "Mixage" 
set zrange [ -1 : 1 ] noreverse nowriteback
set key off # no legend

set label 1 "clipping" at .8, .8, 1.6 center tc rgb "blue"
set arrow 1 from .8, .8, 1.5 to .75, .75, 1 lc rgb "blue"
set label 2 "clipping" at -.8, -.8, -0.4 center tc rgb "blue"
set arrow 2 from -.8, -.8, -0.5 to -0.75, -0.75, -1 lc rgb "blue"

min(x, y) = x < y ? x : y
max(x, y) = x > y ? x : y

mix_sum(x, y) = max(-1, min(1, x + y))

set view 60, 10
splot mix_sum(x, y)
