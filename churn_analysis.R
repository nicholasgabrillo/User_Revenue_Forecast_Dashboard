df <- read.csv("~/Subscription Project/subscription_user_revenue_data.csv")

head(df)
str(df)
summary(df)

# dplyr will be used for data manipulation
# lubridate will assist with data handling
# ggplot2 will help plot the data and provide better visualizations

install.packages("dplyr")
install.packages("lubridate")
install.packages("ggplot2")

library(dplyr)
library(lubridate)
library(ggplot2)

df$month <- as.Date(df$month)
df$active <- as.logical(df$active)

# Monthly Active Users (MAU)
mau <- df %>%
  filter(active == TRUE) %>%
  group_by(month) %>%
  summarise(active_users = n_distinct(user_id))

# Monthly Revenue
monthly_rev <- df %>%
  group_by(month) %>%
  summarise(total_revenue = sum(revenue))

# Monthly Churn Rate
user_activity <- df %>%
  group_by(user_id) %>%
  arrange(user_id, month) %>%
  mutate(prev_active = lag(active))

churn_data <- user_activity %>%
  filter(prev_active == TRUE & active == FALSE) %>%
  group_by(month) %>%
  summarise(churned_users = n_distinct(user_id))

churn_summary <- left_join(mau, churn_data, by = 'month') %>%
  mutate(churn_rate = churned_users / lag(active_users))

# Plotting Active Users

ggplot(mau, aes(x = month, y = active_users)) +
  geom_line(color = "blue") +
  labs(title = "Monthly Active Users (MAU)", y = "Active Users", x = "Month")

# Plotting Total Revenue

ggplot(monthly_rev, aes(x = month, y = total_revenue)) +
  geom_line(color = "darkgreen") +
  labs(title = "Monthly Revenue", y = 'Revenue ($)', x = "Month")

# Plotting Churn Rate

ggplot(churn_summary, aes(x = month, y = churn_rate)) +
  geom_line(color = "red") +
  labs(title = "Monthly Churn Rate", y = "Churn Rate", x = "Month")
