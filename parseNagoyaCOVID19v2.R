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
    i <- i + 1
    
    if (text[i] == "10歳" | text[i] == "10歳未") {
      record <- c(record, "0")
      i <- i + 2
    } else {
      record <- c(record, text[i])
      i <- i + 1
    }
    
    record <- c(record, text[i:(i+5)])
    i <- i + 6

    contact <- ""
    repeat {
      if (!is.na(suppressWarnings(as.numeric(text[i]))) | i > length(text)) {
        record <- c(record, contact)
        break
      } else {
        contact <- paste0(contact, text[i])
        i <- i + 1
      }
    }
    
    retval <- rbind(retval, record)
    
    if (i > length(text))
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
  
  return(retval)
}

args <- commandArgs(trailingOnly = T)

res <- suppressWarnings(parseNagoyaCOVID19v2(args[1]))

if (is.na(args[2])) {
  write.csv(res, sub(".pdf", ".csv", args[1]), row.names = F)
} else {
  write.csv(res, args[2], row.names = F)
}
