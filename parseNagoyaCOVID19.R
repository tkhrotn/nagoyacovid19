parseNagoyaCOVID19 <- function(filename) {
  text <- system(paste0("pdftotext -f 2 -raw \"", filename, "\" - | tr -d '\\f' | grep -v 例目 | grep -v 接触 | grep -v 発症日 | grep -v 性別 | grep -v 以内"), intern = T)

  retval <- matrix(nrow = length(text), ncol = 8)
  
  i <- 1
  repeat {
    l <- strsplit(text[i], " ", fixed = T)[[1]]
    
    if (length(l) != 8) {
      if (!is.na(as.numeric(l[1]))) {
        if (length(l) == 1) {
          retval[i,1] <- c(l)
          retval[i,2] <- "10歳未満"
          l <- strsplit(text[i + 3], " ", fixed = T)[[1]]
          retval[i,c(3,4,5,6,7,8)] <- l[1:6]
          i <- i + 3
        } else if (length(l) == 6) {
          retval[i,c(1,2,3,4,5,7)] <- l
        } else if (length(l) == 7) {
          retval[i,c(1,2,3,4,5,7,8)] <- l
        } else if (length(l) > 8) {
          retval[i,] <- l[1:8]
        }
      }
    } else {
      retval[i, ] <- l
    }
    
    i <- i + 1
    
    if (i > length(text))
      break
  }
  
  retval <- retval[!is.na(retval[,1]),]
  
  retval
}

args <- commandArgs(trailingOnly = T)

res <- suppressWarnings(parseNagoyaCOVID19(args[1]))

for (i in 1:nrow(res)) {
  cat(res[i,], "\n")
}
