# %%
# import 
import numpy as np

from bokeh.layouts import layout
from bokeh.models.widgets import Div
from bokeh.plotting import figure, show

from bokeh.io import output_notebook

output_notebook()

# %%
# helper function for coordinate conversion between lat/lon in decimal degrees to web mercator
def lnglat_to_meters(longitude: float, latitude: float) -> tuple[float, float]:
    """ Projects the given (longitude, latitude) values into Web Mercator
    coordinates (meters East of Greenwich and meters North of the Equator).

    """
    origin_shift = np.pi * 6378137
    easting = longitude * origin_shift / 180.0
    northing = np.log(np.tan((90 + latitude) * np.pi / 360.0)) * origin_shift / np.pi
    return (easting, northing)

description = Div(text="""<b><code>tile_demo.py</code></b> - Bokeh tile provider examples. Linked Pan and Zoom on all maps!""")

# %%
# Lady Bird Lake, Austin Texas
lat = 30.268801
lon = -97.763347

EN = lnglat_to_meters(lon, lat)
dE = 1000 # (m) Easting  plus-and-minus from map center
dN = 1000 # (m) Northing plus-and-minus from map center

x_range = (EN[0]-dE, EN[0]+dE) # (m) Easting  x_lo, x_hi
y_range = (EN[1]-dN, EN[1]+dN) # (m) Northing y_lo, y_hi

providers = [
    "CartoDB Positron",
    "CartoDB Positron retina",
    "OpenStreetMap Mapnik",
    "OpenTopoMap",
    "USGS.USTopo",
    "Esri World Imagery",
]

plots = []
for i, vendor_name in enumerate(providers):
    plot = figure(
        x_range=x_range, y_range=y_range,
        x_axis_type="mercator", y_axis_type="mercator",
        height=250, width=300,
        title=vendor_name,
        toolbar_location=None, active_scroll="wheel_zoom",
    )
    plot.add_tile(vendor_name)
    plots.append(plot)

layout = layout([
    [description],
    plots[0:3],
    plots[3:6],
])

show(layout)

# %%
try:
  import bokeh
except ImportError:
  print("Trying to Install required module: requests\n")
  os.system('/Users/sousekilyu/Documents/GitHub/GaoKaoVer3/.venv/bin/python -m pip install bokeh')

try:
  import bokeh.sampledata
except ImportError:
  print("Trying to Install required module: requests\n")
  os.system('/Users/sousekilyu/Documents/GitHub/GaoKaoVer3/.venv/bin/python -m pip install bokeh.sampledata')

from bokeh.models import LogColorMapper
from bokeh.palettes import Viridis6 as palette
from bokeh.plotting import figure, show
from bokeh import sampledata
sampledata.download()
from bokeh.sampledata.unemployment import data as unemployment
from bokeh.sampledata.us_counties import data as counties

# %%
palette = tuple(reversed(palette))

counties = {
    code: county for code, county in counties.items() if county["state"] == "tx"
}

county_xs = [county["lons"] for county in counties.values()]
county_ys = [county["lats"] for county in counties.values()]

county_names = [county['name'] for county in counties.values()]
county_rates = [unemployment[county_id] for county_id in counties]
color_mapper = LogColorMapper(palette=palette)

data=dict(
    x=county_xs,
    y=county_ys,
    name=county_names,
    rate=county_rates,
)

TOOLS = "pan,wheel_zoom,reset,hover,save"

# %% 
p = figure(
    title="Texas Unemployment, 2009", tools=TOOLS,
    x_axis_location=None, y_axis_location=None,
    tooltips=[
        ("Name", "@name"), ("Unemployment rate", "@rate%"), ("(Long, Lat)", "($x, $y)"),
    ])
p.grid.grid_line_color = None
p.hover.point_policy = "follow_mouse"

p.patches('x', 'y', source=data,
          fill_color={'field': 'rate', 'transform': color_mapper},
          fill_alpha=0.7, line_color="white", line_width=0.5)

show(p)


# %%
from bokeh.plotting import figure, show
from bokeh.sampledata.penguins import data
from bokeh.transform import factor_cmap, factor_mark
from bokeh.io import export_png

SPECIES = sorted(data.species.unique())
MARKERS = ['hex', 'circle_x', 'triangle']

p = figure(title = "Penguin size", background_fill_color="#fafafa", width=800, height=600)
p.xaxis.axis_label = 'Flipper Length (mm)'
p.yaxis.axis_label = 'Body Mass (g)'

p.scatter("flipper_length_mm", "body_mass_g", source=data,
          legend_group="species", fill_alpha=0.4, size=12,
          marker=factor_mark('species', MARKERS, SPECIES),
          color=factor_cmap('species', 'Category10_3', SPECIES))

p.legend.location = "top_left"
p.legend.title = "Species"

show(p)
# save p as png file with high dpi value
export_png(p, filename="/Users/sousekilyu/Downloads/penguin.png")

# %%
