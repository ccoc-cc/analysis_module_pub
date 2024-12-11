

get_data <- function(data_path, group_path) {
  data <- read_tsv(data_path, col_names = TRUE, col_types = cols(), locale = locale(encoding = "UTF-8"), na = c("NA", "N/A", "nan"))
  colnames(data)[1] <- "ID"
  data <- data %>% column_to_rownames(var = "ID")
  group <- read_tsv(group_path, col_names = TRUE, col_types = cols(), locale = locale(encoding = "UTF-8"), na = c("NA", "N/A", "nan"))[, 1:2] %>% `colnames<-`(c("sample", "group"))
  data <- select(data, group$sample) # 筛选列
  data <- na.omit(data)
  data[is.na(data)] <- 0
  if (nrow(data[which(apply(data, 1, function(x) max(x) == min(x))), ]) > 0) {
    data <- data[-which(apply(data, 1, function(x) max(x) == min(x))), ]
  }
  return(list(data = data, group = group))
}

get_pca <- function(data, group) {
  pca <- prcomp(t(as.matrix(data)), scale = TRUE) # 主成分计算
  pca_summary <- summary(pca) # 获取描述性统计量
  #----------------------------------------------------------
  pc1 <- pca_summary$importance[2, 1] * 100
  pc2 <- pca_summary$importance[2, 2] * 100
  pc3 <- pca_summary$importance[2, 3] * 100
  pca_df <- data.frame(sample = rownames(pca$x), pca$x)
  pca_df <- inner_join(pca_df, group, by = "sample")
  return(list(pca = pca, pca_df = pca_df, pca_summary = pca_summary, pc1 = pc1, pc2 = pc2, pc3 = pc3))
}

get_color <- function(group,color_user){
  pal_png = c("#E64B35","#4DBBD5","#00A087","#3C5488","#F39B7F","#8491B4","#91D1C2","#EE4C97","#FFDC91","#0072B5","#7E6148","#B09C85")
  brewer_s1d2 = c("#E41A1C","#377EB8","#4DAF4A","#984EA3","#FF7F00","#FFFF33","#A65628","#F781BF","#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02","#A6761D","#666666")
  color_zwk <- c("#E41A1C","#377EB8","#4DAF4A","#984EA3","#FF7F00","#FFFF33","#A65628","#F781BF","#1B9E77","#D95F02","#7570B3","#E7298A","#66A61E","#E6AB02","#A6761D","#666666","#FF0000","#FF6347","#DC143C","#FFA500","#FF8C00","#EE7600","#FFFF00","#FFD700","#F0E68C","#008000","#00FF7F","#3CB371","#0000FF","#00BFFF","#4169E1","#800080","#9932CC","#DA70D6","#FFC0CB","#FF69B4","#FF1493","#A52A2A","#8B4513","#6B4423","#808080","#A9A9A9","#D3D3D3","#000000","#C0C0C0","#FF4500","#4682B4","#7FFFD4","#FFDAB9","#66CDAA","#FFE4E1","#40E0D0","#9370DB","#FFA07A","#20B2AA","#87CEEB","#FF6103","#708090","#5F9EA0","#FFEBCD","#98FB98","#FF7F50","#8A2BE2","#FFE4C4","#00CED1","#FF82AB","#ADFF2F","#FFB6C1","#48D1CC","#FFAFAF","#B0E0E6","#FFD39B","#9400D3","#FFEFD5","#6495ED","#FFE4B5","#7B68EE","#FFC1CC","#32CD32","#FFDEAD","#696969")
  # colors <- RColorBrewer::brewer.pal(n = length(unique(group$group)), name = "Set1")
  if (color_user!="default"){
    colors <- str_split(color_user,"\\,")[[1]]
  }else{
    colors <- unique(c(pal_png,brewer_s1d2,color_zwk))
  }
  colors_final <- colors[1:length(unique(group))]
  names(colors_final) <- unique(group)
  return(colors_final)
}

plot_pca2d <- function(pca_calculate,label="sample",colors){
  pca_df = pca_calculate$pca_df
  pc1 <- as.numeric(pca_calculate$pc1)
  pc2 <- as.numeric(pca_calculate$pc2)
  if(label=="sample"){
    g_fun <- ggplot(pca_df, aes(x=PC1, y=PC2,color=group,label=sample))
  }else{
    g_fun <- ggplot(pca_df, aes(x=PC1, y=PC2,color=group))
  }
  g_fun <- g_fun +
    scale_color_manual(values=colors) +
    scale_fill_manual(values=colors) +
    geom_point(shape=19,size=3) + #画点
    labs(title='2D PCA Plot',
         x=paste("PC1 (", round(pc1, 2), "%)", sep=""),
         y=paste("PC2 (", round(pc2, 2), "%)", sep="")) +
    theme_bw() + #加主题
    theme(text = element_text(face="bold"),
          plot.title=element_text(hjust=0.5))
  return(g_fun)
}

plot_circ <- function(pca_df){
  df_e <- t(data.frame(row.names = c("x","y","group")))
  theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, length = 50))
  circle <- cbind(cos(theta), sin(theta))
  for(i in unique(pca_df$group)){
    df_tmp <- pca_df[pca_df$group==i,]
    if(nrow(df_tmp) == 3){
      sigma <- var(df_tmp[,c("PC1","PC2")])
      mu <- c(mean(df_tmp$PC1), mean(df_tmp$PC2))
      ell <- data.frame(sweep(circle %*% chol(sigma) * sqrt(qchisq(0.68 ,df = 2)), 2, mu, FUN = '+'), group = i)
      colnames(ell) <- c("x","y","group")
      df_e <- rbind(df_e,ell)
    }
  }
  return(df_e)
}

save_pca2d <- function(pca_calculate, colors, prefix, height, width, label="T"){
  pca_df <- pca_calculate$pca_df
  group_repeat <- c()
  for(i in unique(pca_df$group)){group_repeat <- c(group_repeat,nrow(pca_df[pca_df$group==i,]))}
  df_e <- t(data.frame(row.names = c("x","y","group")))
  try(df_e <- plot_circ(pca_df))
  g <-  plot_pca2d(pca_calculate,"",colors) + stat_ellipse(aes(fill=group),geom="polygon",alpha=ifelse(min(group_repeat)>=4,0.2,0),levles=0.95)
  if (nrow(df_e)>=2) { g <- g + geom_path(data = df_e, aes(x=x,y=y,color=group)) }
  if (label == "T"){g <- g + geom_label_repel(aes( label = sample),alpha=0.8,force=1,color="black")}
  # save
  suppressMessages(ggsave(paste0(prefix,".png"),g,height=height,width=width))
  suppressMessages(ggsave(paste0(prefix,".pdf"),g,height=height,width=width))
}


plot_var <- function(pca_summary){
    pVar <- as.data.frame(t(pca_summary$importance[-1, ])) %>% rownames_to_column(var = 'PC') %>% as_tibble
    pVar <- pVar[pVar$`Proportion of Variance` != 0, ]
    if (nrow(pVar) > 5) { pVar <- pVar[1:5, ] }
    gVar <- pVar %>% gather(key = key, value = value, `Proportion of Variance`:`Cumulative Proportion`) %>%
      ggplot(aes(PC, value, group = key)) +
      geom_point() +
      geom_label_repel(aes(label = round(value, 2)), alpha = 0.8, force = 1, color = "black") +
      geom_line() +
      facet_wrap(~key, scales = "free_y") +
      theme_bw() +
      lims(y = c(0, 1)) +
      labs(x = "Principal Component", y = "Variance", title = "Variance explained by each principal component") +
      theme(text = element_text(face = "bold"), plot.title = element_text(hjust = 0.5), strip.background = element_blank())
    return(gVar)
}


plot_3d <- function(pca_calculate,colors_3d,prefix,height,width,outdir){
    pdf(file=paste0(outdir,"/", prefix,".3d.pdf"),height=height,width=width)
    a<-dev.cur()
    png(file=paste0(outdir,"/", prefix,".3d.png"),height=height,width=width, units="in", res=300)
    dev.control("enable")
    suppressWarnings(scatterplot3d(pca_calculate$pca_df[2:4], angle=60, pch=19,
                                mar=c(5, 5, 5, 5),color=colors_3d,
                                xlab=paste("PC1 (",round(pca_calculate$pc1, 2),"%)",sep=""),
                                ylab=paste("PC2 (",round(pca_calculate$pc2, 2),"%)",sep=""),
                                zlab=paste("PC3 (",round(pca_calculate$pc3, 2),"%)",sep="")))
    legend("topleft",inset=-0.1, legend=unique(factor(pca_calculate$pca_df[['group']])),
        col=unique(colors_3d), pch=19, bg="white", xpd=TRUE)
    dev.copy(which=a)
    while(!is.null(dev.list()))dev.off()
}


