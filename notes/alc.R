library(tidyverse)
library(deSolve)

# model parameters
parameters = c(
  k_g = 1.0,      # per hour, GI tract elimination rate (not into blood)
  k_a = 2.0,      # per hour, absorption rate from GI tract into blood
  k_e = 3.0,      # per hour, elimination rate from blood by liver
  duration = 0.5, # hours of dosing
  input = 28      # grams of alcohol per hour of dosing
)

# initial state
state = c(dose = 0, gi = 0, blood = 0)

# this is the 2-compartment differential equations model function, implemented
# in the correct format to be used with deSolve
model = function(t, state, parameters) {
  # state: (dose, gi, blood)
  # parameters: (k_g, k_a, k_e, duration, input)
  with(as.list(c(state, parameters)),{
    dose = ifelse(t <= duration, input, 0)  # dosing
    dgi = -k_a * gi - k_g * gi + dose   # GI tract equation
    dblood = k_a * gi - k_e * blood     # blood equation
    return(list(c(dose, dgi, dblood)))  # derivatives
  }) 
}


# simulate model for 12 hours
times = seq(0, 12, by = 0.05)
out = ode(y = state, times = times, func = model, parms = parameters) 

# plot amount in each compartment over time
out %>% 
  as.data.frame %>%
  pivot_longer(c(dose, gi, blood), 
               names_to='compartment', 
               values_to='amount [g]') %>%
  filter(time <= 5) %>%
  ggplot() + 
    geom_line(aes(x=time, y=`amount [g]`, colour=compartment)) 


