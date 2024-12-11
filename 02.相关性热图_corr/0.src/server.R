

for(i in dir("0.src/", pattern = "*source*", full.names = T)){source(i)}

# server <- function(input, output) {}

server <- function(input, output, session) {
  
  observeEvent(input$run, {
    if (is.null(input$indata1)) {
      showModal(modalDialog( title = "错误", "请上传数据文件。", easyClose = TRUE, footer = NULL ))
      return()
    }
    
    if (is.null(input$group1)) {
      showModal(modalDialog( title = "错误", "请上传分组信息文件。", easyClose = TRUE, footer = NULL ))
      return()
    }
    
    
    
    # input = list(
    #   indata1 = list(datapath = "1.input/数据1.txt"),
    #   indata2 = list(datapath = "1.input/数据2.txt"),
    #   group1  = list(datapath = "1.input/分组信息_row1.txt"),
    #   group2  = list(datapath = "1.input/分组信息_row2.txt"),
    #   prefix  = "test_output",
    #   corrType = "pearson",
    #   cor_p_cut = 0.05,
    #   cor_cut = 0.8,
    
    #   cologroup = "#E64B35,#4DBBD5,#00A087,#3C5488,#F39B7F,#8491B4,#91D1C2,#DC0000,#7E6148,#B09C85,#E41A1C,#377EB8,#4DAF4A,#984EA3,#FF7F00,#FFFF33,#A65628,#F781BF,#1B9E77,#D95F02,#7570B3,#E7298A,#66A61E,#E6AB02,#A6761D,#666666",
    #   colorMap = "#000080,#F6F6F6,#CD2626",
    #   cluster = "row_and_col",
    
    #   show_rownames = "auto",
    #   show_colnames = "auto",
    #   height = 8,
    #   width = 8
    # )
    
    print(input)
    
    out_dir = "2.output"
    out_prefix = paste0(out_dir,"/",input$prefix)
    check_dir_exists(out_dir)
    
    #-------main--------
    
    group_df_x <- read_tsv(input$group1$datapath, show_col_types = FALSE)
    colnames(group_df_x)[1] <- "ID"
    colnames(group_df_x)[2] <- paste0(colnames(group_df_x)[2], "_row")
    id_x_input <- unique(group_df_x$ID)
    df_x <- process_data(input$indata1$datapath, id_x_input)
    
    group_df_y <- read_tsv(input$group2$datapath, show_col_types = FALSE)
    colnames(group_df_y)[1] <- "ID"
    colnames(group_df_y)[2] <- paste0(colnames(group_df_y)[2], "_col")
    id_y_input <- unique(group_df_y$ID)
    df_y <- process_data(input$indata2$datapath, id_y_input)
    
    data <- cbind(df_x,df_y)
    
    #----开始计算--------------------------------------------------------------
    tic("corr 耗时")
    cor.result <- rcorr(as.matrix(data), type = input$corrtype)
    toc()
    
    corr_df   <- cor.result$r %>% as.data.frame()
    corr_p_df <- cor.result$P %>% as.data.frame()
    
    write.table(rownames_to_column(corr_df,   "ID"), file = paste0(out_prefix, ".all.value.txt"),  row.names = FALSE, sep = "\t", quote = FALSE)
    write.table(rownames_to_column(corr_p_df, "ID"), file = paste0(out_prefix, ".all.pvalue.txt"), row.names = FALSE, sep = "\t", quote = FALSE)
    
    #----筛选--------------------------------------------------------------
    #----过滤--------------------------------------------------------------
    gather_corr_p <- corr_p_df %>% rownames_to_column(var = "ID_y") %>% gather(ID_x, corr_pvalue, -ID_y)
    gather_corr   <- corr_df   %>% rownames_to_column(var = "ID_y") %>% gather(ID_x, corr_value,  -ID_y)
    
    df_all <- merge(gather_corr, gather_corr_p, by = c("ID_x","ID_y"))
    write.table(df_all, file = paste0(out_prefix, ".all.gather.txt"), row.names = FALSE, sep = "\t", quote = FALSE)

    df_filter <- df_all %>% 
      filter(abs(corr_value) >= input$cor_cut)  %>%
      filter(corr_pvalue     <= input$cor_p_cut)
    write.table(df_filter, file = paste0(out_prefix, ".filter.gather.txt"), row.names = FALSE, sep = "\t", quote = FALSE)
    
    id_filter_list <- unique(c(df_filter$ID_x,df_filter$ID_y))
    df_filter_2 <- corr_df[id_filter_list %in% colnames(df_x),id_filter_list %in% colnames(df_y)]
    
    
    
    
    #---------------
    sample_n <- ncol(df_filter_2)
    compound_n <- nrow(df_filter_2)
    if (input$show_rownames == "auto") {
      if(compound_n > 100){
        show_rownames = F
        # logwarn("数据太多 %s * %s = %s ，不展示行名了",compound_n,sample_n,compound_n *sample_n,logger=script_name)
      }else{
        show_rownames = T
      }
    }else{
      show_rownames = as.logical(input$show_rownames)
    }
    if (input$show_colnames == "auto") {
      if(sample_n > 100){
        show_colnames = F
        # logwarn("数据太多 %s * %s = %s ，不展示列名了",compound_n,sample_n,compound_n *sample_n,logger=script_name)
      }else{
        show_colnames = T
      }
    }else{
      show_colnames = as.logical(input$show_colnames)
    }
    
    
    group_col_len = group_df_y[,2] %>% as.matrix() %>% as.character() %>% unique() %>% length()
    group_row_len = group_df_x[,2] %>% as.matrix() %>% as.character() %>% unique() %>% length()
    cologroup = strsplit(input$cologroup, ",")[[1]]
    
    anno_row_list <- get_anno_col(group_df_x,cologroup[1:group_col_len])
    anno_col_list <- get_anno_col(group_df_y,cologroup[(group_col_len+1):(group_row_len+group_col_len)])
    colorMap = strsplit(input$colorMap, ",")[[1]]
    
    p <- heatmap_p(df_filter_2,show_rownames,show_colnames,anno_col_list,anno_row_list,colorMap,input$cluster,prefix=out_prefix,scaletf="none")
    
    output$heatmapPlot <- renderPlot({
      p
    })
    
    
    if(input$html){
      heatmaply_html = heatmaply(df_filter_2,
                                 color = colorRampPalette(colorMap)(100),
                                 col_side_colors  = as.data.frame(anno_col_list[[1]]), 
                                 row_side_colors  = as.data.frame(anno_row_list[[1]]),
                                 col_side_palette = anno_col_list[[2]][[1]],  
                                 row_side_palette = anno_row_list[[2]][[1]],
                                 file = paste0(out_prefix,".html"),
                                 dendrogram = "both",
                                 # dist_method = "euclidean",
                                 grid_gap = 0.1,
                                 column_text_angle = 90,
                                 # k_row = ifelse(nrow(df_filter_2)>=9,9,nrow(df_filter_2)),
                                 xlab = "",
                                 ylab = "",
                                 scale  = "none",
      )
    }
    
    #-------弹窗消息--------
    showModal(modalDialog( title = "成功", "分析已完成！", easyClose = TRUE, footer = NULL ))
    
    showNotification("运行完成")
    showNotification("请点击下载结果文件")
    
    
    #----下载----
    output$downloadData <- downloadHandler(
      filename = function() {
        paste0(input$prefix, "_results.zip")
      },
      content = function(file) {
        tempdir <- tempdir()
        files <- list.files(out_dir, full.names = TRUE)
        zip::zip(file, files)
      }
    )
    
  })
}

