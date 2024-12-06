ui <- fluidPage(
  titlePanel("Canonical Correlation Analysis"),
  sidebarLayout(
    sidebarPanel(
      fileInput("indata", "上传数据文件", accept = c(".txt",".tsv")),
      selectInput("group_mean", "是否按组求均值", choices = list("否" = "F", "是" = "T"), selected = 1),
      conditionalPanel(
        condition = "input.group_mean == 'T'",
        fileInput("group", "上传分组信息文件", accept = c(".txt",".tsv"))
      ),
      textInput("filePrefix", "输出文件前缀", value = "out"),
      selectInput("analysis_type", "分析方法", choices = list("kmeans" = "kmeans", "mfuzz(c-means)" = "mfuzz"), selected = 1),
      numericInput("cluster_num", "输入数字", value = 9, min = 2, max = 100, step = 1),
      actionButton("run", "运行分析"),
      downloadButton("downloadData", "下载结果")
    ),
    mainPanel(
      plotlyOutput("timePlot")
    )
  )
)
