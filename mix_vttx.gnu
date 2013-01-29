##set term pngcairo size 1024, 768
##set output 'mix_vttx.png'

set contour base
set cntrparam levels 20
set samples 101, 101
set isosamples 21, 21
set xyplane at 0
set title "mix_vttx"
set xlabel "Échantillon 1 (x)"
set xrange [ -1 : 1 ] noreverse nowriteback
set ylabel "Échantillon 2 (y)"
set yrange [ -1 : 1 ] noreverse nowriteback
set zlabel "Mixage"
set zrange [ -1 : 1 ] noreverse nowriteback
set key off # no legend

mix_vttx(x, y) = \
    x >= 0 && y >= 0 ? x + y - x * y \
  : x <= 0 && y <= 0 ? x + y + x * y \
  : x + y

set view 60, 10
splot mix_vttx(x, y)
