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
plt.savefig("/Users/sousekilyu/Downloads/ttt5.png")

# %%
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

# Get the full list of styles
sns.set_theme(rc={'figure.figsize':(12,12)})
sns.axes_style()
custom = {"axes.edgecolor": "red", "grid.linestyle": "dashed", "grid.color": "black"}
sns.set_style("darkgrid", rc = custom)

# load dataset
tips = sns.load_dataset("tips")
# Create a boxplot
sns.boxplot(x="day", y="total_bill", data=tips)
# Set plot title and labels
plt.title("Boxplot of Total Bill by Day")
plt.xlabel("Day")
plt.ylabel("Total Bill")
# Save the plot to a file before displaying it
plt.savefig("/Users/sousekilyu/Downloads/ttt10.png")
# Display the plot
plt.show()

penguins = sns.load_dataset("penguins")
sns.pairplot(penguins)
plt.savefig("/Users/sousekilyu/Downloads/ttt11.png")
#%%

