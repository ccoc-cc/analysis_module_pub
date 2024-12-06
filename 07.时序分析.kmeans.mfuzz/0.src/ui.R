ui <- fluidPage(
  titlePanel("时序分析（mfuzz or k-means）"),
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
      numericInput("cluster_num", "聚成几类", value = 9, min = 2, max = 100, step = 1),
      helpText("如果聚类数/图片列数不是整数，网页版显示会有问题，其他没问题"),
      numericInput("plot_ncol", "图片分几列", value = 3, step = 1, min=1),
      numericInput("plotHeight", "图片高度 (单位: in)", value = 6, step = 0.1),
      numericInput("plotWidth", "图片宽度 (单位: in)", value = 6, step = 0.1),
      actionButton("run", "运行分析"),
      downloadButton("downloadData", "下载结果")
    ),
    mainPanel(
      plotlyOutput("timePlot")
    )
  )
)
