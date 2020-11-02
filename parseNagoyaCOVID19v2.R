parseNagoyaCOVID19v2 <- function(filename) {
  published <- system(paste0("pdftotext -f 1 \"", filename, "\" - | head -n 2 | tail -n 1 | awk -F ' ' '{print \"2020-\"$4\"-\"$6}'"), intern = T)
  text <- system(paste0("pdftotext -f 2 \"", filename, "\" - | sed -e 's/\\f//g'"), intern = T)
  text <- text[text != ""]
  
  i <- 1
  
  # skip header
  repeat {
    if (!is.na(suppressWarnings(as.numeric(text[i])))) {
      break
    } else {
      i <- i + 1
    }
  }
  
  retval <- NULL
  
  repeat {
    record <- text[i]
    
    if (!is.na(suppressWarnings(as.numeric(text[i]))) & as.numeric(text[i]) == 3266) {
      #record <- c(record, "30", "女", "名古屋市", "なし", "―", "10月28日", "なし", "本市公表3173例目（20歳代女性・10月26日）と接触")
      record <- c(record, "調査中", "調査中", "名古屋市", "なし", "調査中", "10月28日", "調査中", "")
      i <- i + 17
    } else if (!is.na(suppressWarnings(as.numeric(text[i]))) & as.numeric(text[i]) == 3267) {
      record <- c(record, "30", "女", "名古屋市", "なし", "―", "10月28日", "なし", "本市公表3173例目（20歳代女性・10月26日）と接触")
      i <- i + 1
    } else if (!is.na(suppressWarnings(as.numeric(text[i]))) & as.numeric(text[i]) == 3268) {
      record <- c(record, "調査中", "調査中", "名古屋市", "なし", "調査中", "10月28日", "調査中", "")
      i <- i + 5
    } else if (!is.na(suppressWarnings(as.numeric(text[i]))) & as.numeric(text[i]) == 2999) {
      record <- c(record, "高齢者", "女", "名古屋市", "なし", "―", "10月10日", "死亡", "")
      i <- i + 8
    }else {
      i <- i + 1
      
      if (text[i] == "調査中 調査中") {
        record <- c(record, NA, NA)
        i <- i + 1
        record <- c(record, text[i:(i+4)])
        i <- i + 5
      } else {
        if (text[i] == "10歳" | text[i] == "10歳未") {
          record <- c(record, "0")
          i <- i + 2
        } else {
          record <- c(record, text[i])
          i <- i + 1
        }
        
        record <- c(record, text[i:(i+5)])
        i <- i + 6
      }
      
      contact <- ""
      repeat {
        if (!is.na(suppressWarnings(as.numeric(text[i]))) | i > length(text) | startsWith(text[i], "新規患者の接触歴別内訳") | startsWith(text[i], "[参考]")) {
          record <- c(record, contact)
          break
        } else {
          contact <- paste0(contact, text[i])
          i <- i + 1
        }
      }
    }
    
    retval <- rbind(retval, record)
    
    if (i > length(text) | startsWith(text[i], "接触歴") | startsWith(text[i], "新規患者の接触歴別内訳") | startsWith(text[i], "[参考]"))
      break
  }
  
  retval <- data.frame(名古屋市No = retval[,1],
                       愛知県No = rep(NA, nrow(retval)),
                       年代 = retval[,2],
                       性別 = ifelse(retval[,3] == "男", "男性", "女性"),
                       国籍 = rep(NA, nrow(retval)),
                       住居地 = retval[,4],
                       接触状況 = retval[,9],
                       症状 = retval[,8],
                       発症日 = retval[,6],
                       陽性確定日 = retval[,7],
                       発表日 = rep(published, nrow(retval)))
  
  retval$年代[retval$名古屋市No == 3265] <- 20
  retval$年代[retval$名古屋市No == 3266] <- 30
  retval$年代[retval$名古屋市No == 3268] <- 20
  retval$年代[retval$名古屋市No == 3269] <- 50
  retval$年代[retval$名古屋市No == 3270] <- 50
  retval$年代[retval$名古屋市No == 3271] <- 30
  retval$年代[retval$名古屋市No == 3272] <- 20

  retval$性別[retval$名古屋市No == 3265] <- "女性"
  retval$性別[retval$名古屋市No == 3266] <- "女性"
  retval$性別[retval$名古屋市No == 3268] <- "女性"
  retval$性別[retval$名古屋市No == 3269] <- "女性"
  retval$性別[retval$名古屋市No == 3270] <- "女性"
  retval$性別[retval$名古屋市No == 3271] <- "女性"
  retval$性別[retval$名古屋市No == 3272] <- "女性"

  retval$発症日[retval$名古屋市No == 3265] <- NA
  retval$発症日[retval$名古屋市No == 3266] <- "10月21日"
  retval$発症日[retval$名古屋市No == 3268] <- "10月26日"
  retval$発症日[retval$名古屋市No == 3269] <- "10月24日"
  retval$発症日[retval$名古屋市No == 3270] <- NA
  retval$発症日[retval$名古屋市No == 3271] <- NA
  retval$発症日[retval$名古屋市No == 3272] <- "10月26日"

  retval$症状[retval$名古屋市No == 3265] <- "なし"
  retval$症状[retval$名古屋市No == 3266] <- "軽症"
  retval$症状[retval$名古屋市No == 3268] <- "軽症"
  retval$症状[retval$名古屋市No == 3269] <- "軽症"
  retval$症状[retval$名古屋市No == 3270] <- "なし"
  retval$症状[retval$名古屋市No == 3271] <- "なし"
  retval$症状[retval$名古屋市No == 3272] <- "軽症"
  
  retval$海外渡航歴[retval$名古屋市No == 3259] <- "なし"
  
    
  retval$発症日 <- sapply(as.character(retval$発症日), function(x) {
    if (is.na(x) | x == "―") {
      return(NA)
    } else if (x == "調査中") {
      return("調査中")
    }
    
    month <- strsplit(x, "月")[[1]][1]
    day <- strsplit(strsplit(x, "月")[[1]][2], "日")[[1]][1]
    paste0("2020-", month, "-", day)
  })

  retval$陽性確定日 <- sapply(as.character(retval$陽性確定日), function(x) {
    if (is.na(x) | x == "―") {
      return(NA)
    } else if (x == "調査中") {
      return("調査中")
    }
    
    month <- strsplit(x, "月")[[1]][1]
    day <- strsplit(strsplit(x, "月")[[1]][2], "日")[[1]][1]
    paste0("2020-", month, "-", day)
  })
  
  retval$接触状況[retval$接触状況 == ""] <- NA
  
  retval$年代[retval$年代 == "" | retval$年代 == "―"] <- NA
  
  return(retval)
}

args <- commandArgs(trailingOnly = T)

res <- suppressWarnings(parseNagoyaCOVID19v2(args[1]))

if (is.na(args[2])) {
  write.csv(res, sub(".pdf", ".csv", args[1]), row.names = F)
} else {
  write.csv(res, args[2], row.names = F)
}
