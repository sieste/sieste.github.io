library(tidyverse)
library(GGally)
library(deSolve)

# model parameters
parameters = c(
  k_g = 0.05,     # per hour, GI tract own elimination rate
  k_a = 2.0,      # per hour, absorption rate from GI tract into blood
  k_e = 0.5,      # per hour, elimination rate from blood by liver
  duration = 0.5, # hours of dosing
  input = 28      # grams of alcohol per hour of dosing
)

# initial state is all 0
state = c(dose = 0, gi = 0, blood = 0)

# model differential equations for use with deSolve
model = function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    dose = ifelse(t <= duration, input, 0)  # dosing
    dgi = -k_a * gi - k_g * gi + dose # GI tract
    dblood = k_a * gi - k_e * blood     # blood
    return(list(c(dose, dgi, dblood)))        # derivatives
  }) 
}

# simulate model, immediately convert output to long data frame
times = seq(0, 12, by = 0.05)
out = ode(y = state, times = times, func = model, parms = parameters) %>% 
      as.data.frame %>%
      pivot_longer(c(gi, blood), names_to='compartment', values_to='concentration')

ggplot(out) + geom_line(aes(x=time, y=concentration, colour=compartment))



# function that takes inputs and produces a simulation (matrix with 4 columns:
# time, dose, gi, blood)
sim = function(parms) {
  stopifnot(length(parms) == 5)
  names(parms) = c('k_g', 'k_a', 'k_e', 'duration', 'input')
  out = ode(y = state, times = times, func = model, parms = parms)
  return(as.matrix(out))
}


# use history matching to calibrate model for a 75kg male who feels a slight
# effect after one beer for between 1 and 3 hours -- that means maximum blood
# alcohol between 4.5 and 13.5 (feeling slightly tipsy after 1 beer), and drops
# to below 4.5 between 1 and 3 hours


# find extremes via one-at-a-time and visual inspection
with(as.data.frame(sim(c(.05, 2, 3, .5, 28))), plot(time, blood)) # maximum is c. 3.8
with(as.data.frame(sim(c(.05, 2, .2, .5, 28))), plot(time, blood)) # duration is c. 6 hours 
with(as.data.frame(sim(c(0, 2, .5, .5, 28))), plot(time, blood)) # looks ok, so start k_g=0
with(as.data.frame(sim(c(3, 2, .5, .5, 28))), plot(time, blood)) # maximum too low
with(as.data.frame(sim(c(.05, 0.5, .5, .5, 28))), plot(time, blood)) # maximum low and duration too long
with(as.data.frame(sim(c(.05, 10, .5, .5, 28))), plot(time, blood)) # maximum low and duration too long


# physical insights:
# * all rates > 0
# * low/slow maximum blood conc when k_a is low, k_g and k_e are high
# * high/fast maximum blood conc when k_a is high, k_g and k_e are low
# * expect flow from gi to blood to be faster than elimination, i.e. k_a > k_e
# and k_g

# better way: experimental design and linear model
design0 = 
  crossing(k_g = c(.02, .1), 
           k_a = c(1, 3),
           k_e = c(.3, .7)) %>%
  mutate(duration = 0.5, input = 28)
# for each parameter setting, calculate maximum blood concentration, and time
# to drop back below 4.5
max_blood = numeric(nrow(design0))
up_time = numeric(nrow(design0))
for (ii in 1:nrow(design0)) {
  out_ = sim(design0[ii, ])
  time_ = out_[, 'time']
  blood_ = out_[, 'blood']
  max_blood[ii] = max(blood_)
  i_dur_ = tail(which(blood_ > 4.5), 1) 
  up_time[ii] = ifelse(length(i_dur_) == 0, NA, time_[i_dur_])
}
design0 = design0 %>%
  mutate(max_blood = max_blood, up_time = up_time)
# fit linear models  
lm(max_blood ~ k_g + k_a + k_e, data=design0)
lm(up_time ~ k_g + k_a + k_e, data=design0)

# magnitude of derivative of up_time and max_blood wrt to parameters is roughly
# similar (about 3:1:5), which should be reflected in the parameter ranges.

# starting from central values (.06, 2, .5) how much do I have to vary each
# parameter in each direction to make it past the minimum/maximum?
# 8.3 - 3.3 * .06 + 1.3 * 2 - 5 * .5 -> 8.2
# * to get to around 4 we can increase k_g to about 1, decrease k_a to almost
# 0, or increase k_e to about 1.2
# * to get to around 13, we can only increase k_a to about 6

# start with k_g ~ U(0, 1), k_a ~ U(0,6) k_e ~ U(0, 1.5)
set.seed(123)
n = 500
par_mat = cbind(k_a = runif(n, 0, 1),
                k_g = runif(n, 0, 10),
                k_e = runif(n, 0, 2),
                duration = 0.5,
                input = 28)

# for each parameter setting, store maximum blood concentration, and time to
# drop back below 4.5
max_blood = numeric(n)
up_time = numeric(n)
for (ii in 1:n) {
  out_ = sim(par_mat[ii, ])
  time_ = out_[, 'time']
  blood_ = out_[, 'blood']
  max_blood[ii] = max(blood_)
  i_dur_ = tail(which(blood_ > 4.5), 1) 
  up_time[ii] = ifelse(length(i_dur_) == 0, 0, time_[i_dur_])
}

# history matching result
hm_res = as_tibble(par_mat) %>%
  mutate(max_blood = max_blood, up_time = up_time) %>%
  mutate(nroy = max_blood > 4.5 & max_blood < 13.5 & up_time > 1 & up_time < 3)

ggpairs(hm_res, columns = c('k_a', 'k_g', 'k_e'), aes(colour=nroy))

# simulate and plot blood alcohol for the nroy parameters
par_mat_nroy = hm_res %>% 
  filter(nroy) %>% 
  select(k_a, k_g, k_e, duration, input) %>% 
  as.matrix

# for each of the nroy parameters plot the blood alcohol concentration curve
res = NULL
for (ii in 1:nrow(par_mat_nroy)) {
  out_ = sim(par_mat_nroy[ii, ])
  res_ii = tibble(sample = ii, time = out_[, 'time'], blood = out_[, 'blood'])
  if (ii == 1) {
    res = res_ii
  } else {
    res = bind_rows(res, res_ii)
  }
}

ggplot(res) + 
  geom_line(aes(x=time, y=blood, group=sample), alpha=.2) +
  geom_hline(yintercept=c(4.5, 13.5), lty=2) +
  geom_vline(xintercept=c(1, 3), lty=2) 

# histogram of blood alcohol amount after 3 hours
res %>% filter(time == 3) %>%
ggplot() + geom_histogram(aes(x=blood), breaks=seq(0,5,.5))


######################################################################
# applying the model to different conditions
######################################################################

# for each of the nroy parameters plot the blood alcohol concentration curve
# under the new scenario
res2 = NULL
for (ii in 1:nrow(par_mat_nroy)) {
  parms = par_mat_nroy[ii, ]
  parms[4:5] = c(2, 14) # 2 pint in 2 hours
  out_ = sim(parms) 
  res_ii = tibble(sample = ii, time = out_[, 'time'], blood = out_[, 'blood'])
  if (ii == 1) {
    res2 = res_ii
  } else {
    res2 = bind_rows(res2, res_ii)
  }
}

ggplot(res2) + 
  geom_line(aes(x=time, y=blood, group=sample), alpha=.2) + 
  geom_hline(yintercept=c(4.5, 13.5), lty=2)

# probability of being more than "tipsy" after 2 beers in 2 hours
res2 %>% 
  group_by(sample) %>%
  summarise(max = max(blood)) %>%
  ggplot() + 
    stat_ecdf(aes(x=max)) +
    geom_vline(xintercept=13.5, lty=2)
# probability is about 20% 




