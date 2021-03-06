#' ##########################################################
#' ### **Description:** Functions Rendered for MIDA dashboard
#' ##########################################################
#'
#----------------------------------------------------------
#'
#' **Sections:**
#' 
#' **1.0** SIR Model - without vital dynamics
#' 
#' **1.1** SIR Model - with vital dynamics
#' 
#' **1.2** SIR Model - with heterogeneity susceptibility
#' 
#' **2.0** SIS Model
#' 
#' **3.0** SEIR Model
#' 
#' **4.0** SIR Model - stochastic
#' 
#' ----------------------------------------------------------
#'
#' **Compartmental Model Functions**
#' 
#' Sections 1-4 contain functions to calculate the epidemic tracjectory
#' across the corresponding SIR/SIS/SIER population type, with or
#' without vital dynamics, with or without heterogeneity in 
#' susceptibility or infectivity or deterministcally or stochastically.
#' 
#' --------------------------------------------------------
#'
#' **Plot_ly Functions**
#' 
#' Sections 1-4 contain functions to render plot_ly's of the
#' epidemic tractories corresponding with the asscociated
#' compartmental model functions
#' 
#' --------------------------------------------------------
#'
#' **Parameters**
#' 
#' - beta = transmission rate
#' 
#' - alpha = recovery rate
#' 
#' - gamma = exit rate from exposed compartment
#' 
#' - mu = birth/death rate
#' 
#' --------------------------------------------------------
#'
#'
#' ----------------------------------------------------------
#' ----------------------------------------------------------
#' **1.0** SIR Model - without vital dynamics
#' ----------------------------------------------------------
#' ----------------------------------------------------------

SIR <- function(populations, beta, alpha, timestep){
  
  # first extract the current population sizes from the data frame
  latest <- tail(populations, 1)
  
  # calculate total size of population, effective beta and alpha
  pop.size <- latest$Susceptibles + latest$Infecteds + latest$Recovereds
  effective.beta <- beta * timestep
  effective.alpha <- alpha * timestep
  
  # calculate changes to populations
  new.infecteds <- effective.beta * latest$Susceptibles * latest$Infecteds / pop.size
  new.recovereds <- effective.alpha * latest$Infecteds
   
  # update population
  next.susceptibles <- latest$Susceptibles - new.infecteds
  next.infecteds <- latest$Infecteds - new.recovereds + new.infecteds
  next.recovereds <- latest$Recovereds + new.recovereds
  
  # add new row onto populations data frame and return
  next.populations <- rbind(populations,
                            data.frame(Time=latest$Time + timestep,
                                       Susceptibles=next.susceptibles,
                                       Infecteds=next.infecteds,
                                       Recovereds=next.recovereds))
}

plot.populations.SIR <- function(populations){
  
  py <- plot_ly(populations, x = ~Time)
  py <- py %>% add_trace(y = ~Susceptibles, name = "Susceptibles", mode = "lines",
                         line = list(color = "#1c9099", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles: ", Susceptibles, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                         line = list(color = "#d95f0e", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                         line = list(color = "#636363", width = 3), hoverinfo = "text",
                         text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% layout(
    legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2),
    xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
    yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  
  return(py)
}

#' ----------------------------------------------------------
#' ----------------------------------------------------------
#' **1.1** SIR Model - with vital dynamics
#' ----------------------------------------------------------
#' ----------------------------------------------------------

SIR.vd <- function(populations, beta, alpha, mu, timestep){
  
  # first extract the current population sizes from the data frame
  latest <- tail(populations, 1)
  
  # calculate total size of population, effective beta, alpha and mu
  pop.size <- latest$Susceptibles + latest$Infecteds + latest$Recovereds
  effective.beta <- beta * timestep
  effective.alpha <- alpha * timestep
  effective.mu <- mu * timestep
  
  # calculate changes to populations
  new.infecteds <- effective.beta * latest$Susceptibles * latest$Infecteds / pop.size
  new.recovereds <- effective.alpha * latest$Infecteds
  
  # vital dynamics
  N.births <- effective.mu * pop.size
  S.deaths <- effective.mu * latest$Susceptibles
  I.deaths <- effective.mu * latest$Infecteds
  R.deaths <- effective.mu * latest$Recovereds
  
  # update population
  next.susceptibles <- latest$Susceptibles - new.infecteds + N.births - S.deaths
  next.infecteds <- latest$Infecteds - new.recovereds + new.infecteds - I.deaths
  next.recovereds <- latest$Recovereds + new.recovereds - R.deaths
  
  # add new row onto populations data frame and return
  next.populations <- rbind(populations,
                            data.frame(Time=latest$Time + timestep,
                                       Susceptibles=next.susceptibles,
                                       Infecteds=next.infecteds,
                                       Recovereds=next.recovereds))
}

plot.populations.SIR.vd <- function(populations){
  
  py <- plot_ly(populations, x = ~Time)
  py <- py %>% add_trace(y = ~Susceptibles, name = "Susceptibles", mode = "lines",
                         line = list(color = "#1c9099", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles: ", Susceptibles, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                         line = list(color = "#d95f0e", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                         line = list(color = "#636363", width = 3), hoverinfo = "text",
                         text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% layout(
    legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2),
    xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
    yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  
  return(py)
}

#' ----------------------------------------------------------
#' ----------------------------------------------------------
#' **1.2** SIR Model - with heterogeneity susceptibility
#' ----------------------------------------------------------
#' ----------------------------------------------------------

SIR.s <- function(populations, beta.L, beta.H, alpha, timestep){
  
  # first extract the current population sizes from the data frame
  latest <- tail(populations, 1)
  
  # calculate total size of population, effective betas and alpha
  pop.size <- latest$Susceptibles.L + latest$Susceptibles.H + latest$Infecteds + latest$Recovereds
  effective.beta.L <- beta.L * timestep
  effective.beta.H <- beta.H * timestep
  effective.alpha <- alpha * timestep
  
  # calculate changes to populations
  new.infecteds.L <- effective.beta.L * latest$Susceptibles.L * latest$Infecteds / pop.size
  new.infecteds.H <- effective.beta.H * latest$Susceptibles.H * latest$Infecteds / pop.size
  new.recovereds <- effective.alpha * latest$Infecteds
  
  # update population
  next.susceptibles.L <- latest$Susceptibles.L - new.infecteds.L
  next.susceptibles.H <- latest$Susceptibles.H - new.infecteds.H
  next.infecteds <- latest$Infecteds - new.recovereds + new.infecteds.L + new.infecteds.H
  next.recovereds <- latest$Recovereds + new.recovereds
  
  # add new row onto populations data frame and return
  next.populations <- rbind(populations,
                            data.frame(Time=latest$Time + timestep,
                                       Susceptibles.L=next.susceptibles.L,
                                       Susceptibles.H=next.susceptibles.H,
                                       Infecteds=next.infecteds,
                                       Recovereds=next.recovereds))
}

plot.populations.SIR.s <- function(populations){
  
  py <- plot_ly(populations, x = ~Time)
  py <- py %>% add_trace(y = ~Susceptibles.L, name = "Susceptibles (S<sub>L</sub>)", mode = "lines",
                         line = list(color = "#1c9099", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles (S<sub>L</sub>): ", Susceptibles.L, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Susceptibles.H, name = "Susceptibles (S<sub>H</sub>)", mode = "lines",
                         line = list(color = "#31a354", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles (S<sub>H</sub>): ", Susceptibles.H, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                         line = list(color = "#d95f0e", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                         line = list(color = "#636363", width = 3), hoverinfo = "text",
                         text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% layout(
    legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2),
    xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
    yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  
  return(py)
}

#' --------------------------------------------------------------------------
#' --------------------------------------------------------------------------
#' **1.3** SIR Model - with heterogeneity in susceptibility and infectivity
#' --------------------------------------------------------------------------
#' --------------------------------------------------------------------------

SIR.si <- function(populations, beta.LL, beta.HH, beta.LH, beta.HL, qL, qH, alpha, timestep){
  
  # First extract the current population sizes from the data frame
  latest <- tail(populations, 1)
 
   # calculate total size of population, effective betas and alpha
  pop.size <- latest$Susceptibles.L + latest$Susceptibles.H +
    latest$Infecteds.L + latest$Infecteds.H + latest$Recovereds
  effective.beta.LL <- beta.LL * timestep
  effective.beta.LH <- beta.LH * timestep
  effective.beta.HH <- beta.HH * timestep
  effective.beta.HL <- beta.HL * timestep
  effective.alpha <- alpha * timestep
  
  # calculate changes to populations
  susceptibles.L <- ((effective.beta.LL * latest$Susceptibles.L * latest$Infecteds.L) / pop.size) + 
    ((effective.beta.LH * latest$Susceptibles.L * latest$Infecteds.H) / pop.size)
  susceptibles.H <- ((effective.beta.HH * latest$Susceptibles.H * latest$Infecteds.H) / pop.size) + 
    ((effective.beta.HL * latest$Susceptibles.H * latest$Infecteds.L) / pop.size)
  new.infecteds.L <- (qL * susceptibles.L) + (qL * susceptibles.H)
  new.infecteds.H <- (qH * susceptibles.L) + (qH * susceptibles.H)
  new.recovereds.L <- effective.alpha * latest$Infecteds.L
  new.recovereds.H <- effective.alpha * latest$Infecteds.H
  
  # update population
  next.susceptibles.L <- latest$Susceptibles.L - susceptibles.L
  next.susceptibles.H <- latest$Susceptibles.H - susceptibles.H
  next.infecteds.L <- latest$Infecteds.L + new.infecteds.L - new.recovereds.L
  next.infecteds.H <- latest$Infecteds.H + new.infecteds.H - new.recovereds.H
  next.recovereds <- latest$Recovereds + new.recovereds.L + new.recovereds.H
  
  # add new row onto populations data frame and return
  next.populations <- rbind(populations,
                            data.frame(Time=latest$Time + timestep,
                                       Susceptibles.L=next.susceptibles.L,
                                       Susceptibles.H=next.susceptibles.H,
                                       Infecteds.L=next.infecteds.L,
                                       Infecteds.H=next.infecteds.H,
                                       Recovereds=next.recovereds))
}

plot.populations.SIR.si <- function(populations){
  
  py <- plot_ly(populations, x = ~Time)
  py <- py %>% add_trace(y = ~Susceptibles.L, name = "Susceptibles (S<sub>L</sub>)", mode = "lines",
                         line = list(color = "#1c9099", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles (S<sub>L</sub>): ", Susceptibles.L, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Susceptibles.H, name = "Susceptibles (S<sub>H</sub>)", mode = "lines",
                         line = list(color = "#31a354", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles (S<sub>H</sub>): ", Susceptibles.H, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds.L, name = "Infecteds (I<sub>L</sub>)", mode = "lines",
                         line = list(color = "#d95f0e", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds (I<sub>L</sub>): ", Infecteds.L, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds.H, name = "Infecteds (I<sub>H</sub>)", mode = "lines",
                         line = list(color = "#54278f", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds (I<sub>H</sub>): ", Infecteds.H, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                         line = list(color = "#636363", width = 3), hoverinfo = "text",
                         text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% layout(
    legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.3),
    xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
    yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  
  return(py)
}

#' ----------------------------------------------------------
#' ----------------------------------------------------------
#' **2.0** SIS Model
#' ----------------------------------------------------------
#' ----------------------------------------------------------

SIS <- function(populations, beta, alpha, timestep){
  
  # first extract the current population sizes from the data frame
  latest <- tail(populations, 1)
  
  # calculate total size of population, effective beta and alpha
  pop.size <- latest$Susceptibles + latest$Infecteds 
  effective.beta <- beta * timestep
  effective.alpha <- alpha * timestep
  
  # calculate changes to populations
  new.infecteds <- effective.beta * latest$Susceptibles * latest$Infecteds / pop.size
  new.susceptibles <- effective.alpha * latest$Infecteds
  
  # update population
  next.susceptibles <- latest$Susceptibles + new.susceptibles - new.infecteds
  next.infecteds <- latest$Infecteds - new.susceptibles + new.infecteds
  
  # Add new row onto populations data frame and return
  next.populations <- rbind(populations,
                            data.frame(Time=latest$Time + timestep,
                                       Susceptibles=next.susceptibles,
                                       Infecteds=next.infecteds))
}

plot.populations.SIS <- function(populations){
  
  py <- plot_ly(populations, x = ~Time)
  py <- py %>% add_trace(y = ~Susceptibles, name = "Susceptibles", mode = "lines",
                         line = list(color = "#1c9099", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles: ", Susceptibles, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                         line = list(color = "#d95f0e", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% layout(
    legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2),
    xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
    yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  
  return(py)
}


#' ----------------------------------------------------------
#' ----------------------------------------------------------
#' **3.0** SEIR Model
#' ----------------------------------------------------------
#' ----------------------------------------------------------

SEIR <- function(populations, beta, alpha, gamma, timestep){
  
  # First extract the current population sizes from the data frame
  latest <- tail(populations, 1)
  
  # Calculate total size of population, effective beta, gamma and alpha
  pop.size <- latest$Susceptibles + latest$Exposeds + latest$Infecteds + latest$Recovereds
  effective.beta <- beta * timestep   # transmission
  effective.gamma <- gamma * timestep # latent
  effective.alpha <- alpha * timestep # recovery
  
  # Calculate changes to populations
  new.exposeds <- effective.beta *
    latest$Susceptibles * latest$Infecteds / pop.size
  new.infecteds <- effective.gamma * latest$Exposeds
  new.recovereds <- effective.alpha * latest$Infecteds
  
  # update population
  next.susceptibles <- latest$Susceptibles - new.exposeds
  next.expososeds <- latest$Exposeds - new.infecteds + new.exposeds
  next.infecteds <- latest$Infecteds - new.recovereds + new.infecteds
  next.recovereds <- latest$Recovereds + new.recovereds
  
  # Add new row onto populations data frame and return
  next.populations <- rbind(populations,
                            data.frame(Time=latest$Time + timestep,
                                       Susceptibles=next.susceptibles,
                                       Exposeds=next.expososeds,
                                       Infecteds=next.infecteds,
                                       Recovereds=next.recovereds))
}

plot.populations.SEIR <- function(populations){
  
  py <- plot_ly(populations, x = ~Time)
  py <- py %>% add_trace(y = ~Susceptibles, name = "Susceptibles", mode = "lines",
                         line = list(color = "#1c9099", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles: ", Susceptibles, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Exposeds, name = "Exposeds", mode = "lines",
                         line = list(color = "#31a354", width = 3), hoverinfo = "text",
                         text = ~paste("Exposeds: ", Exposeds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                         line = list(color = "#d95f0e", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                         line = list(color = "#636363", width = 3), hoverinfo = "text",
                         text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% layout(
    legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2),
    xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
    yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  
  return(py)
}

#' ----------------------------------------------------------
#' ----------------------------------------------------------
#' **4.0** SIR Model - stochastic
#' ----------------------------------------------------------
#' ----------------------------------------------------------

SIR.stochastic <- function(populations, beta, alpha, timestep){
  
  # First extract the current population sizes from the data frame
  latest <- tail(populations, 1)
  
  # Calculate total size of population, effective beta and effective alpha
  pop.size <- latest$Susceptibles + latest$Infecteds + latest$Recovereds
  effective.beta <- beta * timestep
  effective.alpha <- alpha * timestep
  
  # individual transmission probability
  individual.transmission.prob <- effective.beta * latest$Infecteds/pop.size
  
  # add randomness to make stochastic
  new.recovereds <- rbinom(1, latest$Infecteds, effective.alpha)
  new.infecteds <- rbinom(1, latest$Susceptibles, individual.transmission.prob)        
  
  # update populations 
  next.susceptibles <- latest$Susceptibles - new.infecteds
  next.infecteds <-  latest$Infecteds + new.infecteds - new.recovereds
  next.recovereds <- latest$Recovereds + new.recovereds
  next.time <- latest$Time + timestep
  
  # add new row onto populations data frame and return
  next.populations <- rbind(populations,
                            data.frame(Time= next.time,
                                       Susceptibles=next.susceptibles,
                                       Infecteds=next.infecteds,
                                       Recovereds=next.recovereds))
}

# plotting single or multiple stochastic simulations
plot.populations.SIR.stochastic <- function(populations, Nsims){
  if(Nsims > 1){
    # for multiple stochastic simulations
    py <- plot_ly(populations, x = ~Time)
    py <- py %>% add_trace(y = ~Susceptibles, name = "Susceptibles", mode = "lines",
                           transforms = list(list(type = 'groupby', groups = ~Sim)),
                           showlegend=FALSE, 
                           legendgroup = ~Susceptibles,
                           line = list(color = "#1c9099", width = 2), hoverinfo = "text",
                           text = ~paste("Susceptibles: ", Susceptibles, "<br>Time: ", round(Time, digits = 3), "<br>Sim: ", Sim))
    py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                           transforms = list(list(type = 'groupby', groups = ~Sim)),
                           showlegend=FALSE, 
                           legendgroup = ~Infecteds,
                           line = list(color = "#d95f0e", width = 2), hoverinfo = "text",
                           text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3), "<br>Sim: ", Sim))
    py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                           transforms = list(list(type = 'groupby', groups = ~Sim)),
                           showlegend=FALSE, 
                           legendgroup = ~Recovereds,
                           line = list(color = "#636363", width = 2), hoverinfo = "text",
                           text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3), "<br>Sim: ", Sim))
    py <- py %>% layout(
      legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2, traceorder = "grouped"),
      xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
      yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  }else{
    # just one stochastic simulation
    py <- plot_ly(populations, x = ~Time)
    py <- py %>% add_trace(y = ~Susceptibles, name = "Susceptibles", mode = "lines",
                           line = list(color = "#1c9099", width = 2), hoverinfo = "text",
                           text = ~paste("Susceptibles: ", Susceptibles, "<br>Time: ", round(Time, digits = 3)))
    py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                           line = list(color = "#d95f0e", width = 2), hoverinfo = "text",
                           text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3)))
    py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                           line = list(color = "#636363", width = 2), hoverinfo = "text",
                           text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3)))
    py <- py %>% layout(
      legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2),
      xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
      yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  }
  
  return(py)
}

# plot for average stochastic simulations
plot.populations.SIR.stochastic_average <- function(populations){
  
  py <- plot_ly(populations, x = ~Time)
  py <- py %>% add_trace(y = ~Susceptibles, name = "Susceptibles", mode = "lines",
                         line = list(color = "#1c9099", width = 3), hoverinfo = "text",
                         text = ~paste("Susceptibles: ", Susceptibles, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Infecteds, name = "Infecteds", mode = "lines",
                         line = list(color = "#d95f0e", width = 3), hoverinfo = "text",
                         text = ~paste("Infecteds: ", Infecteds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% add_trace(y = ~Recovereds, name = "Recovereds", mode = "lines",
                         line = list(color = "#636363", width = 3), hoverinfo = "text",
                         text = ~paste("Recovereds: ", Recovereds, "<br>Time: ", round(Time, digits = 3)))
  py <- py %>% layout(
    legend = list(orientation = 'h',  xanchor = "center", x = .5, y = 1.2),
    xaxis = list(title = "Time (days)", showline = TRUE, showgrid = FALSE, zeroline = FALSE),
    yaxis = list(side = "left", title = "Number of individuals", showline = TRUE, showgrid = FALSE, zeroline = FALSE))
  
  return(py)
}