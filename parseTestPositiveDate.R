parseTestPositiveDate <- function(filename) {
  text <- system(paste0("pdftotext \"", filename, "\" -"), intern = T)
  
  headers <- grep("行動・症状等", text)
  
  retval <- character(0)
  
  i <- 1
  repeat {
    if (length(grep("行動・症状等", text[i]))) {
      candidate <- NA
      repeat{
        i <- i + 1
        
        if (length(grep("月", text[i])) > 0 & length(grep("患者|発症", text[i])) == 0) {
          candidate <- text[i]
        }
        
        if (length(grep("概要|人権|動物", text[i])) > 0) {
          retval <- c(retval, candidate)
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

cat(gsub(" ", "", parseTestPositiveDate(args[1])), sep = "\n")
