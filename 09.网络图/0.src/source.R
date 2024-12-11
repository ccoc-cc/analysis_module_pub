
check_and_install <- function(pkg) {
  if (!requireNamespace("pak", quietly = TRUE)) { install.packages("pak") }
  if (!requireNamespace(pkg, quietly = TRUE)) {
    pak::pkg_install(pkg)   
  }
  suppressMessages(library(pkg, character.only = TRUE))
}

check_dir_exists <- function(inpath){
  if(file.exists(inpath)){unlink(inpath,recursive=T)}
  if( ! dir.exists(inpath)){ dir.create(inpath) }
}
