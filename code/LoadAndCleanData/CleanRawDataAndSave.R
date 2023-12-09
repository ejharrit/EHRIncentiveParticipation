#############################################################################################################################
#############################################################################################################################
##                                                                                                                         ##
##                              This file loads the data we pulled from the LoadData.R file,                               ##
##                                       cleans it and saves the new data format                                           ##
##                                                                                                                         ##
##                                                                                                                         ##
#############################################################################################################################


##### Load the necessary packages
#####

library(data.table)
library(tidyverse)
library(janitor)
library(readxl)
library(skimr)

##### --
#####

##### Load our data sets
#####
national_providers <- fread("data/raw/DAC_NationalDownloadableFile.csv") %>%
  as_tibble() %>%
  clean_names()

ehr_files <- list.files("data/raw", "ProvidersPaidByEHR", full.names = TRUE)

ehr_participants <- map_dfr(ehr_files, read_csv, col_select = -`PROVIDER EXT`) %>%
  clean_names()

zip_cbsa <- read_excel("data/raw/ZIP_CBSA_092023.xlsx", sheet = "Export Worksheet") %>%
  clean_names()

cbsa_csa <- read_excel("data/raw/Census_CBSA_CSA_2023.xlsx", skip = 2, col_names = TRUE) %>%
  clean_names()

### remove the unecessary objects
remove(ehr_files)

##### --
#####


##### Join the data sets
#####
### The national_providers data set will be the primary data table. 
### The code below selects the columns needed from this data frame and joins it 
### to the other data sets
ehr_participant_data <- national_providers %>%
  select(c(npi, provider_last_name:provider_first_name, gndr:med_sch, pri_spec:facility_name,
           num_org_mem:zip_code, ind_assgn:grp_assgn)) %>%
  mutate(npi = as.character(npi)) %>%
  ### join the national providers data to the ehr participation data
  left_join(
    ### before joining to the ehr_participants data select only the columns needed from the 
    ### ehr_participants data set
    ehr_participants %>%
      select(c(provider_npi, stage_number:calc_payment_amt)) %>%
      ### make sure there is only one record per provider
      group_by(provider_npi, stage_number, program_year) %>%
      summarize(tot_payment_amt = sum(as.numeric(calc_payment_amt), na.rm = TRUE)),
    ### join the two datasets on npi
    by = c("npi" = "provider_npi")
  ) %>%
  

##### --
#####