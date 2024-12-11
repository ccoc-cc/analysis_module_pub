
ui <- fluidPage(
  titlePanel("Correlation Heatmap"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("indata1", "上传数据1",  accept = c(".txt",".tsv")),
      fileInput("group1", "上传分组信息1", accept = c(".txt",".tsv")),
      helpText("请保证两个数据有相同的样本列，流程只会分析共有的样本"),
      fileInput("indata2", "上传数据2",  accept = c(".txt",".tsv")),
      fileInput("group2", "上传分组信息2", accept = c(".txt",".tsv")),
      selectInput("corrType", "选择计算方法", choices = c("pearson", "spearman"), selected = "pearson"),
      
      numericInput("cor_cut",   "相关性阈值",    value = 0.8, min = 0, max = 1, step=0.01),
      numericInput("cor_p_cut", "相关性P值阈值", value = 0.05, step=0.001, min = 0,max=1),

      textInput("cologroup", "分组颜色", value = "#E64B35,#4DBBD5,#00A087,#3C5488,#F39B7F,#8491B4,#91D1C2,#DC0000,#7E6148,#B09C85,#E41A1C,#377EB8,#4DAF4A,#984EA3,#FF7F00,#FFFF33,#A65628,#F781BF,#1B9E77,#D95F02,#7570B3,#E7298A,#66A61E,#E6AB02,#A6761D,#666666"),
      textInput("colorMap", "色块颜色", value = "#000080,#F6F6F6,#CD2626"),
      selectInput("cluster", "聚类状态", choices = c("不聚类"="no","仅行聚类"="row", "仅列聚类"="col", "都聚类"="row_and_col"), selected = "row_and_col"),

      selectInput("show_colnames", "显示列名", choices = c("显示"="T", "不显示"="F", "100行内显示"="auto"), selected = "auto"),
      selectInput("show_rownames", "显示行名", choices = c("显示"="T", "不显示"="F", "100行内显示"="auto"), selected = "auto"),

      checkboxInput("html", "是否输出网页版（极其耗费时间）", value = FALSE),

      # numericInput("height", "图像高度", value = 8, min = 1),
      # numericInput("width", "图像宽度", value = 8, min = 1),
      textInput("prefix", "输出文件前缀", value = "out"),

      actionButton("run", "运行分析"),
      downloadButton("downloadData", "下载结果")
    ),
    
    mainPanel(
      plotOutput("heatmapPlot")
    )
  )
)
