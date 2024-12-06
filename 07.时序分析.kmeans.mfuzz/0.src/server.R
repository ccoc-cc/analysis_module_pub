
source("0.src/source.R")


server <- function(input, output, session) {
  
  observeEvent(input$run, {
    if (is.null(input$indata)) {
      showModal(modalDialog( title = "错误", "请上传数据文件。", easyClose = TRUE, footer = NULL ))
      return()
    }
    
    if (input$group_mean == "T" && is.null(input$group)) {
      showModal(modalDialog( title = "错误", "请上传分组信息文件。", easyClose = TRUE, footer = NULL ))
      return()
    }
    
    
    # input = list(
    #   indata = list(datapath = "1.input/gene_tpm.txt"),
    #   # group  = list(datapath="1.input/sample_group.txt"),
    #   filePrefix  = "cluster",
    #   group_mean = "F",
    #   analysis_type = "mfuzz",
    #   cluster_num = 9
    # )
    #-------main--------
    out_dir = "2.output"
    out_prefix = paste0(out_dir,"/",input$filePrefix)
    
    check_dir_exists(out_dir)
    
    rawdata <- read.delim(input$indata$datapath, row.names = 1, check.names = FALSE) # %>% head(20)
    
    if (input$group_mean == "T"){
      group_df  <- read.delim(input$group$datapath, check.names = FALSE)
      df_final <- get_group_mean(rawdata,group_df)
    }else{
      df_final <- rawdata %>% as.matrix()
    }
    
    set.seed(123)
    cluster_num <- input$cluster_num
    
    if (input$analysis_type == "mfuzz"){
      result_cluster <- analysis_mfuzz(df_final,cluster_num,paste0(out_prefix,".Mfuzz"),input$plotHeight,input$plotWidth,input$plot_ncol)
    }else if (input$analysis_type == "kmeans"){
      result_cluster <- analysis_k(df_final,cluster_num)
    }
    
    p <- get_result_df(result_cluster$result,result_cluster$dfdf,out_prefix,input$plotHeight,input$plotWidth,input$plot_ncol)
    
    #------
    output$timePlot <- renderPlotly({
      p
    })
    
    showModal(modalDialog( title = "成功", "分析已完成！", easyClose = TRUE, footer = NULL ))
    
    showNotification("运行完成")
    showNotification("请点击下载结果文件")
    
    output$downloadData <- downloadHandler(
      filename = function() {
        paste0(input$filePrefix, "_results.zip")
      },
      content = function(file) {
        tempdir <- tempdir()
        files <- list.files(out_dir, full.names = TRUE)
        zip::zip(file, files)
      }
    )
    
  })
}

