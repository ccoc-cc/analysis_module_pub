ui <- fluidPage(
  titlePanel("网络图"),
  sidebarLayout(
    sidebarPanel(
      helpText("为了美观，建议数据少一点；更多的用cytoscape画"),
      fileInput("edge_path", "上传edge文件",  accept = c(".txt",".tsv")),
      fileInput("node_path", "上传node文件",  accept = c(".txt",".tsv")),
      
      selectInput("layout", "布局类型", choices = c("circ","dh","fr","gem","graphopt","grid","kk","nicely","sphere"), selected = "circ", multiple=T),
      
      helpText("如果颜色列是数字，建议颜色数量少一点，脚本会取渐变；如果是字符，颜色个数建议>=这一列去重后的个数"),
      textInput("color_node", "节点颜色", value = "#E64B35,#4DBBD5,#00A087,#3C5488,#F39B7F,#8491B4,#91D1C2,#DC0000,#7E6148,#B09C85,#E41A1C,#377EB8,#4DAF4A,#984EA3,#FF7F00,#FFFF33,#A65628,#F781BF,#1B9E77,#D95F02,#7570B3,#E7298A,#66A61E,#E6AB02,#A6761D,#666666"),
      textInput("color_edge", "线条颜色", value = "#000080,#F6F6F6,#CD2626"),
      
      checkboxInput("arrow", "是否需要箭头，edge第一列为起点，第二列为终点", value = FALSE),
      checkboxInput("label", "是否展示ID", value = TRUE),

      sliderInput("node_size_size", "节点大小范围", value = c(2, 5), step=0.1, min=0, max=20),

      uiOutput("edge_select"),
      uiOutput("node_select"),
      
      numericInput("height", "图像高度", value = 12, min = 1),
      numericInput("width", "图像宽度", value = 12, min = 1),
      
      textInput("prefix", "输出文件前缀", value = "out"),
      actionButton("run", "运行分析"),
      downloadButton("downloadData", "下载结果")
    ),
    mainPanel(
      plotOutput("ggraph_plot")
    )
  )
)

