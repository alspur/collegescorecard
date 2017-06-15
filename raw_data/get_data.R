# test script for pulling college scorecard data
library(tidyverse)
library(readxl)


# download data ####

# download data dictionary xlsx
data_dictionary_url <- "https://collegescorecard.ed.gov/assets/CollegeScorecardDataDictionary.xlsx"
download.file(data_dictionary_url, "raw_data/data_dictionary.xlsx")

# download college data
college_data_zip_url <- "https://ed-public-download.app.cloud.gov/downloads/CollegeScorecard_Raw_Data.zip"
download.file(college_data_zip_url, "raw_data/college_data.zip")

# unzip files
unzip("raw_data/college_data.zip", exdir = "raw_data")
unzip("raw_data/CollegeScorecard_Raw_Data/Crosswalks_20160908.zip", exdir = "raw_data")

# create clean data dictionary ####

# read raw dictionary into R
data_dictionary <- read_excel("raw_data/data_dictionary.xlsx", sheet = 4)

# filter out rows that don't have variable names
clean_dictionary <- data_dictionary %>%
  filter(!is.na(`VARIABLE NAME`))

# convert all colnames to lowercase
colnames(clean_dictionary) <- tolower(colnames(clean_dictionary))

# replace colname whitespace with underscore
colnames(clean_dictionary) <- stringr::str_replace_all(colnames(clean_dictionary),
                                                       " ", "_")

# repalce colname hyphens with underscores
colnames(clean_dictionary) <- stringr::str_replace_all(colnames(clean_dictionary),
                                                       "-", "_")
# rename and reorder colnames 
clean_dictionary <- clean_dictionary %>%
  rename(var_name = variable_name, 
         dev_friendly_name = developer_friendly_name) %>%
  select(var_name, dev_friendly_name, name_of_data_element, dev_category, 
         api_data_type, source, notes)

# change dev friendly names to convert periods to underscores
clean_dictionary <- clean_dictionary %>%
  mutate(dev_friendly_name = stringr::str_replace_all(dev_friendly_name, "\\.", "_"))

# rename clean data dictionary
data_dictionary <- clean_dictionary

# save data dictionary as .rda
devtools::use_data(data_dictionary, overwrite = TRUE)


# clean college data ####
