#!/usr/bin/env python3

import papermill
import os

# Change to the directory where the notebook file is located
os.chdir('/Users/jonathanold/Library/CloudStorage/GoogleDrive-jonathan_old@berkeley.edu/My Drive/_Berkeley Research/Blood Donations/Code/Python/')


# Execute the notebook
papermill.execute_notebook(input_path='scrape_eraktkosh.ipynb', output_path='scrape_eraktkosh_done.ipynb')