parseOnsetDate <- function(filename, pattern) {
  text <- system(paste0("pdftotext \"", filename, "\" -"), intern = T)
  
  headers <- grep("行動・症状等", text)
  
  retval <- character(0)
  
  i <- 1
  repeat {
    if (length(grep("行動・症状等", text[i]))) {
      candidate <- NA
      repeat{
        i <- i + 1
        
        if (length(grep("月", text[i])) > 0) {
          candidate <- text[i]
        }
        
        if (length(grep(pattern, text[i]))) {
          retval <- c(retval, candidate)
          break
        }
        
        if (length(grep("判定", text[i])) > 0) {
          retval <- c(retval, NA)
          break
        }
        
        if (i >= length(text)) {
          return(retval)
        }
      }
    }
    
    i <- i + 1
    
    if (i >= length(text)) {
      return(retval)
    }
  }
}


args <- commandArgs(trailingOnly = T)

cat(gsub(" ", "", parseOnsetDate(args[1], args[2])), sep = "\n")
