parseAichiCOVID19 <- function(filename) {
  text <- system(paste0("pdftotext -fixed 2 \"", filename, "\" - | sed -e 's/\\f//g'"), intern = T)
  text <- text[-c(1,2,3)]
  retval <- data.frame(
    愛知県ID = gsub(" ", "", substr(text, 20, 40)),
    発表日 = gsub(" ", "", substr(text, 40, 70)),
    年代性別 = gsub(" ", "", substr(text, 70, 90)),
    国籍 = gsub(" ", "", substr(text, 90, 120)),
    住居地 = gsub(" ", "", substr(text, 120, 150)),
    接触状況 = gsub(" ", "", substr(text, 150, 220)),
    備考 = gsub(" ", "", substr(text, 220, 250))
  )
  
  return(retval)
}

args <- commandArgs(trailingOnly = T)

res <- suppressWarnings(parseAichiCOVID19(args[1]))

if (is.na(args[2])) {
  write.csv(res, sub(".pdf", ".csv", args[1]), row.names = F)
} else {
  write.csv(res, args[2], row.names = F)
}
