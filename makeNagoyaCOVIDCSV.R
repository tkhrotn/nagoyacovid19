library(readr)
csv <- system("ls csv/*.csv", intern = T)

nagoyacovid <- NULL
for (f in csv) {
  nagoyacovid <- rbind(nagoyacovid, read_csv(f, col_types = "dddcccccccc"))
}

nagoyacovid <- nagoyacovid[order(nagoyacovid$名古屋市No),]

write.csv(nagoyacovid, "nagoyacovid.csv")
