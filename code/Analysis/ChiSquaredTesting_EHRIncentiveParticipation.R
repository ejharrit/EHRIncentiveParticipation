#############################################################################################################################
#############################################################################################################################
##                                                                                                                         ##
##                              This file performs Chi-squared testing on participation in the                             ##
##                                  EHR incentive program across various categorical variables                             ##
##                                  in our dataset                                                                         ##
##                                                                                                                         ##
#############################################################################################################################


##### Load the necessary packages
#####

library(tidyverse)
library(infer)

##### --
#####


##### Load the data
#####

ehr_participation_data <- read_csv("data/cleaned/ehr_participation_data.csv")

##### --
#####

##### Chi-squared testing
#####

### first the inland_empire variable
###
###

### the test
ehr_participation_data %>%
  chisq_test(incentive_ptcpt ~ inland_empire)

### observed independent statistic for inland_empire and incentive_ptcpt
observed_indep_statistic_ie <- ehr_participation_data %>%
  specify(incentive_ptcpt ~ inland_empire, success = "Meaningfully Attested") %>%
  hypothesize(null = "independence") %>%
  calculate(stat = "Chisq")

### simulated expected distribution
null_dist_sim_ie <- ehr_participation_data %>%
  specify(incentive_ptcpt ~ inland_empire, success = "Meaningfully Attested") %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "Chisq")

### visualize the result to see how extreme the observed result is to a null random distribution of 1000
null_dist_sim_ie %>%
  visualize() + 
  shade_p_value(observed_indep_statistic_ie,
                direction = "greater")

### Practice Size
###
###

### the test
ehr_participation_data %>%
  chisq_test(incentive_ptcpt ~ practice_size)

### observed independent statistic for practice_size and incentive_ptcpt
observed_indep_statistic_sz <- ehr_participation_data %>%
  specify(incentive_ptcpt ~ practice_size, success = "Meaningfully Attested") %>%
  hypothesize(null = "independence") %>%
  calculate(stat = "Chisq")

### simulated expected distribution
null_dist_sim_sz <- ehr_participation_data %>%
  specify(incentive_ptcpt ~ practice_size, success = "Meaningfully Attested") %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "Chisq")

### visualize the result to see how extreme the observed result is to a null random distribution of 1000
null_dist_sim_sz %>%
  visualize() + 
  shade_p_value(observed_indep_statistic_sz,
                direction = "greater")


### Rural
###
###

### the test
ehr_participation_data %>%
  chisq_test(incentive_ptcpt ~ rural)

### observed independent statistic for rural and incentive_ptcpt
observed_indep_statistic_rl <- ehr_participation_data %>%
  specify(incentive_ptcpt ~ rural, success = "Meaningfully Attested") %>%
  hypothesize(null = "independence") %>%
  calculate(stat = "Chisq")

### simulated expected distribution
null_dist_sim_rl <- ehr_participation_data %>%
  specify(incentive_ptcpt ~ rural, success = "Meaningfully Attested") %>%
  hypothesize(null = "independence") %>%
  generate(reps = 1000, type = "permute") %>%
  calculate(stat = "Chisq")

### visualize the result to see how extreme the observed result is to a null random distribution of 1000
null_dist_sim_rl %>%
  visualize() + 
  shade_p_value(observed_indep_statistic_rl,
                direction = "greater")

##### --
#####