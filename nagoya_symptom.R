library(readr)
library(readxl)
library(tableone)
library(lubridate)
library(dplyr)

symptom <- read_table2("data/nagoya/symptom.txt", col_names = FALSE)
symptom$date <- sapply(symptom$X1, function(filename) {
  if (startsWith(filename, "R")) {
    return(as.character(as_date(paste0("2020", substring(filename, 3, 6)))))
  } else if (!is.na(suppressWarnings(as.numeric(substring(filename, 6, 6))))) {
    return(as.character(as_date(paste0("2020", substring(filename, 3, 6)))))
  } else {
    return(as.character(as_date(paste0("2020", substring(filename, 2, 5)))))
  }
})

onset <- read_table2("data/nagoya/onset.txt", col_names = FALSE)
positive <- read_table2("data/nagoya/positive.txt", col_names = FALSE)

symptom <- merge(symptom, onset, by = c("X1", "X2"))
symptom <- merge(symptom, positive, by = c("X1", "X2"))

symptom$onset <- sapply(symptom$X3.y, function(x) {
  if (is.na(x) | x == "―") {
    return(NA)
  } else if (x == "調査中") {
    return("調査中")
  }
  
  s <- strsplit(x, ",")
  return(paste("2020", s[[1]][1], s[[1]][2], sep = "-"))
})

symptom$positive <- sapply(symptom$X3, function(x) {
  if (is.na(x))
    return(NA)
  
  s <- strsplit(x, ",")
  return(paste("2020", s[[1]][1], s[[1]][2], sep = "-"))
})

nagoya <- data.frame(備考 = paste0("名古屋市発表", 1:nrow(symptom)),
                     症状 = symptom$X3.x[order(symptom$date, symptom$X2)],
                     発症日 = symptom$onset[order(symptom$date, symptom$X2)],
                     確定日 = symptom$positive[order(symptom$date, symptom$X2)])


aichi_summary <- read_csv("data/aichi_summary.csv", quote = "\"")
aichi_summary$発表日 <- sapply(aichi_summary$発表日, function(x) {
  month <- strsplit(x, "月")[[1]][1]
  day <- strsplit(strsplit(x, "月")[[1]][2], "日")[[1]][1]
  paste0("2020-", month, "-", day)
})

dataset <- merge(aichi_summary, nagoya, by = "備考", sort = FALSE)
dataset$確定までの日数 <- as_date(dataset$確定日) - as_date(dataset$発症日)

age <- numeric(nrow(dataset))
age[grep("0歳", dataset$`年代性別`)] <- 0
age[grep("10歳未満", dataset$`年代性別`)] <- 0
age[grep("10代", dataset$`年代性別`)] <- 10
age[grep("20代", dataset$`年代性別`)] <- 20
age[grep("30代", dataset$`年代性別`)] <- 30
age[grep("40代", dataset$`年代性別`)] <- 40
age[grep("50代", dataset$`年代性別`)] <- 50
age[grep("60代", dataset$`年代性別`)] <- 60
age[grep("70代", dataset$`年代性別`)] <- 70
age[grep("80代", dataset$`年代性別`)] <- 80
age[grep("90代", dataset$`年代性別`)] <- 90

sex <- character(nrow(dataset))
sex[grep("男性", dataset$`年代性別`)] <- "男性"
sex[grep("女性", dataset$`年代性別`)] <- "女性"


dataset$年代 <- age
dataset$性別 <- sex

plot_ly(dataset, x = ~確定日, y = ~確定までの日数, type = "box")
library(plotly)


boxplot(as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-1"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-1"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-2"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-2"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-3"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-3"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-4"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-4"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-5"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-5"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-6"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-6"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-7"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-7"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-8"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-8"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-9"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-9"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-10"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-10"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-11"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-11"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-12"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-12"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-13"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-13"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-14"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-14"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-15"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-15"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-16"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-16"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-17"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-17"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-18"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-18"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-19"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-19"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-20"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-20"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-21"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-21"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-22"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-22"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-23"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-23"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-24"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-24"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-25"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-25"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-26"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-26"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-27"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-27"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-28"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-28"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-29"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-29"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-30"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-30"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-7-31"]) - as_date(dataset$発症日[dataset$確定日 == "2020-7-31"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-8-1"]) - as_date(dataset$発症日[dataset$確定日 == "2020-8-1"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-8-2"]) - as_date(dataset$発症日[dataset$確定日 == "2020-8-2"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-8-3"]) - as_date(dataset$発症日[dataset$確定日 == "2020-8-3"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-8-4"]) - as_date(dataset$発症日[dataset$確定日 == "2020-8-4"])),
        as.numeric(as_date(dataset$確定日[dataset$確定日 == "2020-8-5"]) - as_date(dataset$発症日[dataset$確定日 == "2020-8-5"])))

mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-14"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-14"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-15"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-15"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-16"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-16"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-17"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-17"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-18"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-18"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-19"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-19"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-20"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-20"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-21"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-21"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-22"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-22"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-23"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-23"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-24"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-24"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-25"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-25"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-26"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-26"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-27"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-27"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-28"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-28"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-29"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-29"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-30"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-30"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-7-31"]) - as_date(dataset$確定日[dataset$確定日 == "2020-7-31"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-8-1"]) - as_date(dataset$確定日[dataset$確定日 == "2020-8-1"])))
mean(as.numeric(as_date(dataset$発表日[dataset$確定日 == "2020-8-2"]) - as_date(dataset$確定日[dataset$確定日 == "2020-8-2"])))

symptom <- read_table2("data/aichi/symptom.txt", col_names = FALSE)
symptom$date <- sapply(symptom$X1, function(filename) {
  if (startsWith(filename, "press")) {
    return(as.character(as_date(paste0("20", substring(filename, 18, 23)))))
  } else {
    return(as.character(as_date(paste0("2020年", filename))))
  }
})

aichi <- data.frame(備考 = paste0("本県発表", 1:nrow(symptom) + 2),
                    症状 = symptom$X3[order(symptom$date, symptom$X2)])

dataset <- merge(X20200720, rbind(nagoya, aichi), by = "備考")

sex <- character(nrow(dataset))
sex[grep("男性", dataset$`年代・性別`)] <- "男性"
sex[grep("女性", dataset$`年代・性別`)] <- "女性"

age <- character(nrow(dataset))
age[grep("0歳", dataset$`年代・性別`)] <- "0歳"
age[grep("10歳未満", dataset$`年代・性別`)] <- "10歳未満"
age[grep("10代", dataset$`年代・性別`)] <- "10代"
age[grep("20代", dataset$`年代・性別`)] <- "20代"
age[grep("30代", dataset$`年代・性別`)] <- "30代"
age[grep("40代", dataset$`年代・性別`)] <- "40代"
age[grep("50代", dataset$`年代・性別`)] <- "50代"
age[grep("60代", dataset$`年代・性別`)] <- "60代"
age[grep("70代", dataset$`年代・性別`)] <- "70代"
age[grep("80代", dataset$`年代・性別`)] <- "80代"
age[grep("90代", dataset$`年代・性別`)] <- "90代"

dataset$年代 <- age
dataset$性別 <- sex

fever <- logical(nrow(dataset))
fever[grep("発熱", dataset$症状)] <- TRUE

cough <- logical(nrow(dataset))
cough[grep("咳", dataset$症状)] <- TRUE

fatigue <- logical(nrow(dataset))
fatigue[grep("倦怠感", dataset$症状)] <- TRUE

taste_and_smell <- logical(nrow(dataset))
taste_and_smell[c(grep("嗅覚", dataset$症状), grep("味覚", dataset$症状), grep("臭覚", dataset$症状))] <- TRUE

pneumonia <- logical(nrow(dataset))
pneumonia[grep("肺炎", dataset$症状)] <- TRUE

nothing <- logical(nrow(dataset))
nothing[grep("なし", dataset$症状)] <- TRUE

tab1 <- data.frame(年齢 = age,
                   性別 = sex,
                   接触状況 = dataset$接触状況,
                   発熱 = fever,
                   咳 = cough,
                   倦怠感 = fatigue,
                   嗅覚味覚 = taste_and_smell,
                   肺炎 = pneumonia,
                   なし = nothing)


CreateTableOne(vars = colnames(tab1)[-c(1,2,3)],
               strata = "年齢",
               data = tab1[1:457,] %>% filter(!is.na(接触状況)), 
               test = FALSE,
               addOverall = TRUE)

