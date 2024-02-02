library(tidyverse)
library(GGally)
library(deSolve)

# model parameters, based on an "educated guess"
parameters = c(
  k_g = 1.0,      # per hour, GI tract elimination rate (not into blood)
  k_a = 2.0,      # per hour, absorption rate from GI tract into blood
  k_e = 3.0,      # per hour, elimination rate from blood by liver
  duration = 0.5, # hours of dosing
  input = 28      # grams of alcohol per hour of dosing
)

# initial state is all 0 ("sober")
state = c(dose = 0, gi = 0, blood = 0)

# this is the 2-compartment differential equations model function, implemented
# in the format to be used with deSolve
model = function(t, state, parameters) {
  # state = c(dose, gi, blood)
  # parameters = c(k_g, k_a, k_e, duration, input)
  with(as.list(c(state, parameters)),{
    dose = ifelse(t <= duration, input, 0)  # dosing
    dgi = -k_a * gi - k_g * gi + dose   # GI tract equation
    dblood = k_a * gi - k_e * blood     # blood equation
    return(list(c(dose, dgi, dblood)))  # derivatives
  }) 
}

# simulate model, immediately convert output to long data frame
times = seq(0, 12, by = 0.05)
out = ode(y = state, times = times, func = model, parms = parameters) %>% 
      as.data.frame %>%
      pivot_longer(c(gi, blood), names_to='compartment', values_to='concentration')

ggplot(out) + geom_line(aes(x=time, y=concentration, colour=compartment))
# gi tract concentration initially increases according to the dosing function,
# here 28 grams per hour for half an hour. but the full 14 grams are never
# reached because of the elimination (k_g) and the transfer to the blood (k_a).
# the blood alcohol increases slower because of the finite transfer rate from
# gi tract into blood stream. after the dosing stops, gi tract concentration
# starts to decrease, but blood concentration still increases for a bit before
# it slowly drops due to elimination, mostly via the liver but also via lungs,
# skin, and cell metabolism (k_e). 



# helper function that takes model parameters and returns a 12-hour simulation
# (matrix with 4 columns: time, dose, gi, blood)
sim = function(parms) {
  stopifnot(length(parms) == 5)
  names(parms) = c('k_g', 'k_a', 'k_e', 'duration', 'input')
  out = ode(y = state, times = times, func = model, parms = parms)
  return(as.matrix(out))
}
head(sim(parameters))

# https://en.wikipedia.org/wiki/Short-term_effects_of_alcohol_consumption
# BAC 0.00-0.03 no noticable effects
# BAC 0.03-0.06 mild euphoria, relaxation 
# BAC 0.06-0.10 disinhibition, extraversion, impaired reasoning
# BAC 0.10-0.20 boisterousness, spins, slurred speech, vomiting
# BAC 0.20-     better stay away

# https://en.wikipedia.org/wiki/Blood_volume
# our simulation is amount of alcohol in blood, so need to convert. BAC of 1
# means there is 1g of alcohol per 100ml of blood, or 10g/l. men have about
# 0.075l of blood per kg body weight, women 0.065l/kg. 

# we want to calibrate our model. that means finding those parameters settings
# that produce "realistic" simulations. assume we only have rather vague
# calibration data as follows. a 75kg male reports that he usually feels a
# slight effect after drinking one pint of beer in around 30 minutes, and this
# effect becomes unnoticable after between 1 and 3 hours. that means that the
# maximum blood alcohol after ingesting 14g of alcohol is between
# 0.03*10g/l*75kg*0.075l/kg=1.7g and 0.06*10g/l*75kg*0.075l/kg=3.4g, and blood
# alcohol amount drops to below 1.7g at some point between 1 and 3 hours.


# experimental design and linear model (+/-1 on each central value)
design0 = 
  crossing(k_g = c(0, 2), 
           k_a = c(1, 3),
           k_e = c(2, 4)) %>%
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
  i_dur_ = tail(which(blood_ > 1.7), 1) 
  up_time[ii] = ifelse(length(i_dur_) == 0, NA, time_[i_dur_])
}
design0 = design0 %>%
  mutate(max_blood = max_blood, up_time = up_time)
# fit linear models  
lm(max_blood ~ k_g + k_a + k_e, data=design0)
lm(up_time ~ k_g + k_a + k_e, data=design0)

# derivative of max_blood wrt parameters is roughly (-.5,+1,-.5). So a one unit
# increase in k_a increases maximum blood amount by about 1g, and a 2 unit
# increase in k_g or k_e decreases blood amount by 1g. since our calibration
# target range for maximum blood amount is 1.7g to 3.4g, we should vary k_a by
# +/-1 and k_g and k_e by about +/-2 to cover a sufficiently wide range. For
# maximum duration we have smaller effects. A one unit increase in k_g or k_e
# decreases max duration by about 20 minutes. Our target range is 1-3 hours, so
# we should probably consider varying these parameters by +/-3 to cover that
# range. duration is quite insensitive to k_a, so should not be considered,
# basically any value would be acceptable (assuming purely linear effects and
# no interactions). In summary, we should vary the following uncertainty
# distributions seem reasonable: k_g ~ U(0, 5), k_a ~ U(0,4) k_e ~ U(1, 5)
set.seed(123)
n = 1000
par_mat = cbind(k_a = runif(n, 0, 5),
                k_g = runif(n, 0, 4),
                k_e = runif(n, 0, 5),
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
  i_dur_ = tail(which(blood_ > 1.7), 1) 
  up_time[ii] = ifelse(length(i_dur_) == 0, 0, time_[i_dur_])
}

# history matching result
hm_res = as_tibble(par_mat) %>%
  mutate(max_blood = max_blood, up_time = up_time) %>%
  mutate(nroy = max_blood > 1.7 & max_blood < 3.4 & up_time > 1 & up_time < 3)

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
  geom_hline(yintercept=c(1.7, 3.4), lty=2) +
  geom_vline(xintercept=c(1, 3), lty=2) 

# histogram of blood alcohol amount after 3 hours
res %>% filter(time == 3) %>%
ggplot() + geom_histogram(aes(x=blood), breaks=seq(0,1,.1))


######################################################################
# applying the model to different conditions
######################################################################

# for each of the nroy parameters plot the blood alcohol concentration curve
# under the new scenario
res2 = NULL
for (ii in 1:nrow(par_mat_nroy)) {
  parms = par_mat_nroy[ii, ]
  parms[4:5] = c(2, 14) # 14g/hr (1 pint per hour) in 2 hours
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
  geom_hline(yintercept=c(1.7, 3.4), lty=2)

# probability of being more than "tipsy" after 2 beers in 2 hours
res2 %>% 
  group_by(sample) %>%
  summarise(max = max(blood)) %>%
  ggplot() + 
    stat_ecdf(aes(x=max)) +
    geom_vline(xintercept=3.4, lty=2)
# probability is about 40% of being drunk after 2 beer




