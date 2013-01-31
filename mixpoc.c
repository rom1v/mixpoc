/* Audio mixing PoC
 *
 * by Romain Vimont <rom+mixing@rom1v.com>
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

static int
_sum(int n, int samples[])
{
  int sum = 0;
  int i;
  for (i = 0; i < n; i++) {
    sum += samples[i];
  }
  return sum;
}

static double
_dsum(int n, int samples[])
{
  double sum = 0;
  int i = 0;
  for (i = 0; i < n; i++) {
    sum += samples[i] / 32768.;
  }
  return sum;
}

/* convert from [-1.; 1.] to [-32768; 32767] */
static int
to_int16(double x)
{
  int res = x * 32768;
  if (res == 32768)
    res = 32767;
  return res;
}

int
mix_sum(int n, int samples[])
{
  int sum = _sum(n, samples);
  if (sum < -32768) {
    sum = -32768;
  } else if (sum > 32767) {
    sum = 32767;
  }
  return sum;
}

int
mix_mean(int n, int samples[])
{
  return _sum(n, samples) / n;
}

static int
_mix_ksum(double k, int n, int samples[])
{
  /* If you mix 4 tracks mix(a, b , c, d), it should be equivalent to do:
   *   mix(mix(a + b) + mix(c + d)) = mix²(a + b + c + d)
   * The coeff for n tracks grows as log2(n). */
  double coeff = pow(k, log2(n));
  return (int) (_sum(n, samples) * coeff);
}

int
mix_ksum(int n, int samples[])
{
  return _mix_ksum(.7, n, samples);
}

static int
_mix2_vttx(int s1, int s2)
{
  double x = s1 / 32768.;
  double y = s2 / 32768.;
  if (x >= 0 && y >= 0) {
    return to_int16(x + y - x * y);
  }
  if (x <= 0 && y <= 0) {
    return to_int16(x + y + x * y);
  }
  return s1 + s2;
}

int
mix_vttx(int n, int samples[])
{
  int sample = samples[0];
  int i;
  for (i = 1; i < n; i++) {
    sample = _mix2_vttx(sample, samples[i]);
  }
  return sample;
}

int
mix_f(int n, int samples[])
{
  double z = _dsum(n, samples) / n;
  int sgn = z >= 0 ? 1 : -1;
  double g = sgn * (1 - pow(1 - sgn * z, n));
  return to_int16(g);
}

int
_mix_hknee(double threshold, int n, int samples[])
{
  double sum = _dsum(n, samples);
  int sign = (sum < 0) ? -1 : 1;
  if (sign * sum < threshold) {
    return to_int16(sum);
  }
  double res = sign * (n * threshold +
                       (sign * sum - threshold) * (1 - n * threshold) / (1 -
                                                                         threshold));
  return to_int16(res);
}

int
mix_hknee(int n, int samples[])
{
  return _mix_hknee(.7, n, samples);
}

/* t for (t)hreshold, s for (s)mooth */
int
_mix_sknee(double t, int s, int n, int samples[])
{
  /* not optimized at all */
  double sum = _dsum(n, samples);
  if (fabs(sum) < t / n - s || fabs(sum) > t / n + s) {
    return _mix_hknee(t, n, samples);
  }
  double j = (1 - t) / (1 / (t / n));
  double dk = t - n * s + (t / n - s) * ((j / 2) * (t / n - s) - n);
  double d =
    sum <
    0 ? -1 : 1 * (j * sum * sum / 2) + (n + j * (s - t / n)) * abs(sum) + dk;
  return to_int16(d);
}

int
mix_sknee(int n, int samples[])
{
  return _mix_sknee(.8, .15, n, samples);
}

int
main(int argc, char *argv[])
{
  int filecount = argc - 2;
  FILE *files[filecount];
  int samples[filecount];
  int hasdata;                  /* boolean */
  int i;
  int lsb, msb;                 /* least/most significant byte */
  int (*mix) ();                /* mixing function */

  if (argc < 3) {
    fprintf(stderr,
            "Syntax: %s %s file1 [file2 [...]]\n",
            argv[0], "(sum|mean|ksum|vttx|f|hknee|sknee)");
    exit(1);
  }

  /* open files */
  for (i = 0; i < filecount; i++) {
    files[i] = fopen(argv[i + 2], "r");
    if (files[i] == NULL) {
      fprintf(stderr, "Error opening %s\n", argv[i + 2]);
      exit(2);
    }
  }

  /* select mixing function */
  if (strcmp("sum", argv[1]) == 0) {
    mix = mix_sum;
  } else if (strcmp("mean", argv[1]) == 0) {
    mix = mix_mean;
  } else if (strcmp("ksum", argv[1]) == 0) {
    mix = mix_ksum;
  } else if (strcmp("vttx", argv[1]) == 0) {
    mix = mix_vttx;
  } else if (strcmp("f", argv[1]) == 0) {
    mix = mix_f;
  } else if (strcmp("hknee", argv[1]) == 0) {
    mix = mix_hknee;
  } else if (strcmp("sknee", argv[1]) == 0) {
    mix = mix_sknee;
  } else {
    fprintf(stderr, "Unknown mixing function: %s\n", argv[1]);
    fprintf(stderr, "Must be one of (sum|mean|ksum|vttx|f|hknee|sknee)\n");
    exit(3);
  }

  do {
    /* short and stupid algorithm for PoC only */
    hasdata = 0;
    for (i = 0; i < filecount; i++) {
      /* read LSB (little endian) */
      if ((lsb = getc(files[i])) == EOF) {
        samples[i] = 0;
      } else {
        /* read MSB (little endian) */
        if ((msb = getc(files[i])) == EOF) {
          samples[i] = 0;
        } else {
          hasdata = 1;
          samples[i] = ((signed char) msb << 8) | (lsb & 0xff);
        }
      }
    }

    if (hasdata) {
      int mixed_sample = (*mix) (filecount, samples);
      /* little endian */
      putchar(mixed_sample & 0xff);
      putchar((mixed_sample >> 8) & 0xff);
    }
  } while (hasdata);

  /* files will be closed automatically (end of main) */

  return 0;
}
