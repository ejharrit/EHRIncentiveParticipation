#############################################################################################################################
#############################################################################################################################
##                                                                                                                         ##
##                              This file loads the data we pulled from the Data.CMS.gov                                   ##
##                                  API, cleans it and saves the new data format                                           ##
##                                                                                                                         ##
##                                                                                                                         ##
#############################################################################################################################


##### Load the necessary packages
#####

library(data.table)
library(tidyverse)
library(skimr)

##### --
#####

##### Load our data sets
#####
national_providers <- fread("data/raw/DAC_NationalDownloadableFile.csv") %>%
  as_tibble()
