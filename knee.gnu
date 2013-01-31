##set term pngcairo size 640, 480
##set output 'knee.png'

set contour base
set cntrparam levels 20
set samples 101, 101
set isosamples 21, 21
set xyplane at 0
set title "Hard and soft knee"
set xlabel "sum/n"
set xrange [ -1 : 1 ] noreverse nowriteback
set ylabel "Mixage"
set yrange [ -1 : 1 ] noreverse nowriteback
set key right bottom

min(x, y) = x < y ? x : y
max(x, y) = x > y ? x : y

ksum(k, z) = max(-1, min(1, n * k * z))
sum(z) = ksum(1, z)
mean(z) = ksum(1./n, z)

n = 2    # sample count
t = 0.8  # threshold
s = 0.15 # smooth width

hknee(z) = abs(z) < t/n ? n*z \
  : sgn(z) * (t + (abs(z)-t/n)*(1-t)/(1-t/n))

# -- Principle of this smooth knee function (maybe too complicated) --
#
# We have two linear functions: sum(x) and the "compressed" part
# (call it c(x), see hknee(x)).
# We want to smooth the angle. The threshold is t, so its abscissa is:
#   sum⁻¹(t) = t/n
# We search a function (let's call it r).
# At t/n-s, we want:
#   r(t/n-s) = sum(t/n-s)                   /* connected */
#   r'(t/n-s) = sum'(t/n-s) = n             /* same variations */
# At t/n+s, we want:
#   r(t/n+s) = c(t/n+s)                     /* connected */
#   r'(t/n+s) = c(t/n+s) = (1-t)/(1/(t/n))  /* same variations */
# We want a linear interpolation of the derivative of sknee (i.e. its
# variations decreases regularly), so the curve is quadratic.
#
# Let's call j = (1-t)/(1/(t/n)) / 2*s
#   r'(z) = j*z + n*j*(s-t/n)
# By integration:
#   r(z) = j * z**2 / 2 + (n + j * (s - t/n)) * z + k (with k a real)
# We want r(t/n-s) = sum(t/n-s) = n * (t/n-s).
# We can deduce k = t - n*s + (t/n-s) * ((j/2) * (t/n-s) - n)
#
# sknee(z) is r(z) between t/n-s and t/n+s, hknee(z) anywhere else.

j = ((1-t)/(1-t/n)-n)/(2*s)
dk = t - n*s + (t/n-s) * ((j/2)*(t/n-s)-n)
r(z) = sgn(z) *( j*(abs(z)**2)/2 + (n+j*(s-t/n))*(abs(z)) + dk)

sknee(z) = abs(z) < t/n-s || abs(z) > t/n+s ? hknee(z) : r(z)

plot mean(x), sum(x), hknee(x), sknee(x)
