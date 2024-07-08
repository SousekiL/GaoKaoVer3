# %%
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from IPython.display import display
from ipywidgets import interact, interactive, IntSlider, ToggleButtons

sns.choose_dark_palette(input='husl', as_cmap=False)
df = sns.load_dataset("tips")
sns.set_style("dark")
sns.set_theme(rc={'figure.figsize':(11.7, 8.27)})  # Set the figure size here

sns.boxplot(x = "day", y = "total_bill", data = df)
plt.savefig("/Users/sousekilyu/Downloads/ttt4.png")

# %%
# give me a case of plotting map using geopandas and geoplot


