# %%
## https://residentmario.github.io/geoplot/gallery/index.html

# %%
#' ## Sankey of traffic volumes in Washington DC
import geopandas as gpd
import geoplot as gplt
import geoplot.crs as gcrs
import matplotlib.pyplot as plt

dc_roads = gpd.read_file(gplt.datasets.get_path('dc_roads'))

gplt.sankey(
    dc_roads, projection=gcrs.AlbersEqualArea(),
    scale='aadt', limits=(0.1, 10), color='black'
)

plt.title("Streets in Washington DC by Average Daily Traffic, 2015")
plt.savefig("/Users/sousekilyu/Downloads/new_Streets in Washington DC by Average Daily Traffic.png",
            dpi=300)

# %%
#' ## KDEPlot of Boston AirBnB Locations
import geopandas as gpd
import geoplot as gplt
import geoplot.crs as gcrs
import matplotlib.pyplot as plt

boston_airbnb_listings = gpd.read_file(gplt.datasets.get_path('boston_airbnb_listings'))

ax = gplt.kdeplot(
    boston_airbnb_listings, cmap='viridis', projection=gcrs.WebMercator(), figsize=(12, 12),
    fill=True
)
gplt.pointplot(boston_airbnb_listings, s=1, color='black', ax=ax)
gplt.webmap(boston_airbnb_listings, ax=ax)
plt.title('Boston AirBnB Locations, 2016', fontsize=18)
plt.savefig("/Users/sousekilyu/Downloads/new_Boston AirBnB Locations.png", dpi=300)

# %%
#' ## Quadtree of San Francisco street trees
import geopandas as gpd
import geoplot as gplt
import geoplot.crs as gcrs
import matplotlib.pyplot as plt

trees = gpd.read_file(gplt.datasets.get_path('san_francisco_street_trees_sample'))
sf = gpd.read_file(gplt.datasets.get_path('san_francisco'))

plt.figure(figsize=(20, 12))
ax = gplt.quadtree(
    trees.assign(nullity=trees['Species'].notnull().astype(int)),
    projection=gcrs.AlbersEqualArea(),
    hue='nullity', nmax=1, cmap='Greens', scheme='Quantiles', 
    legend=True, legend_kwargs={'bbox_to_anchor': (1.35, 0.35), 'frameon': True},
    # legend_var='Species',
    # legend_values=[1.00, 0.97, 0.95, 0.90, 0.88],
    # legend_labels=['1.00', '0.97', '0.95', '0.90', '0.88'],
    clip=sf, edgecolor='white', linewidth=1
)
gplt.polyplot(sf, facecolor='None', edgecolor='gray', 
              linewidth=1, zorder=2, ax=ax)
plt.savefig("/Users/sousekilyu/Downloads/new_Quadtree of San Francisco street trees.png",
            dpi=300,
            bbox_inches='tight')

# %%
