ui <- fluidPage(
  titlePanel("mantel test"),
  sidebarLayout(
    sidebarPanel(
      helpText("第一行第一列必须是“ID”，第一列是OTU编号，后面是样本列"),
      fileInput("otu", "上传otu数据", accept = c(".txt", ".tsv")),
      helpText("第一行第一列必须是“Sample”，第一列是样本，后面是环境因子；注意：程序只会分析两个数据共有的样本"),
      fileInput("env", "上传env数据", accept = c(".txt", ".tsv")),
      helpText("第一列是OTU,要和数据对应，第二列是分类"),
      fileInput("group", "上传分组信息文件", accept = c(".txt", ".tsv")),
      selectInput("data_clean", "数据处理", choices = list("空值填充为0.1" = "fill", "剔除表达比例不足50%的OTU)" = "remove"), selected = 1),
      selectInput("cor_type", "相关性计算方法", choices = list("pearson" = "pearson", "kendall" = "kendall", "spearman" = "spearman"), selected = 1),
      textInput("prefix", "输出文件前缀", value = "out"),
      fluidRow(
        column(6, numericInput("r_cut1", "r_cut1", value = 0.1, step = 0.01)),
        column(6, numericInput("r_cut2", "r_cut2", value = 0.3, step = 0.01))
      ),
      fluidRow(
        column(6, numericInput("p_cut1", "p_cut1", value = 0.001, step = 0.001)),
        column(6, numericInput("p_cut2", "p_cut2", value = 0.01, step = 0.001)),
        column(6, numericInput("p_cut3", "p_cut3", value = 0.05, step = 0.001))
      ),
      fluidRow(
        column(6, numericInput("height", "图片高度", value = 6, step = 0.1)),
        column(6, numericInput("width", "图片宽度", value = 6, step = 0.1))
      ),
      actionButton("run", "运行分析"),
      downloadButton("downloadData", "下载结果")
    ),
    mainPanel(
      plotOutput("outPlot")
    )
  )
)
