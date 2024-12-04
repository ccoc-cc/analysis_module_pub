
source("0.src/source.R")

server <- function(input, output, session) {
  observeEvent(input$run, {
    req(input$indata1)
    req(input$indata2)
    req(input$group)
    
    data_path_1 <- input$indata1$datapath
    data_path_2 <- input$indata2$datapath
    group_path  <- input$group$datapath
    parameter <- ifelse(input$para == "auto", "auto", as.numeric(str_split(input$para, ",")[[1]]))
    
    if(file.exists("2.output")){unlink("2.output")}
    if(!file.exists("2.output")){dir.create("2.output")}

    # data_path_1 = "/mnt/d/Git/r-shiny/99.analysis_module/05.CCA/1.input/data1.txt"
    # data_path_2 = "/mnt/d/Git/r-shiny/99.analysis_module/05.CCA/1.input/data2.txt"
    # group_path  = "/mnt/d/Git/r-shiny/99.analysis_module/05.CCA/1.input/group.txt"
    # parameter <- "auto"
    # 
    showNotification("开始计算")
    res <- perform_cca_analysis(data_path_1, data_path_2, group_path, parameter)
    
    showNotification("开始画图")
    g <- plot_cca(res)
    output$ccaPlot <- renderPlotly({
      ggplotly(g$g)
    })
    gg <- g$g + coord_fixed(ratio=1) # + geom_text_repel(data=plot_df_label,aes(x=Dimension1,y=Dimension2,label=ID))
    
    height = 6
    width = 6

    ggsave(paste0("2.output/cca.plot.png"),gg,height=height,width=width, units="in", dpi=300)
    ggsave(paste0("2.output/cca.plot.pdf"),gg,height=height,width=width, units="in")
    write.table(g$plot_df, file = paste0("2.output/cca.plot.txt"), col.names = NA, row.names = TRUE, sep = "\t", quote = FALSE)

    output$downloadData <- downloadHandler(
      filename = function() {
        paste0("results.zip")
      },
      content = function(file) {
        tempdir <- tempdir()
        files <- list.files("2.output", full.names = TRUE)
        zip::zip(file, files)
      }
    )
  }
)}

