#Final Project
#Nikitha and Kassie

rm(list=ls())

library(rvest)
library(dplyr)
library(stringr)
library(tidyr)
library(tidyverse)
library(readr)
library(stringi)
library(ggplot2)


#IMDB

url <- "https://www.imdb.com/chart/top/?ref_=nv_mv_250"

webpage <- read_html(url)

titles <- webpage %>%
  html_nodes(xpath = '//*[@id="__next"]/main/div/div[3]/section/div/div[2]/div/ul/li/div[2]/div/div/div[1]/a/h3') %>%
  html_text()

durations <- webpage %>%
  html_nodes(xpath = '//*[@id="__next"]/main/div/div[3]/section/div/div[2]/div/ul/li/div[2]/div/div/div[2]/span[2]') %>%
  html_text()

years <- webpage %>%
  html_nodes(xpath = '//*[@id="__next"]/main/div/div[3]/section/div/div[2]/div/ul/li/div[2]/div/div/div[2]/span[1]') %>%
  html_text()

ratings <- webpage %>%
  html_nodes(xpath = '//*[@id="__next"]/main/div/div[3]/section/div/div[2]/div/ul/li/div[2]/div/div/span/div/span') %>%
  html_text()

imdb_data <- data.frame(
  Title = titles,
  Duration = durations,
  Year = years,
  Rating = ratings
)

imdb_data$Title <- str_remove(imdb_data$Title, "^\\d+\\.\\s")

imdb_data <- imdb_data %>%
  mutate(Votes = Rating)

imdb_data$Rating <- str_remove(imdb_data$Rating, "\\(.*\\)")

imdb_data$Votes <- str_remove(imdb_data$Votes, "\\d+\\.\\d+")

imdb_data$Votes <- str_remove_all(imdb_data$Votes, "[()]")

imdb_data$Rating <- as.numeric(str_extract(imdb_data$Rating, "\\d+\\.\\d+"))

imdb_data <- imdb_data %>%
  separate(Duration, into = c("Hours", "Minutes"), sep = "h|\\s*m", convert = TRUE, remove = FALSE, fill = "right") %>%
  mutate(Duration = coalesce(Hours, 0) * 60 + coalesce(Minutes, 0)) %>%
  select(-Hours, -Minutes)

convert_votes <- function(votes) {
  numeric_votes <- as.numeric(gsub("[^0-9.]", "", votes))
  
  ifelse(grepl("K", votes, ignore.case = TRUE), 
         numeric_votes * 1000,
         ifelse(grepl("M", votes, ignore.case = TRUE), 
                numeric_votes * 1000000,
                numeric_votes))
}

imdb_data$Votes <- convert_votes(imdb_data$Votes)

write.csv(imdb_data, "imdb_data.csv", row.names = FALSE)

#Netflix Data
Netflix_data <- read_csv("NetflixDataset.csv")

Netflix_data <- Netflix_data %>%
  filter_all(~ !grepl("�", stri_trans_nfkd(.)))

Netflix_data <- Netflix_data[, c("Title", "Genre", "Director", "Writer", "Actors", "View Rating")]

Netflix_data <- Netflix_data %>%
  mutate(Genre = str_extract(Genre, "^[^,]+"))

Netflix_data <- Netflix_data %>%
  mutate(Director = str_extract(Director, "^[^,]+"))

Netflix_data <- Netflix_data %>%
  mutate(Writer = str_extract(Writer, "^[^,]+"))

Netflix_data <- Netflix_data %>%
  mutate(Actors = str_extract(Actors, "^[^,]+"))

write.csv(Netflix_data, "cleaned_netflix_data.csv", row.names = FALSE)

#Merge Data
merged_data <- merge(Netflix_data, imdb_data, by = "Title", all = FALSE)

merged_data <- merged_data %>%
  rename(Maturity = `View Rating`)

write.csv(merged_data, "merged_dataset.csv", row.names = FALSE)

#Graphs
#3.1
director_ratings <- merged_data %>%
  filter(!is.na(Rating) & Rating > 0 & is.numeric(Rating)) %>%
  group_by(Director) %>%
  summarise(AvgRating = mean(Rating, na.rm = TRUE))

# Select the top 10 directors by average IMDb rating
top_directors <- director_ratings %>%
  top_n(20, AvgRating)

# Create a bar plot for the top 10 directors by average IMDb rating
ggplot(top_directors, aes(x = reorder(Director, -AvgRating), y = AvgRating)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Top 20 Directors by Average IMDb Rating",
       x = "Director",
       y = "Average IMDb Rating") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#3.2
#1
years_data <- merged_data %>%
  separate(Year, into = c("ReleaseYear", "Extra"), sep = "-", remove = TRUE) %>%
  filter(!is.na(ReleaseYear)) %>%
  distinct(ReleaseYear)

# Count the number of movies released per year
movies_per_year <- merged_data %>%
  group_by(Year) %>%
  summarise(NumMovies = n())

# Create a bar plot for movies released per year
ggplot(movies_per_year, aes(x = Year, y = NumMovies, fill = Year)) +
  geom_bar(stat = "identity") +
  labs(title = "Number of Movies Released per Year",
       x = "Release Year",
       y = "Number of Movies") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#2
average_rating_per_year <- merged_data %>%
  group_by(Year) %>%
  summarise(AvgRating = mean(Rating, na.rm = TRUE))

# Find the release year with the highest average IMDb rating
top_year <- average_rating_per_year %>%
  filter(AvgRating == max(AvgRating))

# Create a bar plot for the average IMDb rating per release year
ggplot(average_rating_per_year, aes(x = as.factor(Year), y = AvgRating)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Average IMDb Rating per Release Year",
       x = "Release Year",
       y = "Average IMDb Rating") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_text(aes(label = round(AvgRating, 2)), vjust = -0.3, color = "black", size = 3) +
  annotate("text", x = top_year$Year, y = top_year$AvgRating, label = "Most Liked", color = "black", size = 5)


#3.3
#1
# Extract genres from the cleaned Netflix data
genres <- Netflix_data %>%
  separate_rows(Genre, sep = ", ") %>%
  filter(!is.na(Genre)) %>%
  distinct(Genre)

# Merge the genres with the merged data
genre_distribution <- merged_data %>%
  select(Title, Genre) %>%
  separate_rows(Genre, sep = ", ") %>%
  filter(!is.na(Genre))

# Create a bar plot for the movie distribution per genre
ggplot(genre_distribution, aes(x = Genre, fill = Genre)) +
  geom_bar() +
  labs(title = "Movie Distribution for Each Genre",
       x = "Genre",
       y = "Number of Movies") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


#2
# Extract genres from the cleaned Netflix data
genres <- Netflix_data %>%
  separate_rows(Genre, sep = ", ") %>%
  filter(!is.na(Genre)) %>%
  distinct(Genre)

# Merge the genres with the merged data
genre_ratings <- merged_data %>%
  select(Title, Rating, Genre) %>%
  separate_rows(Genre, sep = ", ") %>%
  filter(!is.na(Genre))

# Create a bar plot for the movie distribution of each genre
ggplot(genre_ratings, aes(x = Genre, fill = factor(Rating))) +
  geom_bar() +
  labs(title = "Movie Distribution by Genre",
       x = "Genre",
       y = "Count",
       fill = "IMDb Rating") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

#3
# Calculate the average rating per genre
average_rating_per_genre <- genre_ratings %>%
  group_by(Genre) %>%
  summarise(AvgRating = mean(Rating, na.rm = TRUE))

# Find the genre with the highest average rating
top_genre <- average_rating_per_genre %>%
  filter(AvgRating == max(AvgRating))

# Create a bar plot for the average IMDb rating per genre
ggplot(average_rating_per_genre, aes(x = Genre, y = AvgRating)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  labs(title = "Average IMDb Rating per Genre",
       x = "Genre",
       y = "Average IMDb Rating") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  geom_text(aes(label = round(AvgRating, 2)), vjust = -0.3, color = "black", size = 3) +
  annotate("text", x = top_genre$Genre, y = top_genre$AvgRating, label = "Highest Rated", color = "black", size = 5)


#3.4
# Create a bar plot for average IMDb rating by View Rating
ggplot(merged_data, aes(x = Maturity, y = Rating)) +
  stat_summary(fun = "mean", geom = "bar", fill = "skyblue") +
  labs(title = "Average IMDb Rating by View Rating",
       x = "View Rating",
       y = "Average IMDb Rating") +
  theme_minimal()


#3.5
ggplot(merged_data, aes(x = Duration, y = Rating)) +
  geom_point() +
  labs(title = "Impact of Movie Duration on IMDb Rating",
       x = "Duration (minutes)",
       y = "IMDb Rating") +
  theme_minimal()

#3.6
ggplot(merged_data, aes(x = Votes, y = Rating)) +
  geom_point() +
  labs(title = "Impact of Number of Voters on Movie Rating",
       x = "Number of Voters",
       y = "IMDb Rating") +
  theme_minimal()
