baseuuid <- function() {
  paste(sample(c(letters[1:6], 0:9), 30, replace = TRUE), collapse = "")
}

uuid <- function(){
  paste(
    substr(baseuuid(), 1, 8),
    "-",
    substr(baseuuid(), 9, 12),
    "-",
    "4",
    substr(baseuuid(), 13, 15),
    "-",
    sample(c("8" ,"9" ,"a" ,"b"),1),
    substr(baseuuid(), 16, 18),
    "-",
    substr(baseuuid(), 19, 30),
    sep = "",
    collapse = ""
  )
}
