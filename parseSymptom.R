parseSymptom <- function(filename) {
  text <- system(paste0("pdftotext -raw \"", filename, "\" - | tr -d \"\f\""), intern = T)
  
  headers <- grep("行動・症状等", text)
  
  retval <- character(0)
  
  i <- 1
  repeat {
    if (length(grep("症状", text[i]))) {
      s <- ""
      s2 <- strsplit(text[i], " ")
      if (length(s2[[1]]) > 1) {
        s <- paste0(s, s2[[1]][2])
      }
      repeat{
        i <- i + 1
        
        if (length(grep("性別", text[i])) > 0) {
          if (s == "")
            s <- "NA"
          
          retval <- c(retval, s)
          break
        }
        
        s <- paste0(s, text[i])
        
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

cat(gsub(" ", "", parseSymptom(args[1])), sep = "\n")
