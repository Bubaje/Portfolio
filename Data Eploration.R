## Instaling Packages

install.packages("tidyverse")
install.packages("skimr")
install.packages("janitor")
library(tidyverse)
library(skimr)
library(janitor)


## Import data

bookings_df <- read_csv("hotel_booking.csv")

## Checking data

head(bookings_df)
str(bookings_df)
colnames(bookings_df)
glimpse(bookings_df)


## Cleaning data

skim_without_charts(bookings_df)

trimmed_df <- bookings_df %>% 
  select(hotel, is_canceled, lead_time)

trimmed_df %>% 
  select(hotel, is_canceled, lead_time) %>% 
  rename(hotel_type = hotel)

combine_date_df <- bookings_df %>%
  select(arrival_date_year, arrival_date_month) %>% 
  unite(arrival_month_year, c("arrival_date_month", "arrival_date_year"), sep = " ")

People_df <- bookings_df %>%
  mutate(guests = adults + children + babies)
head(People_df)


## Focus on adr & adults

new_df <- select(bookings_df, `adr`, adults)
view(new_df)
mutate(new_df, total = `adr` / adults)

## Manipulating data
arrange(bookings_df, lead_time) #<- Ascending order
arrange(bookings_df, desc(lead_time)) #<- Descending 

## New data Frame

bookings_df_v2 <-
  arrange(bookings_df, desc(lead_time))
view(bookings_df_v2)
max(bookings_df_v2$lead_time)
min(bookings_df_v2$lead_time)

## Filtering only hotel in city
bookings_booking_city <-
  filter(bookings_df, hotel == "City Hotel")
head(bookings_booking_city)

hotel_summary <- 
  bookings_df %>%
  group_by(hotel) %>%
  summarise(average_lead_time=mean(lead_time),
            min_lead_time=min(lead_time),
            max_lead_time=max(lead_time))
head(hotel_summary)

