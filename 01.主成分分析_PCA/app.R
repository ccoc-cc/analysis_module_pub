
#----检查、安装、加载R包----
#----第一次运行会很慢，因为要下载安装----

check_and_install <- function(pkg_info) {
  info = strsplit(pkg_info,":")[[1]]
  pkg  = info[1]
  type = ifelse(length(info)>1,info[2],"cran")
  if (!requireNamespace(pkg, quietly = TRUE, ask="no")) {
    if(type == "cran"){
    }else if(type == "bio"){
      if (!requireNamespace("BiocManager", quietly = TRUE)) {
        install.packages("BiocManager")
      }
      BiocManager::install(pkg,ask=FALSE)
    }
  }
  library(pkg, character.only = TRUE)
}

packages <- c("shiny", "tidyverse", "dplyr", "ggrepel", "scatterplot3d", "plotly", "htmlwidgets", "RColorBrewer", "logging")

for (pkg in packages) { check_and_install(pkg) }



#----运行----

source("0.src/ui.R")
source("0.src/server.R")

shinyApp(ui,server)


