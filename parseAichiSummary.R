parseAichiCOVID19 <- function(filename) {
  text <- system(paste0("pdftotext -fixed 2 \"", filename, "\" - | sed -e 's/\\f//g'"), intern = T)
  text <- text[-c(1,2,3)]
  retval <- data.frame(
    愛知県ID = gsub(" ", "", substr(text, 1, 50)),
    発表日 = gsub(" ", "", substr(text, 50, 80)),
    年代性別 = gsub(" ", "", substr(text, 80, 100)),
    国籍 = gsub(" ", "", substr(text, 100, 150)),
    住居地 = gsub(" ", "", substr(text, 150, 180)),
    接触状況 = gsub(" ", "", substr(text, 180, 240)),
    備考 = gsub(" ", "", substr(text, 240, 300))
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
