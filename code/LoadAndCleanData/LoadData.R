#############################################################################################################################
#############################################################################################################################
##                                                                                                                         ##
##                              This file loads Data from multiple sources to perform                                      ##
##                                   analysis on participation in the EHR incentive program                                ##
##                                                                                                                         ##
##                                                                                                                         ##
#############################################################################################################################


##### Load the necessary packages
#####

library(tidyverse)
library(purrr)

##### --
#####

##### Set options to allow for longer time for downloads before timing out
#####

options(timeout = max(600, getOption("timeout")))

##### --
#####


#############################################################################################################################
####################################    Pull the data on organizations    ###################################################
####################################    paid for participating in the EHR incentive    ######################################
#############################################################################################################################


##### Download the files. Files can be accessed at
##### https://www.cms.gov/medicare/regulations-guidance/promoting-interoperability-programs/data-reports
#####
### the links to download the files
urls <- c(
  "https://www.cms.gov/regulations-and-guidance/legislation/ehrincentiveprograms/downloads/ep_providerspaidbyehrprogram1.zip",
  "https://www.cms.gov/regulations-and-guidance/legislation/ehrincentiveprograms/downloads/ep_providerspaidbyehrprogram2.zip",
  "https://www.cms.gov/regulations-and-guidance/legislation/ehrincentiveprograms/downloads/eh_providerspaidbyehrprogram.zip"
)

### The file path and names used in this project
files <- c(
  "data/raw/ep_providerspaidbyehrprogram1.zip",
  "data/raw/ep_providerspaidbyehrprogram2.zip",
  "data/raw/eh_providerspaidbyehrprogram.zip"
)

### download files from the links and save them to the file paths set
walk2(urls, files, download.file)

##### --
#####


##### Unzip the files and removed the zipped folders
#####
### Get the zipped folders
zipped_files <- list.files("data/raw", full.names = TRUE)

### Unzip the zipped folders and put the unzipped files in the data/raw folder
walk(zipped_files, unzip, exdir = "data/raw")

### delete the zipped folders
file.remove(zipped_files)

##### --
#####

##### Include a file indicating the last time the data was pulled
#####

write_file(paste0("EHR payment data last downloaded ", Sys.Date()),
  file = paste0("data/raw/last_pull_ehr_data_", Sys.Date(), ".txt")
)

##### --
#####

#############################################################################################################################
#############################################################################################################################
#############################################################################################################################
#############################################################################################################################




#############################################################################################################################
###################################    Download the full list of providers    ###############################################
####################################    eligible to bill Medicare in the United States    ###################################
#############################################################################################################################

##### Download the file. File can be accessed at https://data.cms.gov/provider-data/dataset/mj5m-pzi6
#####

download.file("https://data.cms.gov/provider-data/sites/default/files/resources/69a75aa9d3dc1aed6b881725cf0ddc12_1700683520/DAC_NationalDownloadableFile.csv",
  destfile = "data/raw/DAC_NationalDownloadableFile.csv"
)

#####


##### Include a file indicating the last time the data was pulled
#####

write_file(paste0("Provider data last downloaded ", Sys.Date()),
  file = paste0("data/raw/last_pull_provider_data_", Sys.Date(), ".txt")
)

##### --
#####

#############################################################################################################################
#############################################################################################################################
#############################################################################################################################
#############################################################################################################################



#############################################################################################################################
###################################    Download the zip to core-based statistical are    ####################################
####################################    data from the US Derpatment of Housing and Urban Development    #####################
#############################################################################################################################
### This File was downloaded manually at https://www.huduser.gov/apps/public/uspscrosswalk/home
### a profile needed to be created but the download was free and accessible
### The data set for the third quarter of 2023 was the on downloaded and used in this project
### --
###

#############################################################################################################################
#############################################################################################################################
#############################################################################################################################
#############################################################################################################################

##### Clean the environment
#####
remove(files, urls, zipped_files)