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

dataset$備考 <- sub("名古屋市発表", "", dataset$備考)


output <- data.frame(名古屋市No = dataset$備考,
                     愛知県No = dataset$愛知県ID,
                     年代 = dataset$年代,
                     性別 = dataset$性別,
                     国籍 = dataset$国籍,
                     住居地 = dataset$住居地,
                     接触状況 = dataset$接触状況,
                     症状 = dataset$症状,
                     発症日 = dataset$発症日,
                     陽性確定日 = dataset$確定日,
                     発表日 = dataset$発表日)

output$発症日 <- gsub("０", "0", output$発症日)
output$発症日 <- gsub("１", "1", output$発症日)
output$発症日 <- gsub("２", "2", output$発症日)
output$発症日 <- gsub("３", "3", output$発症日)
output$発症日 <- gsub("４", "4", output$発症日)
output$発症日 <- gsub("５", "5", output$発症日)
output$発症日 <- gsub("６", "6", output$発症日)
output$発症日 <- gsub("７", "7", output$発症日)
output$発症日 <- gsub("８", "8", output$発症日)
output$発症日 <- gsub("９", "9", output$発症日)

output$陽性確定日 <- gsub("０", "0", output$陽性確定日)
output$陽性確定日 <- gsub("１", "1", output$陽性確定日)
output$陽性確定日 <- gsub("２", "2", output$陽性確定日)
output$陽性確定日 <- gsub("３", "3", output$陽性確定日)
output$陽性確定日 <- gsub("４", "4", output$陽性確定日)
output$陽性確定日 <- gsub("５", "5", output$陽性確定日)
output$陽性確定日 <- gsub("６", "6", output$陽性確定日)
output$陽性確定日 <- gsub("７", "7", output$陽性確定日)
output$陽性確定日 <- gsub("８", "8", output$陽性確定日)
output$陽性確定日 <- gsub("９", "9", output$陽性確定日)

output$発表日 <- gsub("０", "0", output$発表日)
output$発表日 <- gsub("１", "1", output$発表日)
output$発表日 <- gsub("２", "2", output$発表日)
output$発表日 <- gsub("３", "3", output$発表日)
output$発表日 <- gsub("４", "4", output$発表日)
output$発表日 <- gsub("５", "5", output$発表日)
output$発表日 <- gsub("６", "6", output$発表日)
output$発表日 <- gsub("７", "7", output$発表日)
output$発表日 <- gsub("８", "8", output$発表日)
output$発表日 <- gsub("９", "9", output$発表日)

write.csv(output, file = "data/nagoya.csv", row.names = F)
