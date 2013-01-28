##set term pngcairo size 1024, 768
##set output 'mix_f_vttx.png'

set samples 101, 101
set isosamples 21, 21
set xyplane at 0
set title "Comparaison de mix_f et mix_vttx"
set xlabel "Échantillon 1" 
set xrange [ -1 : 1 ] noreverse nowriteback
set ylabel "Échantillon 2" 
set yrange [ -1 : 1 ] noreverse nowriteback
set zlabel "Mixage"
set zrange [ -1 : 1 ] noreverse nowriteback
set key bottom right

mix_vttx(x, y) = \
    x >= 0 && y >= 0 ? x + y - x * y \
  : x <= 0 && y <= 0 ? x + y + x * y \
  : x + y

g(x) = x * (2 - abs(x))
mix_f(x, y) = g((x + y) / 2)

set view 60, 10
splot mix_vttx(x, y), mix_f(x, y) with lines linestyle 3
