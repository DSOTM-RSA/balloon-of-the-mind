# Bayesian Approach Pregenancy


# Part A - the DATA

period_onset <- as.Date(c("2014-07-02", "2014-08-02", "2014-08-29", "2014-09-25",
                          "2014-10-24", "2014-11-20", "2014-12-22", "2015-01-19"))
days_between_periods <- as.numeric(diff(period_onset))


# Part B -  the MODEL

## General Assumptions ##
# The women and man have no prior reason for being infertile
# The women has regular periods
# The couple are actively trying to conceive
# If there is a pregnancy, there are no more periods

## Specific Assumptions ##

# The number of days between periods (days_between_periods) is assumed
# to be normally distibuted with unknown mean (mean_period) and SD (sd_period).

# The probability of getting pregnant during a cyle is assumed to be 0.19 IF
# the couple is fertile (is_fertile) - not all couple are fertile, and if you
# are no the the probability of getting pregnant is 0. If fertility is coded
# as 0-1 then this can be compactely written as 0.19 * is_fertile.

# The probability if failing to conceive for a certain number of periods (n_non_pregnant_periods)
# is then (1 - 0.19 * is_fertile)^n_non_pregnant_periods.

# Finally, if you are not going to be pregannt this cycle, then the number of days 
# from your last to your next period (next_period) is going to be more than the
# current number of days since the last period (day_since_last_period)...
# That is, the probability of next_period < days_since_last_period is ZERO.


## The Likelyhood Function ##

# This is a function given some PARAMETERS, and some DATA calculates the probability
# of the DATA, given those PARAMETERS: or more commonly "something proportional to a probability
# that is a LIKELYHOOD".
# And because this likelyhood can very tiny, I need to calcualte it on a log scale
# to avoid numeriaal issues.

# In R this is done by:
# a. Make a  function taking the DATA, and the PARAMETERS as arguments
# b. You initialize the likelyhood to 1, corresponding to 0.0 on the log scale (log_like <-0.0).

# c. Use probability density functions in R (dnomr, dbinom, dpois) to calculate the
# likelyhoods of the different parts of the model. You then MULTIPLE these likelyhoods together.
# On the log scale - this corresponds to adding the log likelyoods to log_like.

# d. Make the d* fucntions return log likelyhoods, by using the arguement log = TRUE
# Also remember a kilehood of 0.0 corresponds to a log-likelyhood of -Inf

# For the above scenario this is given by the below likelyood function:

calc_log_like <- function(days_since_last_period, days_between_periods,
                          mean_period, sd_period, next_period,
                          is_fertile, is_pregnant) {
  n_non_pregnant_periods <- length(days_between_periods)
  log_like <- 0
  if(n_non_pregnant_periods > 0) {
    log_like <- log_like + sum( dnorm(days_between_periods, mean_period, sd_period, log = TRUE) )
  }
  log_like <- log_like + log( (1 - 0.19 * is_fertile)^n_non_pregnant_periods )
  if(!is_pregnant && next_period < days_since_last_period) {
    log_like <- -Inf
  }
  log_like
}

# Here the DATA is the scalar days_since_last_period, and the vector days_between_periods.

# The rest of the arguments are the PARAMETERS to be estimated.
# Thus using this function I can calcualte the log likelhood for any DATA + PARAMETER combination.
# I still only have half a model - I need the PRIORS.

## Part C - PRIORS ##

# I need PRIORS - the information the model has, before seeing any data!!

# Specifially, for mean_period, sd_period_ is_fertile_ and is_pregnant (next_period is
# also a parameter but can be derived from mean_period and sd_period)

# I also need to set the proability of becoming pregnant in a cyle (0.19 as given above)
# No vague priors here - all priors were taken from the literature.

# is_fertile / is_pregnant are based on frequencies
# is fetile = 0.95
# is_pregant is a binary parameter standing for whether the couple are going to get (or already are)
# pregnant the current cyclec [derived from data-set below]

# proportion not pregnant after 12 cycles
prop_not_preg_12_cycles <- c( "19-26 years" = 0.08,
                             "27-34 years" = 0.13,
                             "35-39 years" = 0.18)

# proportion pregant (is_pregnant) in one cycle
1 - (prop_not_preg_12_cycles - 0.05)^(1/12)


# I have all the PRIORS now and can construct a function that returns 
# samples from the prior:

sample_from_prior <- function(n) {
  prior <- data.frame(mean_period = rnorm(n, 27.7, 2.4),
                      sd_period   = abs(rnorm(n, 0, 2.05)),
                      is_fertile  = rbinom(n, 1, 0.95))
  prior$is_pregnant <- rbinom(n, 1, 0.19 * prior$is_fertile)
  prior$next_period <- rnorm(n, prior$mean_period, prior$sd_period)
  prior$next_period[prior$is_pregnant == 1] <- NA
  prior
}

sample_from_prior(n = 4)


## FITTING THE MODEL USING IMPORTANCE SAMPLING ##

# I now have the TRIFORCE of Bayesian statistics: The PRIOR (3), the LIKELYHOOD (2),
# and the DATA (1).
# There are many algorithms available for this model, but  aparticualr convenient method
# is importance sampling.
# Importance sampling is a Monte Carlo: that is very easy to setup, and can 
# work well if the 1) parameter space is small, and the the PRIORS are not
# too dissimilar from the POSTERIOR.


# There are 3 steps in importance sampling:
# 1. Generate a large sample from the PRIOR (done using sample_from_prior)
# 2. Assign a weight to each draw from the PRIOR that is proportional to the
# likelyhood of the data GIVEN those parameters (done using calc_log_like)
# 3. Normalize the weights to sum to 1, so that they now form a 
# probability distribution over the PRIOR sample.
# Finally, resample the PRIOR sample according to the 
# probability distribution (done using function sample)

# The RESULT of using importance sampling is a new smaple, which if the importance
# sampling worked can be treated a a sample from the the POSTERIOR.
# That is - it represents what the "model knows after seeing the data".

# The importance sampling function is constructed as follows:

sample_from_posterior <- function(days_since_last_period, days_between_periods, n_samples) {
  prior <- sample_from_prior(n_samples)
  log_like <- sapply(1:n_samples, function(i) {
    calc_log_like(days_since_last_period, days_between_periods,
                  prior$mean_period[i], prior$sd_period[i], prior$next_period[i],
                  prior$is_fertile[i], prior$is_pregnant[i])
  })
  posterior <- prior[ sample(n_samples, replace = TRUE, prob = exp(log_like)), ]
  posterior
}

# THE RESULTS

post <- sample_from_posterior(33, days_between_periods, n_samples = 100)

head(post)
mean(post$is_fertile)
mean(post$is_pregnant)

post <- sample_from_posterior(34, days_between_periods, n_samples = 100000)
mean(post$is_pregnant)

post <- sample_from_posterior(35, days_between_periods, n_samples = 100000)
mean(post$is_pregnant)


