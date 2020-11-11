##################################################################
#  Name:   Data Management Using R.R                             #
#  Date:   October 24, 2020                                      #
#  Author: Bomi Lee                                              #
#  Purpose: Basic data managmement for first time users          #
#  Thanks to Desmond D. Wallace for some of this code.           #          
##################################################################

# Install and load needed packages

install.packages("gapminder")
#install.packages("rio")
install.packages("tidyverse")
library("gapminder")
#library("rio")
library("tidyverse")


# Load gapminder data

exData <- gapminder

# Export/Import Data

export(exData,
       file = "gapminder.csv") # File type determined by file extension

convert(in_file = "./gapminder.csv",
        out_file = "./gapminder.dta")

exData2 <- import(file = "./gapminder.dta")

ex.readcsv <- read.csv("gapminder.csv")

rm(exData2, ex.readcsv)


# Data Manipulation

View(exData)
names(exData)
head(exData)
summary(exData)

## select - select variables

### Pipe (%>%) Approach (Read function left to right)

exData_gdp <- exData %>%
                select("country", "year", "gdpPercap")
head(exData_gdp)
View(exData_gdp)

exData_gdp2 <- exData[,c(1,3,6)]
View(exData_gdp2)

#exData_gdp3 <- exData[,-c(2,4,5)]
#View(exData_gdp3)

exData_gdp4 <- exData[-1,c("country", "year", "gdpPercap")]
#View(exData_gdp4)


## arrange - Arrange rows by variables

### Which countries have the largest populations?

arrange(exData,
        desc(pop))

which.max(exData$pop)
exData[300,]

### Which countries have the smallest populations?

arrange(exData,
        (pop))

which.min(exData$pop)
exData[1297,]


## filter - Return rows with matching conditions

### Which countries had the largest population in 2007?

exData %>%
  filter(year == 2007) %>%
  arrange(desc(pop))

## select - Select variables by name

### Which countries had the largest life expectancy in 2007?

exData %>%
  filter(year == 2007) %>%
  arrange(desc(lifeExp)) %>%
  select(country, lifeExp)


## mutate/transmute - Add new variables

### What is the Gross Domestic Product (GDP) of each country?

exData %>%
  mutate(gdp = pop * gdpPercap)

exData %>%
  transmute(gdp = pop * gdpPercap)

### NOTE: mutate adds variables only; transmute adds variables and removes other variables

## summarise - Reduces multiple values down to a single value

### What was the average GDP?

exData %>%
  mutate(gdp = pop * gdpPercap) %>%
  summarise(mean_gdp = mean(gdp))

## group_by - Group by one or more variables

### What was the average GDP for each year?

exData %>%
  mutate(gdp = pop * gdpPercap) %>%
  group_by(year) %>%
  summarise(mean_gdp = mean(gdp))

## bind_rows/bind_cols - Efficiently bind multiple data frames by row and column

### bind_rows - Appends objects vertically

exData0207 <- bind_rows(exData %>%
                          filter(year == 2002),
                        exData %>%
                          filter(year == 2007))

view(exData0207)

### bind_cols - Appends objects horizontally

exDataAB <- bind_cols(exData %>%
                        filter(year == 2002) %>%
                        select(country,
                               continent),
                      exData %>%
                        filter(year == 2002) %>%
                        select(year))
view(exDataAB)

## join functions - Join two tbls together

### left_join - return all rows from x, and all columns from x and y. Rows in x
### with no match in y will have NA values in the new columns. If there are
### multiple matches between x and y, all combinations of the matches are returned.

exDataAB2 <- left_join(x = exData %>%
                         filter(year == 2002) %>%
                         select(country,
                                continent),
                       y = exData %>%
                         filter(year == 2002) %>%
                         select(country,
                                year),
                       by = "country")
?right_join
?full_join


# Unemployment rate (https://data.oecd.org/unemp/unemployment-rate.htm)

unemp <- import("./DP_LIVE_07042019232133993.csv")
head(unemp)
View(unemp)
names(unemp)

class(unemp$TIME)

unemp_kor_m <- unemp %>%
  filter(LOCATION=="KOR") %>%
  separate(TIME, c("year", "month"), sep = "-") %>%
  transmute(year = as.numeric(year),
            month = as.numeric(month),
            unemp_k = Value)

head(unemp_kor_m)

export(unemp_kor_m, "kor_unemp_m.csv")
write.csv(unemp_kor_m, "kor_unemp_m2.csv", row.names = FALSE, na = "")

## Quarterly
unemp_kor_q <- unemp %>%
  filter(LOCATION=="KOR") %>%
  separate(TIME, c("year", "month"), sep = "-") %>%
  transmute(month = as.numeric(month),
            year =  as.numeric(year), 
            quarter = ifelse((month>=1)&(month<4), 1, 
                             ifelse((month>=4)&(month<7), 2, 
                                    ifelse((month>=7)&(month<10), 3, 4))),
            unemp_k = Value) %>%
  group_by(year, quarter) %>%
  summarize(unemp_k_q = mean(unemp_k, na.rm=TRUE))

View(unemp_kor_q)
export(unemp_kor_q, "kor_unemp_q.csv")