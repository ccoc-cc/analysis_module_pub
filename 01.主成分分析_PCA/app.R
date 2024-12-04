
#----检查、安装、加载R包----
#----第一次运行会很慢，因为要下载安装----

check_and_install <- function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        install.packages(pkg, repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
    }
    library(pkg, character.only = TRUE)
}

packages <- c("shiny", "tidyverse", "dplyr", "ggrepel", "scatterplot3d", "plotly", "htmlwidgets", "RColorBrewer", "logging")

for (pkg in packages) { check_and_install(pkg) }



#----运行----

source("0.src/ui.R")
source("0.src/server.R")

shinyApp(ui,server)


