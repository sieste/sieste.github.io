# initiliase list of model parameters
agents = within(list(), {
  n_agents = 1000  # number of agents
  p_inf = 0.5      # probability of infection on contact
  r_inf = 0.02     # radius that defines "contact", as fraction of domain width
  t_rec = 20       # time to recovery
  w_step = 0.02    # maximum step width in each direction, as fraction of domain width
})

# initialise state variables (agent coordinates, infection state, infection
# time). initially, just one agent at the center is infected.
agents = within(agents, {
  # initial locations are uniformly distributed
  xy = cbind(runif(n_agents), runif(n_agents))
  # all are susceptible (state = 0)
  state = rep(0, n_agents)
  time = rep(NA, n_agents)
  # i=1 is patient zero located at center
  xy[1, ] = c(0.5, 0.5)
  state[1] = 1
  time[1] = t_rec
  # initialise history object
  history = matrix(nrow=0, ncol=3)
})

# agent updating function (move, infect, recover)
update = function(agents) within(agents, {
  #
  # move agents randomly, ensure they don't leave the domain
  rand_step = matrix(runif(2*n_agents, -w_step, w_step), ncol=2)
  xy = pmax(pmin(xy + rand_step, 1), 0)
  # 
  # calculate all pairwise distances and identify neighbors
  distmat = as.matrix(dist(xy))
  diag(distmat) = Inf # to exclude self from neighbors
  neighbors = which(distmat <= r_inf, arr.ind = TRUE)
  # randomly infect susceptible neighbors
  for (ii in seq_len(nrow(neighbors))) {
    i_from = neighbors[ii, 1]
    i_to = neighbors[ii, 2]
    if (state[i_from] == 1 & state[i_to] == 0) {
      state[i_to] = ifelse(runif(1) < p_inf, 1, 0)
    }
  }
  #
  # decrement recovery time of infected, initialise recovery time of newly
  # infected, and recover agents where recovery time is zero
  time = pmax(time - 1, 0)
  time[ is.na(time) & state == 1 ] = t_rec
  state[ time == 0 ] = 2
  # update history
  new_row = c(s=mean(state==0), i=mean(state==1), r=mean(state==2))
  history = rbind(history, new_row, deparse.level=0)
})

# visualisation function: scatter plot of agents and time series of SIR
# history. use dev.hold and dev.flush to avoid flickering plots.
visualise = function(agents) with(agents, {
  dev.hold()
  layout(c(rep(1,3), 2))
  # plot agents
  par(mar=c(0,0,0,0))
  plot(xy, col=c('blue','red','green')[state+1], 
       pch = 16, ann=FALSE, axes=FALSE, asp=1,
       xlim=c(0,1), ylim=c(0,1))
  # plot history
  par(mar=c(3,3,3,3))
  matplot(history, type='l', las=1,
          col=c('blue','red','green'), lty=1, ylim=c(0,1),
          main = paste(tail(history, 1), collapse='|'))
  dev.flush()
})

# main loop: simulate, visualise, stop when no change for some time
graphics.off(); x11()
while(1) {
  agents = update(agents)
  visualise(agents)
  # stop if state doesn't vary for 50 timesteps
  past = tail(agents$history, 50)
  var_past = apply(past, 2, var)
  if (nrow(past) == 50 && all(var_past == 0)) break
}

