# %%
import pandas as pd
import numpy as np
from openpyxl import load_workbook
import os
import re
import matplotlib.pyplot as plt

os.chdir('/Users/sousekilyu/Documents/GitHub/GaoKaoVer3')

# Define a function to clean up the data
def clean_data(x):
    return re.sub(r"\(.*?\)|\（.*?\）|\{.*?\}|\[.*?\]", "", x)

# Load the data
filepath = "data/2020年山东省普通一批投档线.xlsx"
dt = pd.read_excel(filepath, dtype=str)

# Drop empty columns and rename the columns
dt = dt.dropna(axis=1, how='all')
dt.columns = ["专业", "院校", "计划数", "位次"]

# Filter out rows containing "定向" or "预科" in '专业' column
dt = dt[~dt['专业'].str.contains("定向|预科")]

# Clean up '院校' and '专业' columns
dt['院校'] = dt['院校'].apply(clean_data)
dt['专业'] = dt['专业'].apply(clean_data)

# Replace empty strings with '0' before converting to int
dt['位次'] = dt['位次'].fillna('0').astype(str).apply(lambda x: re.sub(r"前50名", "50", x) if x else '0').astype(int)

# Filter out rows where '位次' is 0 or NaN or inf
dt = dt[dt['位次'] != 0]
dt = dt[~dt['位次'].isin([np.inf, -np.inf])]

# Calculate the median rank by school
dt_school = dt.groupby('院校').agg(rank_by_school=('位次', 'median')).reset_index()
dt_school['rank_by_school'] = dt_school['rank_by_school'].astype(int)

# Merge the original dataframe with the new 'rank_by_school' dataframe
dt = pd.merge(dt, dt_school, on='院校', how='left')

# Display the first 35 rows
dt.head(50)

#%%

