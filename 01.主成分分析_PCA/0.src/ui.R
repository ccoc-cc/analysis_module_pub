ui <- fluidPage(
    titlePanel("PCA Analysis"),
    sidebarLayout(
        sidebarPanel(
            fileInput("dataFile", "选择数据文件", accept = c(".txt", ".tsv")),
            fileInput("groupFile", "选择分组文件", accept = c(".txt", ".tsv")),
            numericInput("plotHeight", "图片高度 (单位: in)", value = 6, min = 1),
            numericInput("plotWidth", "图片宽度 (单位: in)", value = 6, min = 1),
            textInput("filePrefix", "输出文件前缀", value = "out"),
            textInput("colorUser", "分组颜色", value = "default", placeholder = "#E64B35,#4DBBD5,#00A087,#3C5488"),
            actionButton("run", "运行分析"),
            downloadButton("downloadData", "下载结果")
        ),
        mainPanel(
            tabsetPanel(
                tabPanel("2D PCA", plotlyOutput("pca2DPlot")),
                tabPanel("3D PCA", plotlyOutput("pca3DPlot")),
                tabPanel("Variance", plotOutput("variancePlot"))
            )
        )
    )
)
