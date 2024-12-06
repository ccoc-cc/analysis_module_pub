

# server <- function(input, output) {}

server <- function(input, output, session) {
  
  observeEvent(input$run, {
    if (is.null(input$otu)) {
      showModal(modalDialog( title = "错误", "请上传otu文件。", easyClose = TRUE, footer = NULL ))
      return()
    }
    if (is.null(input$env)) {
      showModal(modalDialog( title = "错误", "请上传env文件。", easyClose = TRUE, footer = NULL ))
      return()
    }    
    
    
    check_dir_exists <- function(inpath){
      if(file.exists(inpath)){unlink(inpath,recursive=T)}
      if( ! dir.exists(inpath)){ dir.create(inpath) }
    }
    
    # input = list(
    #   otu = list(datapath = "1.input/otu.txt"),
    #   env = list(datapath = "1.input/env.txt"),
    #   group = list(datapath = "1.input/env_group.txt"),
    #   prefix = "out",
    #   data_clean = "fill",
    #   cor_type = "pearson",
    #   r_cut1 = 0.1,
    #   r_cut2 = 0.3,
    #   p_cut1 = 0.001,
    #   p_cut2 = 0.01,
    #   p_cut3 = 0.05,
    #   height = 6,
    #   width = 6
    # )
    #-------main--------
    
    out_dir = "2.output"
    out_prefix = paste0(out_dir,"/",input$prefix)
    
    check_dir_exists(out_dir)
    
    
    
    
    otu = read_tsv(input$otu$datapath, show_col_types = F) %>% column_to_rownames("ID")
    env = read_tsv(input$env$datapath, show_col_types = F) %>% column_to_rownames("Sample")
    
    sample_list = intersect(colnames(otu), rownames(env))
    
    otu = otu[,sample_list]
    # loginfo("原otu表格行数和列数: %s", dim(otu), logger=script_name)
    otu = otu[rowSums(otu != 0) > 0, ]
    # loginfo("删除全都是空值行后的行数和列数: %s", dim(otu), logger=script_name)
    
    
    if(input$data_clean == "remove"){
      non_zero_proportion <- apply(otu, 1, function(row) {   sum(row != 0) / length(row) })
      otu <- otu[non_zero_proportion > 0.5, ]
      # loginfo("仅保留在一半以上样本有表达的OTU后的行数和列数: %s", dim(otu), logger=script_name)
    }else if(input$data_clean == "fill"){
      # loginfo("空值填充为0.1", logger=script_name)
      otu[otu==0] <- 0.1
    }
    
    otu = otu %>% t() %>% as.matrix()
    
    env = env[sample_list,]
    
    if(!is.null(input$group)){
      group = read_tsv(input$group$datapath, show_col_types = F)
      if (!("OTU" %in% colnames(group)) || !("group" %in% colnames(group))) {
        colnames(group)[1:2] <- c("OTU", "group")
      }
      print(head(group))
      OTU_intas = intersect(group$OTU, colnames(otu))
      group = group[!is.na(group$group),]
      group = group[group$OTU %in% OTU_intas,]
      
      # print(otu[1:5,1:5])
      
      otu = otu[,OTU_intas]
      
      df_index = data.frame(index=1:ncol(otu), ID=colnames(otu))
      otu_group = list()
      for(i in unique(group$group)){
        temp_df = group %>% filter(group  ==i)
        otu_group[[i]] = df_index[df_index$ID %in% as.character(temp_df$OTU),"index"]
        # if(nrow(temp_df) > 5){
        #   otu_group[[i]] = df_index[df_index$ID %in% as.character(temp_df$OTU),"index"]
        # }else{
        #   loginfo("OTU太少，做不了。'%s' 分类只有 %s 个: %s", i, nrow(temp_df), temp_df$OTU, logger=script_name)
        # }
      }
    }else{
      otu_group = NULL
    }
    
    mantel = mantel_test(otu, env, spec.select=otu_group)
    
    r_cut_label <- c( paste0("<", input$r_cut1), paste0(input$r_cut1, "-", input$r_cut2), paste0(">", input$r_cut2))
    p_cut_label <- c( paste0("<=",input$p_cut1), paste0(input$p_cut1, "-", input$p_cut2),  
                      paste0(input$p_cut2, "-", input$p_cut3),  paste0(">=", input$p_cut3))
    mantel = mantel %>%
      mutate(rd = cut(abs(r),  breaks = c(-Inf, input$r_cut1, input$r_cut2, Inf),               labels = r_cut_label),
             pd = cut(p.value, breaks = c(-Inf, input$p_cut1, input$p_cut2, input$p_cut3, Inf), labels = p_cut_label))
    write_tsv(mantel,paste0(out_prefix,".txt"))
    # print(dim(mantel))
    # mantel <- mantel %>% filter(p.value < 0.05)
    # print(dim(mantel))
    
    
    # 画图
    g <- qcorrplot(cor(env, method = input$cor_type), type = "lower", diag = FALSE) + #设置左下角热图，不显示对角线
      geom_square() +
      geom_couple(aes(colour = pd, size = rd), data = mantel, curvature = nice_curvature(), alpha = 0.9) + #连接线弧度设置
      scale_fill_gradientn(colours = colorRampPalette(rev(c("#C095CA","#EDEBED","#ABCFAC")))(100), #设置颜色
                           limits = c(-1, 1), # 设置范围
                           breaks = seq(-1, 1, by = 0.2)) + # 设置刻度间隔及范围
      scale_size_manual(values = c(0.5,1.5,3)) + # 自定义线的粗细
      scale_colour_manual(values = c("#00a087","#f39b7f","#8491b4","#b09c85")) + #自定义线条颜色
      guides( colour = guide_legend(title = "Mantel's p",    order = 1,  override.aes = list(size = 3)),
              size   = guide_legend(title = "Mantel's r",    order = 2,  override.aes = list(colour = "grey35")), 
              fill   = guide_colorbar(title = "Pearson's r", order = 3)) +
      coord_equal()
    
    # esquisse::ggplot_to_ppt(gg = "g")
    
    ggsave(paste0(out_prefix, ".pdf"),g, width = input$width, height = input$height, dpi = 300)
    ggsave(paste0(out_prefix, ".png"),g, width = input$width, height = input$height)
    # loginfo("%s.pdf", out_prefix, logger=paste(script_name, "outfile", sep=":"))
    # loginfo("%s.png", out_prefix, logger=paste(script_name, "outfile", sep=":"))
    
    
    output$outPlot <- renderPlot({
      g
    })
    
    # loginfo("End", logger=script_name)
    
    
    
    
    showModal(modalDialog( title = "成功", "分析已完成！", easyClose = TRUE, footer = NULL ))
    
    showNotification("运行完成")
    showNotification("请点击下载结果文件")
    
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

