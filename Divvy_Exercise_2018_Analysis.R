# Divvy_Exercise
# Question to Answer: How do annual members and casual riders use Cyclistic bikes differently?

# Install and load required packages

install.packages("tidyverse")
install.packages("lubridate")
library(tidyverse)
library(lubridate)

# Stage 1: Upload the csv datasets 

q1_2018 <- read_csv("Divvy_Trips_2018_Q1.csv")
q2_2018 <- read_csv("Divvy_Trips_2018_Q2.csv")
q3_2018 <- read_csv("Divvy_Trips_2018_Q3.csv")
q4_2018 <- read_csv("Divvy_Trips_2018_Q4.csv")

# View and skim through datasets
View(q1_2018)
head(q2_2018)
glimpse(q3_2018)
as_tibble(q4_2018)


# Stage 2: Wrangle and combine data into a single file
# Compare column names of each dataset to make sure they match

colnames(q1_2018)
colnames(q2_2018)
colnames(q3_2018)
colnames(q4_2018)

# Rename columns to make them consistent 

(q1_2018 <- rename(q1_2018
                   ,ride_id = "01 - Rental Details Rental ID"
                   ,rideable_type = "01 - Rental Details Bike ID" 
                   ,started_at = "01 - Rental Details Local Start Time"  
                   ,ended_at = "01 - Rental Details Local End Time"  
                   ,start_station_name = "03 - Rental Start Station Name" 
                   ,start_station_id = "03 - Rental Start Station ID"
                   ,end_station_name = "02 - Rental End Station Name" 
                   ,end_station_id = "02 - Rental End Station ID"
                   ,member_casual = "User Type"
                   ,gender = "Member Gender"
                   ,birth_year = "05 - Member Details Member Birthday Year"))

(q2_2018 <- rename(q2_2018
                   ,ride_id = trip_id
                   ,rideable_type = bikeid 
                   ,started_at = start_time  
                   ,ended_at = end_time  
                   ,start_station_name = from_station_name 
                   ,start_station_id = from_station_id 
                   ,end_station_name = to_station_name 
                   ,end_station_id = to_station_id 
                   ,member_casual = usertype
                   ,birth_year = birthyear))
                

(q3_2018 <- rename(q3_2018
                   ,ride_id = trip_id
                   ,rideable_type = bikeid 
                   ,started_at = start_time  
                   ,ended_at = end_time  
                   ,start_station_name = from_station_name 
                   ,start_station_id = from_station_id 
                   ,end_station_name = to_station_name 
                   ,end_station_id = to_station_id 
                   ,member_casual = usertype
                   ,birth_year = birthyear))



(q4_2018 <- rename(q4_2018
                   ,ride_id = trip_id
                   ,rideable_type = bikeid 
                   ,started_at = start_time  
                   ,ended_at = end_time  
                   ,start_station_name = from_station_name 
                   ,start_station_id = from_station_id 
                   ,end_station_name = to_station_name 
                   ,end_station_id = to_station_id 
                   ,member_casual = usertype
                   ,birth_year = birthyear))

# Inspect the dataframes and look for incongruencies

str(q1_2018)
str(q2_2018)
View(q1_2018)
str(q3_2018)
str(q4_2018)


# Convert ride_id and rideable_type to character so they can stack correctly


q1_2018 <-  mutate(q1_2018, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q2_2018 <-  mutate(q2_2018, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q3_2018 <-  mutate(q3_2018, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 
q4_2018 <-  mutate(q4_2018, ride_id = as.character(ride_id)
                   ,rideable_type = as.character(rideable_type)) 



# Stack individual quarter's data frames into one big data frame

all_trips <- bind_rows(q1_2018, q2_2018, q3_2018, q4_2018)

View(all_trips)
colnames(all_trips)

# Remove unnecessary columns (tripduration, 01 - Rental Details Duration In Seconds Uncapped, birth_year, and gender)

all_trips <- all_trips %>% 
  select(-c(tripduration, "01 - Rental Details Duration In Seconds Uncapped", birth_year, gender))

colnames(all_trips)  


# Stage 3: Clean up and add data to prepare for analysis

# Inspect new table
colnames(all_trips)
nrow(all_trips)
dim(all_trips)
head(all_trips)
tail(all_trips)
glimpse(all_trips)
str(all_trips)
summary(all_trips)
View(all_trips)


# Few problems that need to be addressed:
# 1. Consolidate the four labels in the "member_casual" column into two labels
# Currently two names for members ("member" and "Subscriber) & two names for casual riders ("Customer" and "casual")
# 2. Add additional columns of data (day, month year) to provide more opportunities to aggregate the data
# 3. Add a calculated field for the length of ride called ride_length


# In the "member_casual" column, replace "Subscriber" with member and "Customer" with "casual"

# Check how many observations fall under each usertype

table(all_trips$member_casual)

# Replace the names (Subscriber to member & Customer to casual)

all_trips <- all_trips %>% 
  mutate(member_casual =recode(member_casual
                               ,"Subscriber"="member"
                               ,"Customer"="casual"))

# Check to make sure the proper numbe of observations were reassigned

table(all_trips$member_casual)

# Add columns that list the date, month, day, and year of each ride
# This is allow us to aggregate the ride data for each month, day, or year (before it was only possible at the ride level)


all_trips$date <- as.Date(all_trips$started_at) #The default format is yyyy-mm-dd
all_trips$month <- format(as.Date(all_trips$date), "%m")
all_trips$day <- format(as.Date(all_trips$date), "%d")
all_trips$year <- format(as.Date(all_trips$date), "%Y")
all_trips$day_of_week <- format(as.Date(all_trips$date), "%A")


# Add a "ride_length" calculation to all_trips (in seconds)

all_trips$ride_length <- difftime(all_trips$ended_at,all_trips$started_at)


# Inspect the structure of the columns

str(all_trips)



# Convert "ride_length" from Factor to numeric so we can run calculations on the data

is.factor(all_trips$ride_length)
all_trips$ride_length <- as.numeric(as.character(all_trips$ride_length))
is.numeric(all_trips$ride_length)


# Remove the dirty data

View(all_trips)

# Ensure there is no negative value in ride_length
# Create new version of the dataframe (v2) since daa is being removed 


all_trips_v2 <- all_trips[!(all_trips$start_station_name == "HQ QR" | all_trips$ride_length<0),]

View(all_trips_v2)


# Stage 4: Conduct descriptive analysis
# Descriptive analysis on ride_length (all figures in seconds)

# Straight average (total ride length / rides)

mean(all_trips_v2$ride_length) 

# Midpoint number in the ascending array of ride lengths

median(all_trips_v2$ride_length) 

# Longest ride

max(all_trips_v2$ride_length) 

# Shortest ride

min(all_trips_v2$ride_length) 


# Summary of mean, median, min and max

summary(all_trips_v2$ride_length)


# Compare members and casual users

aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = mean)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = median)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = max)
aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual, FUN = min)

# See the average ride time by each day for members vs casual users

aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)


# Days of the week are out of order, need to be fixed

all_trips_v2$day_of_week <- ordered(all_trips_v2$day_of_week, levels=c("Sunday", "Monday", 
                                                                       "Tuesday", "Wednesday", 
                                                                       "Thursday", "Friday", "Saturday"))

# Run the average ride time by each day for members vs casual users again

aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + all_trips_v2$day_of_week, FUN = mean)


# Analyze ridership data by type and weekday

all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>%  #creates weekday field using wday()
  group_by(member_casual, weekday) %>%  #groups by usertype and weekday
  summarise(number_of_rides = n()							#calculates the number of rides and average duration 
            ,average_duration = mean(ride_length)) %>% 		# calculates the average duration
  arrange(member_casual, weekday)								# sorts


# Visualize the number of rides by rider type

all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(mapping=aes(x = weekday, y = number_of_rides, fill = member_casual)) +
  geom_col(position = "dodge")


# Visualization for average duration

all_trips_v2 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday)  %>% 
  ggplot(mapping=aes(x = weekday, y = average_duration, fill = member_casual)) +
  geom_col(position = "dodge")


# Stage 5: Export summary file for further analysis
# Create a csv file that can be used for visualization in Tableau

counts <- aggregate(all_trips_v2$ride_length ~ all_trips_v2$member_casual + 
all_trips_v2$day_of_week, FUN = mean)

write.csv(counts, file = '~/Desktop/Divvy_Exercise/avg_ride_length.csv')






