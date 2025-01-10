# Movie Data Analysis

## Description
This project is a comprehensive analysis of movie data sourced from IMDb and Netflix. The goal is to uncover insights into movie trends, director ratings, genre distribution, and other significant metrics. By leveraging data scraping and cleaning techniques, the project integrates two datasets to provide a unified view of the film industry. Visualizations further enhance the storytelling by presenting trends and key findings in an accessible format.

The project uses a combination of R programming for data extraction, transformation, and visualization. It includes scripts for web scraping IMDb's top movies, cleaning Netflix data, and merging the datasets for comparative analysis. The findings are aimed at providing a deeper understanding of the factors influencing movie ratings and trends over the years.

## Features
- **IMDb Data Extraction:** Scrapes movie titles, durations, years, and ratings directly from the IMDb website.
- **Netflix Dataset Cleaning:** Processes and cleans Netflix movie data obtained from a Kaggle dataset.
- **Data Integration:** Merges IMDb and Netflix datasets to create a comprehensive view of movie information.
- **Visualizations:** Includes visualizations to illustrate trends, such as:
  - Top directors by average IMDb rating.
  - Movies released per year.
  - Average IMDb ratings over the years.

## IMDb Data
- Scraped directly from IMDb's top movie chart.
- Extracts key attributes: movie titles, durations, release years, and ratings.
- Cleans and processes data for enhanced usability.

## Netflix Data
- Utilizes a publicly available Kaggle dataset.
- Cleans special characters and standardizes columns for analysis.
- Extracts key metadata, such as genre, director, and actors.

## Merged Dataset
- Combines IMDb and Netflix datasets using the title as a common key.
- Enhances the dataset by renaming and reformatting columns.
- Provides a unified view of movie characteristics across platforms.

## Visualizations
### Director Ratings
- Identifies the top 20 directors based on average IMDb ratings.
- Uses bar plots to highlight top-performing directors.

### Movie Releases Over the Years
- Examines the number of movies released each year.
- Analyzes trends in IMDb ratings over time.

## Tools and Libraries Used
- **R Programming:** Data extraction, cleaning, and analysis.
- **Libraries:**
  - `rvest`: For web scraping IMDb data.
  - `dplyr`, `tidyverse`: For data manipulation and cleaning.
  - `ggplot2`: For creating insightful visualizations.

## How to Use
1. Clone the repository to your local machine.
2. Ensure R and the required libraries are installed.
3. Run the provided R scripts to reproduce the analysis and visualizations.

## Output
- Cleaned datasets (`imdb_data.csv`, `cleaned_netflix_data.csv`, `merged_dataset.csv`).
- Visualizations showcasing trends and key findings.
