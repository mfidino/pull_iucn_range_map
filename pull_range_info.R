###################################
#
# Pull range info
# Written by M. Fidino
#
#
####################################

### load packages
library(sf)
library(dplyr)

# I am using the IUCN Spatial data to determine the range of terrestrial
#  mammals throughout north america. On 1/5/2021 these data could be
#  queried at (uncomment and run next line to open up link):
#
#browseURL("https://www.iucnredlist.org/resources/spatial-data-download")


# After downloading and unzipping I am assuming that the folders of spatial
#  data is here (update as necessary):
mammal_path <- "D:/TERRESTRIAL_MAMMALS"

# The mammal data is too large for me to pull entirely onto my laptop.
#  So we're going to need to write a SQL query to collect the specific
#  species for our analysis. First step is to get one row of data
#  from this table to determine column names for querying
one_row <- sf::read_sf(
  "D:/TERRESTRIAL_MAMMALS",
  query = "SELECT * FROM TERRESTRIAL_MAMMALS LIMIT 1"
)


### IMPORTANT COLUMNS:
# 'binomial': binomial nomenclature. First letter capitalized in genus.
# 'legend': We only want "Extant & Introduced (resident)" or 
#             "Extant (resident)" in this column.

# Here is a function that will paste together names for a SQL IN statement
sql_IN <- function(x){
  to_return <- paste0("'",x,"'")
  to_return <- paste0(to_return, collapse = ", ")
  to_return <- paste0("(", to_return, ")")
  return(to_return)
}



# Here is an example of a couple species
my_species <- data.frame(
  name = c("Virginia opossum", "Raccoon", "Coyote"),
  binomial = c("Didelphis virginiana", "Procyon lotor", "Canis latrans")
)

# Here I am also ensuring that the part of the range is where they are known
# to be (the extant part of the query).
mammal_qry <- paste0(
  "SELECT tm.binomial AS binomial FROM TERRESTRIAL_MAMMALS tm\n",
  "WHERE tm.binomial IN ", sql_IN(my_species$binomial), "\n",
  "AND tm.legend IN ", sql_IN(c("Extant & Introduced (resident)",
                                "Extant (resident)"))
)

mams <- sf::read_sf(mammal_path,
                    query = mammal_qry
)

# plot it out:
plot(mams[mams$binomial == "Didelphis virginiana",])


# In this example, raccoon have multiple rows in the dataset. You can combine
#  them like so:
mams <- mams %>% 
  dplyr::group_by(binomial) %>% 
  dplyr::summarise(
    geometry = sf::st_union(geometry)
  )
