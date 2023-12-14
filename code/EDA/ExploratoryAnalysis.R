#############################################################################################################################
#############################################################################################################################
##                                                                                                                         ##
##                              This file this file performs an exploratory analysis on the                                ##
##                                  data we cleaned in the CleanRawDatAndSave.R file                                       ##
##                                                                                                                         ##
##                                                                                                                         ##
#############################################################################################################################


##### Load the necessary packages
#####

library(tidyverse)

##### --
#####


##### Load the data
#####

ehr_participation_data <- read_csv("data/cleaned/ehr_participation_data.csv")

##### --
#####


##### Some descriptive Statistics
#####
### table of participation in EHR incentive program
table(ehr_participation_data$incentive_ptcpt)

### table of the sizes of the practices
table(ehr_participation_data$practice_size)

### table of practices in rural zipcodes
table(ehr_participation_data$rural)

### crosstab of size and participation in the EHR incentive program
table(ehr_participation_data$incentive_ptcpt, ehr_participation_data$practice_size)

### crosstab of rural and participation in the EHR incentive program
table(ehr_participation_data$incentive_ptcpt, ehr_participation_data$rural)

### crosstab of inland_empire and participation in the EHR incentive program
table(ehr_participation_data$incentive_ptcpt, ehr_participation_data$inland_empire)

##### --
#####