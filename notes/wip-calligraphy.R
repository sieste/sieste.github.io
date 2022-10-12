library(tidyverse)

df = tibble(x = seq(-3*pi, 3*pi, .01),
            y = sin(2*x) * exp(-.1 * x^2),
            dy = c(NA, diff(y))) %>%
     na.omit %>%
     mutate(lwd = pmin(dy, 0))
ggplot(df) + 
  geom_path(aes(x=x, y=y, size=-lwd), show.legend=FALSE) +
  theme_void()


df = tibble(t = seq(-2*pi, 2*pi, .01),
            x = cos(5 * t),
            y = sin(4 * t),
            dy = c(NA, diff(y))) %>%
     na.omit %>%
     mutate(lwd = (pmax(dy, 0))^1/3)
ggplot(df) + 
  geom_path(aes(x=x, y=y, size=lwd), show.legend=FALSE) +
  theme_void()


df = tibble(t = seq(-5*pi, 5*pi, .01),
            x = cos(t) - .1 * t,
            y = sin(t),
            dy = c(NA, diff(y))) %>%
     na.omit %>%
     mutate(lwd = pmax(dy,0))
ggplot(df) + 
  geom_path(aes(x=x, y=y, size=lwd), show.legend=FALSE) +
  theme_void()


RR = 26
rr = 6
dd = 11
df = tibble(t = seq(0, 10*pi, .01),
            x = (RR - rr) * cos(t) + dd * cos((RR-rr)/rr * t),
            y = (RR - rr) * sin(t) - dd * sin((RR-rr)/rr * t),
            dy = c(NA, diff(y))) %>%
     na.omit %>%
     mutate(lwd = pmax(dy,0))
ggplot(df) + 
  geom_path(aes(x=x, y=y, size=lwd), show.legend=FALSE) +
  theme_void()


# random bezier curves
n = 200
df = tibble(u = 1:n, x = rnorm(n), y = rnorm(n))
cf = with(df, curvefit(u = u, x = x, y = y, n=10))
v = seq(0, 100, .01)
xs = polyval(drop(cf$px), v)
ys = polyval(drop(cf$py), v)
df = tibble(x = xs,
            y = ys,
            ds = c(NA, sqrt(diff(x)^2 + diff(y)^2)),
            dy = c(NA, diff(y))) %>%
     na.omit %>%
     mutate(lwd = pmax(dy,0))
ggplot(df) + 
  geom_path(aes(x=x, y=y, size=lwd), show.legend=FALSE) +
  theme_void()



