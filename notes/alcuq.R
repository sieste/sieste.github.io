library(tidyverse)
library(GGally)
library(deSolve)

# model parameters
parameters = c(
  k_a = 2.0,      # per hour, absorption rate from GI tract into blood
  k_g = 0.05,     # per hour, GI tract own elimination rate
  k_e = 0.5,      # per hour, elimination rate from blood by liver
  duration = 0.5, # hours of dosing
  input = 28      # grams of alcohol per hour of dosing
)

# initial state
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
times = seq(0, 10, by = 0.01)
out = ode(y = state, times = times, func = model, parms = parameters) %>% 
      as.data.frame %>%
      pivot_longer(-time, names_to='compartment', values_to='concentration')

ggplot(out) + geom_line(aes(x=time, y=concentration, colour=compartment))



# only interested in 3 "internal" parameters, "dosing" parameters are fixed
sim = function(parms) {
  # parms is a 3-vector of 3 rate parameters
  the_parameters = parameters
  the_parameters['k_a'] = parms[1]
  the_parameters['k_g'] = parms[2]
  the_parameters['k_e'] = parms[3]
  # the function simulates the 2 compartment model and returns the maximum
  # concentration obtained in the 2nd compartment
  out = ode(y = state, times = times, func = model, parms = the_parameters)
  return(as.matrix(out))
}


# use history matching to calibrate model for a 75kg male who feels a slight
# effect after one beer for between 1 and 3 hours -- that means maximum blood
# alcohol between 4.5 and 13.5 (feeling slightly tipsy after 1 beer), and drops
# to below 4.5 between 1 and 3 hours

# find extremes via one-at-a-time
with(as.data.frame(sim(c(2, .05, 3))), plot(time, blood)) # maximum is c. 3.8
with(as.data.frame(sim(c(2, .05, .2))), plot(time, blood)) # duration is c. 6 hours 
with(as.data.frame(sim(c(2, 0, .5))), plot(time, blood)) # looks ok, so start k_g=0
with(as.data.frame(sim(c(2, 3, .5))), plot(time, blood)) # maximum too low
with(as.data.frame(sim(c(0.5, .05, .5))), plot(time, blood)) # maximum low and duration too long
with(as.data.frame(sim(c(10, .05, .5))), plot(time, blood)) # maximum low and duration too long


# start with k_a ~ U(0.5,10) k_g ~ U(0,3) k_e ~ U(0.2, 3)
set.seed(123)
n = 500
par_mat = cbind(k_a = runif(n, 0.5, 10),
                k_g = runif(n, 0, 3),
                k_e = runif(n, 0.2, 3))

# for each parameter setting, store maximum blood concentration, and time to
# drop back below 4.5
max_blood = numeric(n)
duration = numeric(n)
for (ii in 1:n) {
  out_ = sim(par_mat[ii, ])
  time_ = out_[, 'time']
  blood_ = out_[, 'blood']
  max_blood[ii] = max(blood_)
  i_dur_ = tail(which(blood_ > 4.5), 1) 
  duration[ii] = ifelse(length(i_dur_) == 0, 0, time_[i_dur_])
}

# history matching result
hm_res = as_tibble(par_mat) %>%
  mutate(max_blood = max_blood, duration = duration) %>%
  mutate(nroy = max_blood > 4.5 & max_blood < 13.5 & duration > 1 & duration < 3)

ggpairs(hm_res, columns = c('k_a', 'k_g', 'k_e'), aes(colour=nroy))

# simulate and plot blood alcohol for the nroy parameters
par_mat_nroy = hm_res %>% filter(nroy) %>% select(k_a, k_g, k_e) %>% as.matrix

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

ggplot(res) + geom_line(aes(x=time, y=blood, group=sample), alpha=.2)

res %>% filter(time == 3) %>%
ggplot() + geom_histogram(aes(x=blood), breaks=seq(0,5,.5))


