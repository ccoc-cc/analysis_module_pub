
#----检查、安装、加载R包----
#----第一次运行会很慢，因为要下载安装----

source("0.src/source.R")

packages <- c("shiny", "zip", "tidyverse", "tidygraph", "ggraph", "RColorBrewer", "igraph")

for (pkg_info in packages) { check_and_install(pkg_info) }


#----运行----

source("0.src/ui.R")
source("0.src/server.R")

shinyApp(ui,server)

