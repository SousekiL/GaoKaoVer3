#' ---
#' title: "Changes in Popular Majors from 2020 to 2024"
#' output: github_document
#' ---
#' 
knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(warning = FALSE, message = FALSE)
knitr::opts_knit$set(root.dir = "/Users/sousekilyu/Documents/GitHub/GaoKaoVer3")

#' 
#' ## Data preparation
#'

## source the scripts
# source("/Users/sousekilyu/Documents/GitHub/GaoKaoVer2/main/function.r")
source("/Users/sousekilyu/Documents/GitHub/GaoKaoVer3/main/etl.R")

hist(dt_rank_cmb$score_by_school_scale)
#' 
#' ## 热门专业变化趋势分析
#' ### 热门专业，冷门专业

# Assuming `data` is your dataframe with columns: major, avg_scores, and year
# Filter top 30 majors by avg_scores within each year
top_majors <- dt_rank_cmb_rough %>%
    group_by(year, major) %>%
    summarise(avg_scores = mean(score_by_major_scale, na.rm = TRUE),
    countn = n()) %>%
    ungroup() %>%
    filter(countn >= 10, year %in% c(2020, 2024)) %>%
    arrange(desc(avg_scores)) %>%
    group_by(year)  %>%
    top_n(30, wt = avg_scores) %>%
    ungroup()
ggplot(top_majors, aes(x = reorder(major, avg_scores), y = avg_scores, fill = as.factor(year))) +
  geom_bar(stat = "identity") +
  facet_wrap(~ year, scales = "free_y") +
  coord_flip() +
  theme_bw() +
  theme(text = element_text(family = "Canger", size = 10),
        axis.text.x = element_text(
            angle = 45,
            hjust = 1,
            family = "Canger",
            size = 10
        ),
        title = element_text(family = "Canger", size = 12),
        legend.position = "none") +
  labs(title = paste0("Popular Majors in Shandong Province"), x = "Majors", y = "Majors Popularity")

ggsave(filename = "plot/Figure 0-1.png", width = 12, height = 16, dpi = 300)

bottom_majors <- dt_rank_cmb_rough %>%
    group_by(year, major) %>%
    summarise(avg_scores = mean(score_by_major_scale, na.rm = TRUE),
    countn = n()) %>%
    ungroup() %>%
    filter(countn >= 10, year %in% c(2020, 2024)) %>%
    arrange(desc(avg_scores)) %>%
    group_by(year)  %>%
    top_n(-30, wt = avg_scores) %>%
    ungroup()
ggplot(bottom_majors, aes(x = reorder(major, avg_scores), y = avg_scores, fill = as.factor(year))) +
  geom_bar(stat = "identity") +
  facet_wrap(~ year, scales = "free_y") +
  coord_flip() +
  theme_bw() +
  theme(text = element_text(family = "Canger", size = 10),
        axis.text.x = element_text(
            angle = 45,
            hjust = 1,
            family = "Canger",
            size = 10
        ),
        title = element_text(family = "Canger", size = 12),
        legend.position = "none") +
  labs(title = paste0("Popular Majors in Shandong Province"), x = "Majors", y = "Majors Popularity")

ggsave(filename = "plot/Figure 0-2.png", width = 12, height = 16, dpi = 300)


#' 
#' ## 热门专业与考生成绩分布关系
#' ### 高分段考生 vs 低分段考生
score_by_major_group_time <- dt_rank_cmb_rough %>%
    group_by(year) %>%
    arrange(score_by_major_scale) %>% 
    mutate(
        score_group = cut(
            score_by_major_scale,
            breaks = c(-Inf, 50, 70, 90, Inf),
            labels = c("低分段", "中低分段", "中高分段", "高分段")
        )
    )  %>% 
    arrange(score_by_school_scale) %>% 
    mutate(
        score_group_school = cut(
            score_by_school_scale,
            breaks = c(-Inf, 50, 70, 90, Inf),
            labels = c("低分段", "中低分段", "中高分段", "高分段")
    )
    )
head(score_by_major_group_time)

generate_plot <- function(time, top_n, title) {
    .data <- score_by_major_group_time %>%
        filter(
            score_group %in% c("低分段", "高分段"),
            year == time
        ) %>%
        group_by(score_group, major) %>%
        summarise(avg_scores = mean(score_by_major_scale, na.rm = TRUE), 
        countn = n(), .groups = "keep") %>%
        filter(countn >= 10)  %>% 
        group_by(score_group) %>%
        top_n(top_n, wt = avg_scores) %>%
        ungroup()
    .plot <- ggplot(.data, aes(x = reorder(major, avg_scores), y = avg_scores, fill = as.factor(score_group))) +
        geom_bar(stat = "identity") +
        facet_wrap(~ score_group, scales = "free_y") +
        coord_flip() +
        theme_bw() +
        theme(text = element_text(family = "Canger", size = 10),
        axis.text.x = element_text(
            angle = 45,
            hjust = 1,
            family = "Canger",
            size = 10
        ),
        title = element_text(family = "Canger", size = 12),
        legend.position = "none") +
        labs(title = paste0(time, " ", title), x = "Majors", y = "Majors Popularity")
  return(.plot)
}
# Generate plots
# 2020
p1 <- generate_plot(2020, 30,
                    title = "Popular Majors in Shandong Province")
print(p1)
ggsave(p1, filename = "plot/Figure 1-1.popular_major_by_score_2020.png", width = 12, height = 16, dpi = 300)

# 2024
p2 <- generate_plot(2024, 30,
                    title = "Popular Majors in Shandong Province")
print(p2)
ggsave(p2, filename = "plot/Figure 1-2.popular_major_by_score_2024.png", width = 12, height = 16, dpi = 300)

# 2020
p3 <- generate_plot(2020, -30,
                    title = "Unpopular Majors in Shandong Province")
print(p3)
ggsave(p3, filename = "plot/Figure 1-3.unpopular_major_by_score_2020.png", width = 12, height = 16, dpi = 300)

# 2024
p4 <- generate_plot(2024, -30,
                    title = "Unpopular Majors in Shandong Province")
print(p4)
ggsave(p4, filename = "plot/Figure 1-4.unpopular_major_by_score_2024.png", width = 12, height = 16, dpi = 300)

#' 
#' ## 从低分段 跃迁至高分段的 学校和专业
## 所有高校
# (中)高分段=>(中)低分段
high2low <- score_by_major_group_time %>%
    filter((year == 2020 & score_group %in% c("高分段", "中高分段")) |
        (year == 2024 & score_group %in% c("低分段", "中低分段"))) %>%
    dplyr::select(院校, major, major_rough, year, score_by_major_scale) %>%
    group_by(院校, major, major_rough) %>%
    arrange(year) %>%
    summarise(
        countn = n(),
        score_by_major_early = first(score_by_major_scale),
        score_by_major_later = last(score_by_major_scale),
        score_by_major_change = score_by_major_later - score_by_major_early,
        .groups = "drop"
    ) %>%
    filter(countn == 2) %>%
    arrange(score_by_major_change) %>%
    mutate(school_major = paste0(substr(院校, 5, nchar(院校)), "+", major)) %>%
    filter(!is.na(school_major))

# 高分段=>(中)低分段
low2high <- score_by_major_group_time %>%
    filter((year == 2020 & score_group %in% c("低分段", "中低分段")) |
        (year == 2024 & score_group %in% c("高分段", "中高分段"))) %>%
    dplyr::select(院校, major, major_rough, year, score_by_major_scale) %>%
    group_by(院校, major, major_rough) %>%
    arrange(year) %>%
    summarise(
        countn = n(),
        score_by_major_early = first(score_by_major_scale),
        score_by_major_later = last(score_by_major_scale),
        score_by_major_change = score_by_major_later - score_by_major_early,
        .groups = "drop"
    ) %>%
    filter(countn == 2) %>%
    arrange(desc(score_by_major_change)) %>%
    mutate(school_major = paste0(substr(院校, 5, nchar(院校)), "+", major)) %>%
    filter(!is.na(school_major))
# plot: https://www.r-bloggers.com/2017/06/bar-plots-and-modern-alternatives/
phl01 <- high2low[1:30, ] %>%
    ggdotchart(
        x = "school_major", y = "score_by_major_change",
        color = "#F8756D",
        sorting = "descending",
        add = "segments",
        dot.size = 6,
        ggtheme = theme_pubr()
    ) +
    rotate() +
    # theme_bw() +
    theme(text = element_text(family = "Canger", size = 10),
        title = element_text(family = "Canger", size = 12),
        legend.position = "none") +
    labs(title = "Majors from High to Low Scores Level", x = "Universities / Majors", y = "Δ Popularity")
print(phl01)
ggsave(phl01,
    filename = "plot/Figure 2-1.high2low.png",
    width = 14,
    height = 16,
    dpi = 300
)
phl02 <- low2high[1:30, ] %>%
    ggdotchart(
        x = "school_major", y = "score_by_major_change",
        color = "#00BA38",
        sorting = "ascending",
        add = "segments",
        dot.size = 6,
        ggtheme = theme_pubr()
    ) +
    rotate() +
    # theme_bw() +
    theme(text = element_text(family = "Canger", size = 10),
        title = element_text(family = "Canger", size = 12),
        legend.position = "none") +
    labs(title = "Majors from Low to High Scores Level", x = "School / Major", y = "Δ Popularity")
print(phl02)
ggsave(phl02,
    filename = "plot/Figure 2-2.low2high.png",
    width = 14,
    height = 16,
    dpi = 300
)


#' 
#' ## 2020-2024专业热度变化分布
# Plot the distribution of the change in scores by major
# Calculate the average scores by major
avg_scores <- score_by_major_rough_change %>%
    filter(major_rough %in% majorData_rough$major) %>%
    group_by(major_rough) %>%
    summarise(avg_score = mean(score_by_major_change), .groups = "keep")
head(avg_scores)
# Add the average scores to the graph
p <- score_by_major_rough_change %>%
    filter(major_rough %in% majorData_rough$major) %>%
    mutate(color = ifelse(score_by_major_change >= 0, "上涨", "下降")) %>%
    ggplot(aes(x = score_by_major_change, fill = color)) +
    geom_histogram(bins = 100) +
    facet_wrap(~ reorder(major_rough, score_by_major_change, FUN = mean), dir = "h") +
    coord_cartesian(xlim = c(-30, 30), ylim = c(0, 150)) +
    scale_fill_manual(
        values = c("上涨" = "#00BA38", "下降" = "#F8756D"),
        labels = c("上涨" = "Increase", "下降" = "Decrease"),
        name = "Δ Popularity"
    ) +
    theme_bw() +
    theme(
        text = element_text(family = "Canger", size = 10),
        title = element_text(family = "Canger", size = 12),
        legend.position = c(.8, .07),
    ) +
    labs(title = "Histogram of Popularity Changes in Major Categories", x = "2020-2024 Δ Popularity", y = "Freq.")
# save png
print(p)
ggsave(p,
    filename = "plot/Figure 3-1.score_by_major_rough_change.png",
    width = 16,
    height = 12,
    dpi = 300
)

#' ## 热门高校变化
#' ### 热门高校一线&新一线城市聚集度变化

# # 高分学校在大城市占比 vs 高分专业在大城市占比。学校分数线体现底线思维，专业分数线体现择优思维。结果：重点城市的高分学校聚集度上涨，高分专业聚集度没有上涨
# #' 说明：
# #' 1. 从学校报考维度，学生倾向于去重点城市的学校就读，区域因素很重要，用重点城市学校「托底」；
# #' 2. 从专业选择角度，学生更加实际，在能选择的范围内专业优先，而非地域优先。
# score_by_major_group_time %>%
#     filter(score_group_school %in% c("中高分段", "高分段")) %>%
#     dplyr::select(school, year, city, province, score_group_school) %>%
#     unique() %>%
#     group_by(year) %>%
#     summarise(
#         fraction = round(sum(ifelse(city %in% core_city, 1, 0)) / n(), 3)
#     )
# #
# score_by_major_group_time %>%
#     filter(score_group %in% c("中高分段", "高分段")) %>%
#     dplyr::select(school, major, year, city, province, score_group) %>%
#     unique() %>%
#     group_by(year) %>%
#     summarise(
#         fraction = round(sum(ifelse(city %in% core_city, 1, 0)) / n(), 3)
#     )
# ## 论据：主要大城市的「热门」专业占比并没有显著增加
# score_by_major_group_time %>%
#     filter(city %in% core_city) %>%
#     dplyr::select(school, major, major_rough, year, city, province, score_group) %>%
#     group_by(year) %>%
#     summarise(
#         fraction = round(sum(ifelse(major_rough %in% c("软件工程", "电气类", "汉语言", "计算机类", "通信类"), 1, 0)) / n(), 3)
#     )

#' 
#' ### 重点高校专业热度变化 / 高分段学校的低分段专业，同
# !考虑到学校最低分收到专业极大影响，院校位次分数根据中位数排名，而非最低位次
dt_school_top <- dt_rank_cmb %>%
    mutate(school = substr(院校, 5, nchar(院校))) %>%
    filter(year == 2024) %>%
    mutate(rank = dense_rank(desc(score_by_school_scale))) %>%
    # filter(rank <= 30) %>%
    ungroup()
dt_school_top_change <- score_by_major_rough_change %>%
    filter(院校 %in% dt_school_top$院校) %>%
    left_join(unique(select(dt_school_top, 院校, score_by_school_scale, school, rank)),
        by = "院校"
    )
head(dt_school_top_change)

p_school_change <- dt_school_top_change %>%
    filter(rank <= 50) %>%
    ggplot(aes(
        x = score_by_major_change,
        y = reorder(school, score_by_school_scale),
        color = ifelse(score_by_major_change > 0, "#00BA38", "#F8756D")
    )) +
    geom_point(size = 5, alpha = .5) +
    scale_color_identity() +
    # scale_x_log10() +
    theme_bw() +
    theme(text = element_text(family = "Canger", size = 10),
          title = element_text(family = "Canger", size = 12),
          legend.position = "none") +
    labs(title = "Popularity Changes in Top 50 Unis' Majors, 2020-2024", x = "Δ Popularity", y = "Universities")
# save png
print(p_school_change)
ggsave(p_school_change,
    filename = "plot/Figure 4-1.top_uni_change_by_major.png",
    width = 12,
    height = 16,
    dpi = 300
)

# # zoom out
# p_school_change_zoom <- dt_school_top_change %>%
#     filter(rank <= 50) %>%
#     ggplot(aes(
#         x = score_by_major_change,
#         y = reorder(school, score_by_school_scale),
#         color = ifelse(score_by_major_change > 0, "#00BA38", "#F8756D")
#     )) +
#     geom_point(size = 5, alpha = .5) +
#     scale_color_identity() +
#     coord_cartesian(xlim = c(-5, 5)) +
#     # scale_x_log10() +
#     theme_bw() +
#     theme(text = element_text(family = "Canger", size = 10)) +
#     labs(title = "Popularity Changes in Top 50 Universities' Majors, 2020-2024", x = "Δ Popularity (Zoom out)", y = "Universities")
# # save png
# print(p_school_change_zoom)
# ggsaveTheme(p_school_change_zoom,
#     mytheme = my_theme,
#     filename = "plot/Figure 7.top_uni_change_by_major_zoom.png",
#     width = 12,
#     height = 16,
#     dpi = 300
# )

#'
#' ### Top50 cases
# Filter out the schools with the most significant changes in major scores.
.school_major <- dt_school_top_change %>%
    dplyr::select(school, rank, major, major_rough, score_by_major_change, score_by_school_scale) %>% 
    mutate(delta = ifelse(score_by_major_change > 0, 1, 0)) %>% 
    # top50
    filter(rank <= 50) %>%
    group_by(delta, school)  %>% 
    mutate(avg_majors_scores = mean(score_by_major_change, na.rm = TRUE))  %>% 
    ungroup() %>% 
    # 根据专业变化平均分对院校排序
    group_by(delta) %>% 
    mutate(rank_avg = dense_rank(desc(avg_majors_scores))) %>% 
    ungroup()

# up 5
 p_up <- .school_major %>% 
    dplyr::arrange(desc(avg_majors_scores), desc(score_by_major_change)) %>% 
    filter(delta == 1, 
    #between(avg_majors_scores, -0.2, 0.2),
    between(rank_avg, 1, 10)) %>% 
    ggplot(aes(
        x = score_by_major_change,
        y = reorder(school, avg_majors_scores),
        color = ifelse(score_by_major_change > 0, "#00BA38", "#F8756D")
    )) +
        geom_point(size = 5, alpha = .5) +
        scale_color_identity() +
        coord_cartesian(xlim = c(0, 8)) +
        geom_text_repel(aes(
            label = major
        ), 
        #angle = 45,
        vjust = -0.5,
        alpha = .7,
        min.segment.length = Inf,
        max.overlaps = 20,
        size = 2,
        family = "Canger",
        color = 'black')  +
        # scale_x_log10() +
        # coord_flip() +
        theme_bw() +
        theme(text = element_text(family = "Canger", size = 10),
              title = element_text(family = "Canger", size = 12),
              legend.position = "none") +
        labs(title = "Popularity Changes in Top Unis' Majors, 2020-2024", x = "Δ Popularity (Zoom out)", y = "Universities")
print(p_up)
ggsave(p_up,
    filename = "plot/Figure 4-2.up_major_names.png",
    width = 12,
    height = 16,
    dpi = 300
)

# down 5
 p_down <- .school_major %>%
     arrange(avg_majors_scores, score_by_major_change) %>% 
     filter(delta == 0, 
     #between(avg_majors_scores, -0.2, 0.2),
     between(rank_avg, length(unique(.school_major$rank_avg))-9, length(unique(.school_major$rank_avg)))) %>%
     ggplot(aes(
        x = score_by_major_change,
        y = reorder(school, avg_majors_scores),
        color = ifelse(score_by_major_change > 0, "#00BA38", "#F8756D")
    )) +
        geom_point(size = 5, alpha = .5) +
        scale_color_identity() +
        coord_cartesian(xlim = c(-10, 0)) +
        geom_text_repel(
            aes(
                label = major
            ),
            min.segment.length = Inf,
            max.overlaps = 20,
            size = 2,
            family = "Canger",
            color = "black",
            #angle = 45,
            vjust = -0.5,
        alpha = .7
        ) +
        # scale_x_log10() +
        #coord_flip() +
        theme_bw() +
        theme(text = element_text(family = "Canger", size = 10),
              title = element_text(family = "Canger", size = 12),
              legend.position = "none") +
        labs(title = "Popularity Changes in Top Unis' Majors, 2020-2024", x = "Δ Popularity (Zoom out)", y = "Universities")
print(p_down)
ggsave(p_down,
    filename = "plot/Figure 4-3.down_major_names.png",
    width = 12,
    height = 16,
    dpi = 300
)

#! comment for more details
 p_up2 <- .school_major %>%
     dplyr::arrange(desc(avg_majors_scores), desc(score_by_major_change)) %>%
     filter(delta == 1) %>%
     ggplot(aes(
         x = score_by_major_change,
         y = reorder(school, avg_majors_scores),
         color = ifelse(score_by_major_change > 0, "#00BA38", "#F8756D")
     )) +
     geom_point(size = 5, alpha = .5) +
     scale_color_identity() +
     coord_cartesian(xlim = c(0, 8)) +
     geom_text_repel(
         aes(
             label = major
         ),
         # angle = 45,
         vjust = -0.5,
         alpha = .7,
         min.segment.length = Inf,
         max.overlaps = 15,
         size = 2,
         family = "Canger",
         color = "black"
     ) +
     # scale_x_log10() +
     # coord_flip() +
     theme_bw() +
     theme(text = element_text(family = "Canger", size = 10),
           title = element_text(family = "Canger", size = 12),
          legend.position = "none") +
     labs(title = "Popularity Changes in Top Unis' Majors, 2020-2024", x = "Δ Popularity (Zoom out)", y = "Universities")
print(p_up2)
ggsave(p_up2,
     filename = "plot/Figure 4-4.png",
     width = 12,
     height = 20,
     dpi = 300
 )
p_down2 <- .school_major %>%
     arrange(avg_majors_scores, score_by_major_change) %>%
     filter(delta == 0) %>%
     ggplot(aes(
         x = score_by_major_change,
         y = reorder(school, avg_majors_scores),
         color = ifelse(score_by_major_change > 0, "#00BA38", "#F8756D")
     )) +
     geom_point(size = 5, alpha = .5) +
     scale_color_identity() +
     coord_cartesian(xlim = c(-5, 0)) +
     geom_text_repel(
         aes(
             label = major
         ),
         min.segment.length = Inf,
         max.overlaps = 15,
         size = 2,
         family = "Canger",
         color = "black",
         # angle = 45,
         vjust = -0.5,
         alpha = .7
     ) +
     # scale_x_log10() +
     # coord_flip() +
     theme_bw() +
     theme(text = element_text(family = "Canger", size = 10),
           title = element_text(family = "Canger", size = 12),
          legend.position = "none") +
     labs(title = "Popularity Changes in Top Unis' Majors, 2020-2024", x = "Δ Popularity (Zoom out)", y = "Universities")
print(p_down2)
ggsave(p_down2,
     filename = "plot/Figure 4-5.png",
     width = 12,
     height = 20,
     dpi = 300
 )


#'
#' ## 不同类型大学投档线变化
.lang <- score_by_major_group_time %>%
  filter(school %in% c("北京外国语大学",
                       "上海外国语大学",
                       "中国传媒大学",
                       "外交学院",
                       "北京语言大学",
                       "广东外语外贸大学",
                       "北京第二外国语学院",
                       "天津外国语大学",
                       "西安外国语大学",
                       "四川外国语大学",
                       "大连外国语大学")) %>%
  select(school, score_by_school_scale, year) %>%
  unique() %>%
  mutate(category = "Foreign Studies")
.law <- score_by_major_group_time %>%
  filter(school %in% c("中国政法大学",
                       "华东政法大学",
                       "西南政法大学",
                       "上海政法学院",
                       "西北政法大学")) %>%
  select(school, score_by_school_scale, year) %>%
  unique() %>%
  mutate(category = "Poli. Sci. & Law")
.fin <- score_by_major_group_time %>%
  filter(school %in% c("上海财经大学",
                       "中央财经大学",
                       "对外经济贸易大学",
                       "中南财经政法大学",
                       "西南财经大学"
                       # "东北财经大学",
                       # "江西财经大学"
                       )) %>%
  select(school, score_by_school_scale, year) %>%
  unique() %>%
  mutate(category = "Fin. & Econ.")
data_subject <- rbind(.lang, .law, .fin)
#
ggplot(data_subject, aes(x = year, y = score_by_school_scale, group = school, color = category)) +
  geom_line(lwd = 1) +
  geom_point() +
  facet_wrap(~ category) +
  geom_text_repel(
    data = data_subject[which(data_subject$year == 2024),],
    aes(label = school),
    family = "Canger",
    size = 3,
    direction = "y",
    xlim = c(2024.3, NA),
    hjust = 0,
    segment.size = .7,
    segment.alpha = .5,
    segment.linetype = "dotted",
    box.padding = .4,
    segment.curvature = -0.1,
    segment.ncp = 3,
    segment.angle = 20
  ) +
  scale_x_continuous(
    # expand = c(0, 0),
    limits = c(2020, 2025.5),
    breaks = seq(2020, 2024, by = 1)
  ) +
  labs(title = "专门类大学投档线, 2020-2024", x = "Year", y = "Δ Popularity") +
  theme_bw() +
  theme(text = element_text(family = "Canger", size = 10),
        title = element_text(family = "Canger", size = 12),
        legend.position = "none")

ggsave(filename = "plot/Figure 5-1.png",
     width = 16,
     height = 12,
     dpi = 300
 )

## top 3
data_subject2 <- data_subject %>%
  filter(school %in% c("北京外国语大学",
                       "上海外国语大学",
                       "中国传媒大学",
                       "上海财经大学",
                       "中央财经大学",
                       "对外经济贸易大学",
                       "中国政法大学",
                       "华东政法大学",
                       "西南政法大学"
  ))
ggplot(data_subject2, aes(x = year, y = score_by_school_scale, group = school, color = category)) +
  geom_line(lwd = 1) +
  geom_point() +
  facet_wrap(~ category) +
  geom_text_repel(
    data = data_subject2[which(data_subject2$year == 2024),],
    aes(label = school),
    family = "Canger",
    size = 3,
    direction = "y",
    xlim = c(2024.3, NA),
    hjust = 0,
    segment.size = .7,
    segment.alpha = .5,
    segment.linetype = "dotted",
    box.padding = .4,
    segment.curvature = -0.1,
    segment.ncp = 3,
    segment.angle = 20
  ) +
  scale_x_continuous(
    # expand = c(0, 0),
    limits = c(2020, 2025.5),
    breaks = seq(2020, 2024, by = 1)
  ) +
  labs(title = "专门类大学投档线, 2020-2024", x = "Year", y = "Δ Popularity") +
  theme_bw() +
  theme(text = element_text(family = "Canger", size = 10),
        title = element_text(family = "Canger", size = 12),
        legend.position = "none")

ggsave(filename = "plot/Figure 5-2.png",
     width = 16,
     height = 12,
     dpi = 300
 )
