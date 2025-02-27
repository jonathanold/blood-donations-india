# Blood Donation and Availability Trends in India

This repository contains the analysis of trends in blood donations and blood availability across India. The project leverages data from various sources to provide insights into donation patterns, regional availability, and related health metrics.

## Project Structure

The project is organized into the following folders:

---

### `twitter/`

This folder contains data, scripts, and visualizations related to analyzing tweets about blood donation in India. The data is primarily sourced from the Twitter account [@BloodDonorsIn](https://twitter.com/BloodDonorsIn), which focuses on connecting blood donors with those in need. Below is a description of the files and their purpose:

#### **Files and Descriptions**

- **`tweepy.ipynb`**: A Jupyter Notebook that demonstrates how to use the Tweepy library to scrape tweets from Twitter. It includes code for authenticating with the Twitter API, retrieving user information, and collecting tweet data.
- **`tweets-cleaning.ipynb`**: This notebook processes, cleans, and merges multiple CSV and Excel files containing scraped tweets. The final cleaned dataset is saved as `final_df.csv`.
- **`cities-blood-groups.ipynb`**: A notebook analyzing the relationship between cities, blood groups, and tweet activity. It uses visualization libraries like Seaborn and Matplotlib to generate insights.
- **Visualizations**:
    - **`plot_2021_week.pdf`**: A visualization showing tweet counts by week during 2021.
    - **`plot_2022_week.pdf`**: A visualization showing tweet counts by week during 2022.
    - **`plot_2023_week.pdf`**: A visualization showing tweet counts by week during 2023.
    - **`bloodgroups.pdf`**: A chart showing tweet volumes categorized by blood type.
    - **`cities.pdf`**: A visualization highlighting tweet activity across different cities.
    - **`twitter_vs_pop.pdf`**: A comparison of Twitter requests for blood donations versus population proportions across regions.
    - **`units.pdf`**: A chart displaying the number of blood units demanded in tweets.


---

### `scrape/`

This folder contains scripts, notebooks, and data files used to scrape and process information about blood banks and their availability in India. The focus is on extracting data from platforms like eRaktKosh and a specific state-level dataset (i.e., from Odisha). Below is a detailed description of the files and their purpose:

#### **Files and Descriptions**

- **`run_eraktkosh.py`**: A Python script that automates the execution of the `scrape_eraktkosh.ipynb` notebook using `papermill`. It processes blood bank data from the eRaktKosh platform.
- **`run_odisha.py`**: Similar to `run_eraktkosh.py`, this script uses `papermill` to execute the `scrape_odisha.ipynb` notebook. It focuses on extracting blood bank data specific to Odisha.
- **`scrape_eraktkosh_done.ipynb`**: A completed Jupyter Notebook that scrapes data from the eRaktKosh platform. It uses Python libraries such as `requests`, `BeautifulSoup`, and `pandas` to extract and process blood bank information across various states in India. The notebook includes:
    - Base URLs for accessing blood bank stock details.
    - Headers for HTTP requests.
    - Code to parse JSON responses and extract relevant details like blood group availability, last update timestamps, and contact information.
- **`scrape_odisha_done.ipynb`**: A completed Jupyter Notebook that specifically extracts blood bank information for Odisha. It includes:
    - Code to send HTTP requests to relevant APIs.
    - Parsing of responses to retrieve details such as district IDs, blood bank IDs, and stock availability.
    - Outputs containing structured data about blood banks in Odisha.
- **`odisha_distid_bbid_list.csv`**: A CSV file mapping district IDs (`distid`) to blood bank IDs (`bbid`) for Odisha. This file is used as a reference in the scraping process to identify specific blood banks within districts.

---
### `analysis/`
This folder contains scripts and notebooks used for data analysis and visualization. Below is a brief description of the files included:

- **`eRaktKosh.do`**: A script analyzing data from the eRaktKosh platform to study trends in blood bank usage and availability.
- **`punjab_data.do`**: A script focusing on blood donation trends specifically in Punjab, India.
- **`wvs.do`**: Code analyzing World Values Survey (WVS) data, finding cross-country correlations between social values and blood donation rates.
- **`tweets.do`**: A script for analyzing requests for blood donations reposted on Twitter at `https://x.com/BloodDonorsIn`.
- **`make_map.do`**: A script for generating geographic visualizations of blood donation statistics across regions.
- **`make_anemia_map.ipynb`**: A Jupyter Notebook that processes geospatial anemia prevalence data and creates maps to visualize anemia-related health metrics across India.


---
## Requirements

To run the scripts and notebooks, ensure you have the following installed:
- Python 3.x
- Jupyter Notebook
- Required Python packages (install using `pip install -r requirements.txt`)

## Usage

1. Clone this repository:
```
git clone https://github.com/yourusername/blood-donation-trends.git
cd blood-donation-trends
```

2. Install dependencies:
```

pip install -r requirements.txt

```

3. Navigate to the `analysis/` folder and run the desired script or notebook:
```

jupyter notebook make_anemia_map.ipynb

```

4. Modify the scripts as needed to analyze specific datasets or generate additional visualizations.

## Data Sources

The analysis uses data from the following sources:
- [eRaktKosh](https://www.eraktkosh.in)
- World Values Survey (WVS)
- Social media platforms (e.g., Twitter)
- Geospatial anemia prevalence datasets

## Outputs

The project generates:
- Statistical analyses of blood donation trends and the fluctuation of blood availability across space and time.
- Geographic maps visualizing anemia prevalence and blood availability.

## Contributing

Contributions are welcome! If you'd like to contribute, please fork this repository, make your changes, and submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to reach out if you have any questions or suggestions!
