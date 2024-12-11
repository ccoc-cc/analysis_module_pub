
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

data_tidy <- function(data){
  data[is.na(data)] <- 0
  if ( nrow(data[which(apply(data,1,function(x) max(x)==min(x))),]) > 0 ){
    data <- data[-which(apply(data,1,function(x) max(x)==min(x))),]
  }
  return(data)
}

process_data <- function(raw_data_path, id_list) {
  # raw_data_path = input$indata1$datapath
  # id_list = id_x_input
  # 
  raw_data <- read_tsv(raw_data_path, show_col_types = FALSE)
  colnames(raw_data)[1] <- "ID"
  raw_data <- raw_data %>% column_to_rownames(var = "ID")
  
  id_list <- intersect(id_list, rownames(raw_data))
  raw_data <- data_tidy(raw_data[id_list, ]) 
  
  filtered_data <- t(raw_data) %>% as.data.frame()
  return(filtered_data)
}







