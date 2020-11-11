library(readr)
csv <- system("ls csv/*.csv", intern = T)

nagoyacovid <- NULL
for (f in csv) {
  nagoyacovid <- rbind(nagoyacovid, read_csv(f, col_types = "dddcccccccc"))
}

nagoyacovid <- nagoyacovid[order(nagoyacovid$名古屋市No),]
nagoyacovid <- nagoyacovid[nagoyacovid$名古屋市No != 1180 & nagoyacovid$名古屋市No != 621 & nagoyacovid$名古屋市No != 925 & nagoyacovid$名古屋市No != 1435,]

write.csv(nagoyacovid, "nagoyacovid.csv")
