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
ehr_participation_data <- national_providers %>%
  filter(state == "CA") %>%
  mutate(zip_code = str_sub(zip_code, 1, 5)) %>%
  distinct(npi, facility_name, num_org_mem, zip_code, org_pac_id) %>%
  mutate(npi = as.character(npi)) %>%
  ### join the zip to zip_cbsa data set
  left_join(
    zip_cbsa %>%
      filter(usps_zip_pref_state == "CA") %>%
      ### zip codes map to multiple CBSAs, the code below assigns a zipcode to the CBSA with the highest ratio
      ### of residential addresses for that zipcode
      group_by(zip) %>%
      arrange(desc(res_ratio)) %>%
      slice_head(n = 1) %>%
      ungroup() %>%
      distinct(zip, cbsa) %>%
      ### Join the zip_cbsa file to the cbsa_csa file to get the cbsa_title
      left_join(
        cbsa_csa %>%
          filter(state_name == "California") %>%
          distinct(cbsa_code, cbsa_title),
        by = c("cbsa" = "cbsa_code")
      ),
    by = c("zip_code" = "zip")
  ) %>%
  ### drop zip_code and cbsa and keep only distinct records
  select(-c(zip_code, cbsa)) %>%
  distinct() %>%
  ### join the national providers data to the ehr participation data
  left_join(
    ehr_participants %>%
      ### select only provider_npi and keep only distinct values
      select(provider_npi) %>%
      distinct(),
    ### join the two datasets on npi
    by = c("npi" = "provider_npi"),
    ### keep the provider_npi variable NA values in that field can be used to indicate the provider
    ### did not participate in the incentive program because there was no match
    keep = TRUE
  ) %>%
  ### drop npi and keep only distinct values
  select(-npi) %>%
  distinct()

### remove the unnecessary data sets
remove(cbsa_csa, ehr_participants, national_providers, zip_cbsa)

##### --
#####


##### create new variables and reorganize the columns
#####

ehr_participation_data <- ehr_participation_data %>%
  mutate(
    ### create a new variable indicating if the zipcode is rural or not. Zipcodes not assigned to a CBSA are considered
    ### rural
    rural = if_else(is.na(cbsa_title), "rural", "urban"),
    ### convert the num_org_mem variable to a categorical variable that categorizes the bottom third as "small", the
    ### middle third as "medium", and the top third as "large" using values calculated from
    ### quantile(ehr_participation_data$num_org_mem, probs = c(0.3333, 0.6666), na.rm = TRUE)
    practice_size = case_when(
      num_org_mem <= 11                     ~ "small",
      num_org_mem > 11 & num_org_mem <= 306 ~ "medium",
      num_org_mem > 306                     ~ "large",
      TRUE                                  ~ NA
    ),
    ### Use the provider_npi field to indicate if the provider participated in the EHR incentive program
    incentive_ptcpt = if_else(is.na(provider_npi), "No Meaningful Attest", "Meaningfully Attested"),
    ### create a variable indicating if the provider is in the Riverside-San Bernardino-Ontario, CA CBS
    ### we will call it Inland Empire although it will include some rural area outside of the Inland Empire
    ### the population center of this CBSA is still the Inland Empire
    inland_empire = if_else(cbsa_title == "Riverside-San Bernardino-Ontario, CA", 
                                              "Inland Empire", "CA other")
  ) %>%
  select(
    ### move geographic information and identifiers to the front with facility name
    org_pac_id,     facility_name,  cbsa_title, rural, inland_empire,
    ### next, additional information about the facility
    practice_size,  incentive_ptcpt
  )

##### --
#####


### write the dataframe to the clean data file as a csv
write_csv(ehr_participation_data, file = "data/cleaned/ehr_participation_data.csv")

### clear our workspace
remove(ehr_participation_data)

##### --
#####
