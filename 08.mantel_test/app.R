
#----检查、安装、加载R包----
#----第一次运行会很慢，因为要下载安装----

check_and_install <- function(pkg) {
  if (!requireNamespace("pak", quietly = TRUE)) { install.packages("pak") }
  pkg_name = rev(strsplit(pkg,"/")[[1]])[1]
  if (!requireNamespace(pkg_name, quietly = TRUE)) {
    pak::pkg_install(pkg)   
  }
  suppressMessages(library(pkg_name, character.only = TRUE))
}

packages <- c("shiny", "zip", "tidyverse", "Hy4m/linkET", "hannet91/ggcor", "plotly")

for (pkg_info in packages) { check_and_install(pkg_info) }



#----运行----

source("0.src/ui.R")
source("0.src/server.R")

shinyApp(ui,server)


