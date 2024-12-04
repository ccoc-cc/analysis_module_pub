ui <- fluidPage(
  titlePanel("Canonical Correlation Analysis"),
  sidebarLayout(
    sidebarPanel(
      fileInput("indata1", "上传数据文件",  accept = c(".txt",".tsv")),
      fileInput("indata2", "上传数据文件",  accept = c(".txt",".tsv")),
      fileInput("group", "上传分组信息文件", accept = c(".txt",".tsv")),
      helpText("正则化参数,默认根据预设规则自动判断。也可以手动输入逗号分割的两个>0的实数。如 '1,1'。该参数最好取不报错的最小值。越大越容易出结果，但原矩阵原信息保留越少"),
      textInput("para", "正则化参数", value = "auto"),
      actionButton("run", "运行分析"),
      downloadButton("downloadData", "下载结果")
    ),
    mainPanel(
      plotlyOutput("ccaPlot")
    )
  )
)