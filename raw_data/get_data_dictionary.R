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

# create new version of data_dictonary
clean_dictionary <- data_dictionary

# convert all colnames to lowercase
colnames(clean_dictionary) <- tolower(colnames(clean_dictionary))

# replace colname whitespace with underscore
colnames(clean_dictionary) <- stringr::str_replace_all(colnames(clean_dictionary),
                                                       " ", "_")

# repalce colname hyphens with underscores
colnames(clean_dictionary) <- stringr::str_replace_all(colnames(clean_dictionary),
                                                       "-", "_")
# fill in blank dev_friendly_names
temp_name <- character()
temp_type <- character()

for(i in seq_along(clean_dictionary$developer_friendly_name)){
  if(is.na(clean_dictionary$developer_friendly_name[i])){
    clean_dictionary$developer_friendly_name[i] <- temp_name
    clean_dictionary$api_data_type[i] <- temp_type
  }
  else{
    temp_name <- clean_dictionary$developer_friendly_name[i]
    temp_type <- clean_dictionary$api_data_type[i]
  }
}

# rename and reorder colnames 
clean_dictionary <- clean_dictionary %>%
  rename(var_name = variable_name, 
         dev_friendly_name = developer_friendly_name) %>%
  select(var_name, name_of_data_element, dev_friendly_name, label, dev_category, 
         api_data_type, source, notes)

# change dev friendly names to convert periods to underscores
clean_dictionary <- clean_dictionary %>%
  mutate(dev_friendly_name = stringr::str_replace_all(dev_friendly_name, "\\.", "_"))

slim_dictionary <- clean_dictionary %>%
  filter(!is.na(var_name)) %>%
  select(var_name, name_of_data_element, dev_friendly_name)

# rename clean data dictionary
data_dictionary <- clean_dictionary

# save data dictionary as .rda
devtools::use_data(data_dictionary, overwrite = TRUE)
devtools::use_data(slim_dictionary, overwrite = TRUE)

# clean college data ####

tidy_college_data <- function(year = 1997){
  
  academic_year <- paste(year - 1, year - 1900, sep = "_")
  
  file_path <- paste0("raw_data/CollegeScorecard_Raw_Data/MERGED", academic_year, "_PP.csv")
  
  year_data <- read_csv(file_path, na = c("", "NA", "NULL"))
  
  colnames(year_data) <- data_dictionary$dev_friendly_name
  
}
