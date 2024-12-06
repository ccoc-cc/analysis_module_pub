
check_dir_exists <- function(inpath){
    if(file.exists(inpath)){unlink(inpath,recursive=T)}
    if( ! dir.exists(inpath)){ dir.create(inpath) }
}


get_group_mean <- function(indata_df,group_df){
    indata_df_t <- as.data.frame(t(indata_df)) %>% rownames_to_column("sample")
    indata_df_merged <- merge(indata_df_t, group_df, by = "sample") %>% column_to_rownames("sample")
    
    df_final <- indata_df_merged %>%
        group_by(group) %>%
        summarise(across(everything(), mean, na.rm = TRUE)) %>% 
        column_to_rownames("group") %>% 
        t() %>% as.matrix()
    return(df_final)
}

analysis_mfuzz <- function(df_final,cluster_num,out_path,plotHeight,plotWidth,plot_ncol){
    #----构建对象----
    mfuzz_class <- new('ExpressionSet',exprs = as.matrix(df_final))
    #----预处理缺失值或者异常值----
    mfuzz_class <- filter.NA(mfuzz_class, thres = 0.25)
    mfuzz_class <- fill.NA(mfuzz_class, mode = 'mean')
    mfuzz_class <- filter.std(mfuzz_class, min.std = 0, visu = F)
    mfuzz_class <- standardise(mfuzz_class)
    #----Mfuzz 基于 fuzzy c-means 的算法进行聚类----
    result_cluster_c <- mfuzz(mfuzz_class, c = cluster_num, m = mestimate(mfuzz_class))
    result_cluster   <- result_cluster_c
    dfdf = mfuzz_class@assayData$exprs
    
    png(filename = paste0(out_path,".png"), width = plotWidth, height = plotHeight, units = "in", bg = "white", res = 300) 
    mfuzz.plot2(mfuzz_class, cl = result_cluster, mfrow = c(ceiling(cluster_num/plot_ncol), plot_ncol), time.labels = colnames(mfuzz_class),x11 =F)
    while(!is.null(dev.list()))dev.off()
    return(list(result=result_cluster,dfdf=dfdf))
}

analysis_k <- function(df_final, cluster_num){
    #----kmeans 基于 k-means 的算法进行聚类----
    #----处理缺失值----
    dfdf <- t(scale(t(df_final))) %>% as.data.frame()
    index <- logical(dim(dfdf)[1])
    for (i in 1:dim(dfdf)[1]) {
        index[i] <- (((sum(is.na(dfdf[i, ]))/dim(dfdf)[2])) > 0.25)
    }
    dfdf <- dfdf[!index, ]
    #----计算----
    result_cluster_k <- kmeans(as.matrix(dfdf),cluster_num)
    
    return(list(result=result_cluster_k,dfdf=dfdf))
}

get_result_df <- function(result_cluster,dfdf,out_prefix,plotHeight,plotWidth,plot_ncol){
    df_cluster <- data.frame(result_cluster$cluster) %>% 
        rownames_to_column("ID") %>% `colnames<-`(c("ID","cluster"))
    all_df = merge(df_cluster, rownames_to_column(as.data.frame(dfdf),var = "ID"), by="ID")
    write.table(df_cluster, paste0(out_prefix, ".txt"), sep = '\t', col.names = NA, quote = FALSE)
    
    df_plot <- gather(all_df, "group", "value", -c(ID,cluster))
    df_plot_group <- df_plot %>% group_by(cluster, group) %>% dplyr::summarise(mean=mean(value))

    p <- ggplot()+
        geom_line(data=df_plot,aes(x=group,y=value,group=ID),color="lightgray") +
        geom_point(data=df_plot_group,aes(x=group,y=mean),color="blue") +
        geom_line( data=df_plot_group,aes(x=group,y=mean,group=cluster),color="blue") +
        facet_wrap(~cluster,ncol=plot_ncol) +
        ylim(min(df_plot$value),max(df_plot$value))+
        labs(x="",y="",title="")+
        theme_bw()+
        theme(text = element_text(face="bold"),
              axis.text.x = element_text(angle=90,vjust=0.5),
              axis.text = element_text(size=10),
              strip.background = element_blank(),
              plot.title = element_text(hjust=0.5),
              strip.text = element_text(size=10))
    ggsave(paste0(out_prefix, ".png"), p, width = plotWidth, height = plotHeight, bg="white", dpi = 300)
    ggsave(paste0(out_prefix, ".pdf"), p, width = plotWidth, height = plotHeight)
    ggsave(paste0(out_prefix, ".svg"), p, width = plotWidth, height = plotHeight)

    g_html <- ggplotly(p)
    saveWidget(as_widget(g_html), file=paste0(out_prefix,".html"))

    return(g_html)
}
