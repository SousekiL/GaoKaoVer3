# %%
import pandas as pd
import numpy as np
from openpyxl import load_workbook
import os
import re
import matplotlib.pyplot as plt

os.chdir('/Users/sousekilyu/Documents/GitHub/GaoKaoVer3')

# %%
year = 2020
filepath = f"data/{year}年山东省普通一批投档线.xlsx"
dt = pd.read_excel(filepath, dtype=str)
dt = dt.dropna(axis=1, how='all')
dt.columns = ["专业", "院校", "计划数", "位次"]
dt = dt[~dt['专业'].str.contains("定向|预科")]
dt['院校'] = dt['院校'].apply(lambda x: re.sub(r"\(.*?\)|\{.*?\}|\[.*?\]", "", x))
dt['专业'] = dt['专业'].apply(lambda x: re.sub(r"\(.*?\)|\{.*?\}|\[.*?\]", "", x))
# Replace empty strings with '0' before converting to int
dt['位次'] = dt['位次'].fillna('0').astype(str).apply(lambda x: re.sub(r"前50名", "50", x) if x else '0').astype(int)
dt = dt[dt['位次'] != 0]
dt_school = dt[~dt['位次'].isna() & ~dt['位次'].isin([np.inf, -np.inf])]
dt_school = dt_school.groupby('院校').agg(rank_by_school=('位次', 'median')).reset_index()
dt_school.columns = ['院校', 'rank_by_school']
dt_school['rank_by_school'] = dt_school['rank_by_school'].astype(int)
dt = pd.merge(dt, dt_school, on='院校', how='left')
dt.head(35)
# %%
