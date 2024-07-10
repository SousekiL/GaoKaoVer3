# %%
import pandas as pd
import numpy as np
from openpyxl import load_workbook
import os
import re
import matplotlib.pyplot as plt

# Set working directory
os.chdir('/Users/sousekilyu/Documents/GitHub/GaoKaoVer3')

# Define the major lists
majorList = [
    ["新闻|传播", "新闻传播学"],
    ["法学|法律", "法学"],
    ["计算机", "计算机类"],
    ["软件", "软件工程"],
    ["土木", "土木工程类"],
    ["数据科学与大数据技术", "数据科学与大数据技术"],
    ["自然保护与环境生态|环境生态", "环境生态类"],
    ["轨道交通电气与控制", "轨道交通电气类"],
    ["旅游管理", "旅游管理"]
]

majorList2 = [
    ["新闻|传播|广告|出版", "新闻传播学"],
    ["翻译|外语|外国语|.*?语$", "外国语言文学"],
    ["法学|法律", "法学"],
    ["中文|汉语言", "汉语言"],
    ["哲学", "哲学"],
    ["金融", "金融类"],
    ["经济|贸易", "经济学类"],
    ["历史|文物|考古|文博", "历史学类"],
    ["政治学|思想政治", "政治学类"],
    ["工商管理", "工商管理"],
    ["心理", "心理学"],
    ["公共管理|行政管理|社会保障", "公共管理类"],
    ["社会学|社会工作|人类学|民族学|民俗学", "社会学类"],
    ["数学", "数学类"],
    ["电气", "电气类"],
    ["通信", "通信类"],
    ["电子", "电子类"],
    ["机械", "机械类"],
    ["计算机|人工智能", "计算机类"],
    ["软件", "软件工程"],
    ["土木", "土木工程类"],
    ["^统计学$|应用统计|经济统计", "统计学类"],
    ["建筑|城乡规划", "建筑学类"],
    ["生物", "生物类"],
    ["材料", "材料类"],
    ["化学", "化学类"],
    ["基地", "基地班"],
    ["拔尖", "拔尖班"],
    ["环境科学|环境工程", "环境科学类"],
    ["临床医学", "临床医学"],
    ["口腔", "口腔医学"],
    ["临床药学|药学", "药学类"],
    ["林学|林业|草|动物|水产|农业", "农业类"],
    ["信息管理|档案|图书", "信息管理与图书情报"],
    ["地球|地质", "地质学"]
]

# Convert the lists to dataframes
majorData = pd.DataFrame(majorList, columns=["noun", "major"])
majorData_rough = pd.DataFrame(majorList2, columns=["noun", "major"])

# Function to read and process data
def read_and_process_data(year):
    """
    读取并处理指定年份的山东省普通一批投档线数据。

    参数:
    year -- 数据的年份

    返回:
    dt -- 处理后的数据表，包含专业、院校、计划数和位次信息
    dt_school -- 经过处理的院校排名数据表
    """
    # 从Excel文件中读取数据，指定列类型为字符串，并去除所有列的空值
    dt = pd.read_excel(f"data/{year}年山东省普通一批投档线.xlsx", dtype=str).dropna(axis=1, how='all')

    # 重命名列
    dt.columns = ["专业", "院校", "计划数", "位次"]

    # 移除包含“定向”或“预科”的专业行
    dt = dt[~dt['专业'].str.contains("定向|预科")]

    # 移除院校和专业列中的括号内的信息
    dt[['院校', '专业']] = dt[['院校', '专业']].applymap(lambda x: re.sub(r"\(.*?\)|\{.*?\}|\[.*?\]", "", x))

    # 处理位次列，将“前50名”转换为数字50，并移除位次为0的行
    dt['位次'] = dt['位次'].fillna('0').astype(str).apply(lambda x: re.sub(r"前50名", "50", x) if x else '0').astype(int)
    dt = dt[dt['位次'] != 0]

    # 处理位次为正无穷或负无穷的行，并计算每个院校的位次中位数
    dt_school = dt[~dt['位次'].isin([np.inf, -np.inf])]
    dt_school = dt_school.groupby('院校').agg(rank_by_school=('位次', 'median')).reset_index()

    # 将院校的位次中位数转换为整数类型
    dt_school['rank_by_school'] = dt_school['rank_by_school'].astype(int)

    return dt, dt_school

# %%
# Read data
years = range(2020, 2024)
data_list = {f"dt{year}": read_and_process_data(year) for year in years}
# Split data
for year in years:
    globals()[f"dt{year}"], globals()[f"dt{year}_school"] = data_list[f"dt{year}"]
 
# %%
# Function to process data
def process_data(data):
    data['专业'] = data['专业'].str[2:]
    data = data.groupby(['院校', '专业']).agg({'计划数': 'sum', '位次': 'max'}).reset_index()
    return data

# Process data
dt2023_cmb_pd = process_data(dt2023)
dt2022_cmb_pd = process_data(dt2022)
dt2021_cmb_pd = process_data(dt2021)
dt2020_cmb_pd = process_data(dt2020)

# %% doing
dt2023_cmb_pd['major'] = np.nan

for i in range(len(majorData)):
    dt2023_cmb_pd.loc[df['专业'].str.contains(majorData.iloc[i, 0]), 'major'] = majorData.iloc[i, 1]

dt2023_cmb_pd['major'].fillna(dt2023_cmb_pd['专业'], inplace=True)
dt2023_cmb = dt2023_cmb_pd.groupby(['院校', 'major']).agg({'计划数': 'sum', '位次': 'max'}).reset_index()

# %%
# Function to update major
def update_major(df, majorData):
    """
    更新 DataFrame 中的专业信息，根据 majorData 中的规则。

    参数:
    df: pandas DataFrame，包含院校、专业和计划数等信息的数据表。
    majorData: pandas DataFrame，包含专业匹配规则和对应的新专业名称的数据表。

    返回:
    pandas DataFrame，更新后的数据表，新增了 'major' 列，表示更新后的主要专业。
    """
    # 初始化 'major' 列为空值
    df['major'] = np.nan

    # 遍历 majorData，根据专业匹配规则更新 df 中的专业名称
    for i in range(len(majorData)):
        # 当 '专业' 列包含 majorData 中的规则时，更新 'major' 列
        df.loc[df['专业'].str.contains(majorData.iloc[i, 0]), 'major'] = majorData.iloc[i, 1]

    # 对 'major' 列中仍为空值的行，使用 '专业' 列的值进行填充
    df['major'].fillna(df['专业'], inplace=True)

    # 按 '院校' 和 'major' 分组，对 '计划数' 进行求和，对 '位次' 进行取最大值，然后重置索引
    df = df.groupby(['院校', 'major']).agg({'计划数': 'sum', '位次': 'max'}).reset_index()

    return df

# Update major
dt2023_cmb = update_major(dt2023_cmb_pd, majorData)
dt2022_cmb = update_major(dt2022_cmb_pd, majorData)
dt2021_cmb = update_major(dt2021_cmb_pd, majorData)
dt2020_cmb = update_major(dt2020_cmb_pd, majorData)

# %%
# Function to perform operations
def perform_operations(data, dt_school, year):
    data = pd.merge(data, dt_school, on='院校')
    data['year'] = year
    return data

# Perform operations
dt2023_rank_cmb = perform_operations(dt2023_cmb, dt2023_school, 2023)
dt2022_rank_cmb = perform_operations(dt2022_cmb, dt2022_school, 2022)
dt2021_rank_cmb = perform_operations(dt2021_cmb, dt2021_school, 2021)
dt2020_rank_cmb = perform_operations(dt2020_cmb, dt2020_school, 2020)

# Bind rows
dt_rank_cmb = pd.concat([dt2023_rank_cmb, dt2022_rank_cmb, dt2021_rank_cmb, dt2020_rank_cmb])
dt_rank_cmb['school'] = dt_rank_cmb['院校'].str[4:]

# %%
# Load school data
school_data = pd.read_excel("/Users/sousekilyu/Documents/GitHub/GaoKaoVer2/data/全国普通高等学校名单.xlsx")[['school', 'city', 'province']]
dt_rank_cmb = pd.merge(dt_rank_cmb, school_data, on='school', how='left')

# Calculate scaled scores
dt_rank_cmb['score_by_major_scale'] = dt_rank_cmb.groupby('year')['位次'].apply(lambda x: 100 - (x - x.min()) / (x.max() - x.min()) * 100)
dt_rank_cmb['score_by_school_scale'] = dt_rank_cmb.groupby('year')['rank_by_school'].apply(lambda x: 100 - (x - x.min()) / (x.max() - x.min()) * 100)
dt_rank_cmb.rename(columns={'计划数': 'frequency'}, inplace=True)

# Calculate score changes
score_by_major_change = dt_rank_cmb[dt_rank_cmb['year'].isin([2020, 2023])].sort_values('year').groupby(['院校', 'major', 'province', 'city']).agg(
    countn=('year', 'count'),
    score_by_major_early=('score_by_major_scale', 'first'),
    score_by_major_later=('score_by_major_scale', 'last')
).reset_index()
score_by_major_change['score_by_major_change'] = score_by_major_change['score_by_major_later'] - score_by_major_change['score_by_major_early']
score_by_major_change = score_by_major_change[score_by_major_change['countn'] > 1].sort_values('score_by_major_change', ascending=False)

# Update major rough
score_by_major_rough_change = update_major(score_by_major_change, majorData_rough)
dt_rank_cmb_rough = update_major(dt_rank_cmb, majorData_rough)


# %%
#' ## function plot
# %%
# Define a function to save the plot with a theme
def save_plot_with_theme(p, filename, dpi):
    p.set_title('Title', fontsize=75, fontname='Canger')
    p.xaxis.label.set_size(50)
    p.yaxis.label.set_size(50)
    p.xaxis.set_tick_params(labelsize=50, rotation=45)
    p.yaxis.set_tick_params(labelsize=50)
    p.legend(prop={'size': 50, 'family': 'Canger'})
    p.figure.savefig(filename, dpi=dpi)

# Create a dataframe
df = pd.DataFrame({
    'score': [1, 2, 3, 4, 5],
    'frequency': [10, 20, 30, 25, 15]
})

# Calculate cumulative frequency
df['cum_frequency'] = df['frequency'].cumsum()

# Calculate total frequency
total_frequency = df['frequency'].sum()

# Define levels
levels = pd.cut(df['cum_frequency'], 
                bins=[0, total_frequency * 0.2, total_frequency * 0.4, total_frequency * 0.6, total_frequency * 0.8, total_frequency], 
                labels=["Very Low", "Low", "Medium", "High", "Very High"])

df['level'] = levels

# Plot
p = df.plot(kind='bar', x='score', y='frequency', legend=False)
p.set_xlabel('Score')
p.set_ylabel('Frequency')

# Save the plot with a theme
save_plot_with_theme(p, 'plot.png', 300)