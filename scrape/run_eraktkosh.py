#!/usr/bin/env python3.9

import papermill
import os

# Change to the directory where the notebook file is located
os.chdir('/Users/jonathanold/pCloud Drive/_Berkeley Research/Blood Donations/blood-donations-india/scrape/')


# Execute the notebook
papermill.execute_notebook(input_path='scrape_eraktkosh.ipynb', output_path='scrape_eraktkosh_done.ipynb')