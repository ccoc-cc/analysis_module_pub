
source("0.src/pca.R")

server <- function(input, output, session) {
  observeEvent(input$run, {
    
    req(input$dataFile)
    req(input$groupFile)
    

    # input <- list(
    #   dataFile  = list(datapath = "/mnt/d/Git/r-shiny/99.analysis_module/01.主成分分析_PCA/1.input/data_assess_pre.txt"),
    #   groupFile = list(datapath = "/mnt/d/Git/r-shiny/99.analysis_module/01.主成分分析_PCA/1.input/all_group.txt"),
    #   plotHeight = 6, plotWidth = 6,
    #   filePrefix = "out"
    # )
    
    outdir <- "2.output"
    
    data_path <- input$dataFile$datapath
    group_path <- input$groupFile$datapath
    prefix <- input$filePrefix
    height <- input$plotHeight
    width <- input$plotWidth
    colorUser <- input$colorUser
    
    if(file.exists(outdir)){unlink(outdir)}
    if(!file.exists(outdir)){dir.create(outdir)}


    showNotification("开始计算")
    
    input_df <- get_data(data_path,group_path)
    pca_calculate <- get_pca(input_df$data,input_df$group)
    
    write.table(pca_calculate$pca$x,          file = paste0(outdir,"/", prefix, ".pcx.txt"),        col.names = NA, row.names = TRUE, sep = "\t", quote = FALSE)
    write.table(pca_calculate$pca$importance, file = paste0(outdir,"/", prefix, ".proportion.txt"), col.names = NA, row.names = TRUE, sep = "\t", quote = FALSE)
    
    showNotification("开始画2D图")
    
    
    colors  <- get_color(input_df$group$group,colorUser)
    colors_3d <- colors[pca_calculate$pca_df$group]
    
    
    
    g_html <- ggplotly(plot_pca2d(pca_calculate,"sample",colors))
    output$pca2DPlot <- renderPlotly({
      g_html # <- ggplotly(plot_pca2d(pca_calculate$pca_df,"sample",colors)) # ggplotly(pca2d_g)
    })
    save_pca2d(pca_calculate, colors, paste0(outdir,"/",prefix), height, width, input$label )
    saveWidget(as_widget(g_html), file=paste0(outdir,"/",prefix,".html"))
    
    showNotification("开始画3D图")
    
    # 3D PCA Plot
    p3d <- plot_ly(pca_calculate$pca_df, x = ~PC1, y = ~PC2, z = ~PC3, color = ~group, colors = colors_3d, text = ~paste("Sample: ", sample, sep = "")) %>%
      add_markers() %>%
      layout(title = "3D PCA Plot")
    output$pca3DPlot <- renderPlotly({
      p3d
    })
    htmlwidgets::saveWidget(plotly::as_widget(p3d), file=paste0(outdir,"/",prefix,".3d.html"))
    
    
    plot_3d(pca_calculate,colors_3d,prefix,height,width,outdir)
    
    showNotification("开始画var图")
    
    gVar <- plot_var(pca_calculate$pca_summary)
    
    output$variancePlot <- renderPlot({
      gVar
    })
    
    ggsave(paste0(outdir,"/",prefix,".var.png"),gVar,height=height,width=width, units="in", dpi=300)
    ggsave(paste0(outdir,"/", prefix,".var.pdf"),gVar,height=height,width=width)
    
    
    showNotification("运行完成")
    showNotification("请点击下载结果文件")
    
    output$downloadData <- downloadHandler(
      filename = function() {
        paste0(prefix, "_results.zip")
      },
      content = function(file) {
        tempdir <- tempdir()
        files <- list.files(outdir, full.names = TRUE)
        zip::zip(file, files)
      }
    )
  })
}


