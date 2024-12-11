get_anno_col <- function(group_df,color_list){
  colnames(group_df)[1] <- "sample"
  anno_col <- group_df %>% column_to_rownames(var="sample")
  color_col <- list()
  for(i in colnames(anno_col)){
    uniq_g <- unique(anno_col[,i])
    uniq_g <- uniq_g[!is.na(uniq_g)]
    color_group <- color_list[1:length(uniq_g)]
    names(color_group) <- uniq_g
    color_col[[i]] <- color_group
  }
  return(list(anno_col,color_col))
}


#-----------------------------------------------------------

heatmap_p <- function(data_plot,show_rownames,show_colnames,anno_col_list,anno_row_list,colorMap,cluster,prefix="heatmap",scaletf="row"){
  
  # data_plot = df_filter_2
  # cluster = input$cluster
  # prefix=out_prefix
  # scaletf="none"
  
  anno_col  = anno_col_list[[1]]
  anno_row  = anno_row_list[[1]]
  color_col <- append(anno_row_list[[2]],anno_col_list[[2]])
  
  cluster_rows <- ifelse(cluster %in% c("row","row_and_col"), T, F)
  cluster_cols <- ifelse(cluster %in% c("col","row_and_col"), T, F)
  
  cellwidth  <- ifelse(show_rownames,10,NA)
  cellheight <- ifelse(show_rownames,10,NA)
  
  col = colorRampPalette(colorMap)(100)
  
  
  p <- pheatmap(as.matrix(data_plot),
                color = col,
                cluster_rows=cluster_rows,cluster_cols=cluster_cols,
                # trending_distance_rows = "euclidean",
                show_colnames=show_colnames,show_rownames=show_rownames,
                angle_col = "90",
                na_col = "black",
                annotation_col=anno_col,
                annotation_row=anno_row,
                annotation_colors=color_col,
                border=F,
                scale = scaletf,
                main = "heatmap",
                cellwidth = cellwidth, cellheight = cellheight,
  )
  
  max_size <- 65535
  if(show_rownames){
    height <- compound_n * 0.15 + 3
  }else{
    height <- 12
  }
  if(height>max_size){height=max_size}
  
  if(show_colnames){
    str_len_max <- max(str_length(rownames(data_plot)))
    width <- str_len_max/10 + 3 + 0.3*sample_n
  }else{
    width <- 12
  }
  if(width>max_size){width=max_size}
  
  # print(paste("高度：",height,"宽度",width,sep="  "))
  # CairoPDF(file = paste0(prefix,".pdf"),height=height,width=width,bg="transparent")
  pdf(paste0(prefix,".pdf"), height=height,width=width)
  print(p)
  while(!is.null(dev.list()))dev.off()
  # CairoPNG(file = paste0(prefix,".png"),height=height,width=width,units="in", bg="white",dpi=300)
  png(paste0(prefix,".png"), height=height, width=width, units="in", res=300)
  print(p)
  while(!is.null(dev.list()))dev.off()
  # loginfo("%s.png",prefix,logger=paste(script_name,"outfile",sep=":"))
  # loginfo("%s.pdf",prefix,logger=paste(script_name,"outfile",sep=":"))
  
  plot_out <- data_plot
  if(scaletf=="row"){ plot_out <- t(scale(t(plot_out))) }
  if(cluster_rows){row_ids = p$tree_row$labels[p$tree_row$order]}else{row_ids = rownames(plot_out)}
  if(cluster_cols){col_ids = p$tree_col$labels[p$tree_col$order]}else{col_ids = colnames(plot_out)}
  plot_out = plot_out[row_ids,col_ids]
  plot_out <- plot_out %>% as.data.frame() %>% rownames_to_column(var="ID")
  write_tsv(plot_out,file=paste0(prefix,".plot.xls"))
  # loginfo("%s.plot.xls",prefix,logger=paste(script_name,"outfile",sep=":"))
  
  return(p)
}

