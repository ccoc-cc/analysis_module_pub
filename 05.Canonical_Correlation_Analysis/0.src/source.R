
get_data <- function(data_path, sample_list) {
  raw_df <- read_tsv(data_path, show_col_types = FALSE)  %>% column_to_rownames(var="ID")
  # raw_df <- raw_df[!is.na(raw_df$type),]
  # raw_df <- raw_df[raw_df$type=="up" | raw_df$type=="down",]
  raw_df$ID <- rownames(raw_df)
  data <- scale(t(raw_df[,sample_list]))
  return(list(raw_df=raw_df,data=data))
}


perform_cca_analysis <- function(data_path_1, data_path_2, group_path, parameter = "auto") {
  group_df    <- read_tsv(group_path, show_col_types = FALSE)

  sample_x <- unique(group_df$sample1)
  sample_y <- unique(group_df$sample2)
  
  # sample_x_m = paste(sample_x,collapse = ".")
  # showNotification(sample_x_m)

  get_data_x = get_data(data_path_1,sample_x)
  get_data_y = get_data(data_path_2,sample_y)
  data_x = get_data_x$data
  data_y = get_data_y$data
  
  if (parameter == "auto") {
    rcc_analysis <- TRUE
    parameter <- 0
    while (rcc_analysis) {
      rcc_analysis <- tryCatch(
        {rcc(data_x, data_y, parameter, parameter)},
        error = function(err) TRUE
      )
      if (is.logical(rcc_analysis) && rcc_analysis == TRUE) {
        if (parameter > 10) {
          stop("无法完成CCA")
        } else {
          parameter <- parameter + 0.1
        }
      } else {
        res.rcc <- rcc_analysis
        rcc_analysis <- FALSE
      }
    }
  } else {
    res.rcc <- rcc(data_x, data_y, parameter[1], parameter[2])
  }
  return(list(res.rcc = res.rcc, raw_x = get_data_x$raw_df, raw_y = get_data_y$raw_df))
}

gg_circle <- function(r, xc, yc, color="black", fill=NA, ...) {
  x <- xc + r*cos(seq(0, pi, length.out=100))
  ymax <- yc + r*sin(seq(0, pi, length.out=100))
  ymin <- yc + r*sin(seq(0, -pi, length.out=100))
  annotate("ribbon", x=x, ymin=ymin, ymax=ymax, color=color, fill=fill, ...)
}

  
plot_cca <- function(res) {
  res.rcc <- res$res.rcc
  raw_x <- res$raw_x
  raw_y <- res$raw_y
  
  X_plot_raw <- res.rcc$scores$corr.X.xscores[,1:2] %>%
    `colnames<-`(paste0("Dimension",1:2)) %>% as.data.frame() %>% 
    rownames_to_column(var="ID") %>% merge(raw_x[,c("ID","type")], by = "ID") %>% 
    mutate(class="data1") %>% 
    mutate(len=sqrt(Dimension1^2 + Dimension2^2)) %>% arrange(desc(len))
  
  # X_plot_diff   <- X_plot_raw %>% filter(type=="up" | type == "down") %>% arrange(desc(len))
  # X_plot_nodiff <- X_plot_raw %>% filter(type!="up" & type != "down")
  
  Y_plot_raw <- res.rcc$scores$corr.Y.xscores[,1:2] %>%
    `colnames<-`(paste0("Dimension",1:2)) %>% as.data.frame() %>% 
    rownames_to_column(var="ID") %>% 
    merge(raw_y[,c("ID","type")], by = "ID") %>% 
    mutate(class="data2") %>%
    mutate(len=sqrt(Dimension1^2 + Dimension2^2)) %>% arrange(desc(len))

  # Y_plot_diff   <- Y_plot_raw %>% filter(type=="up" | type == "down") %>% arrange(desc(len))
  # Y_plot_nodiff <- Y_plot_raw %>% filter(type!="up" & type != "down")
  
  # plot_df <- rbind(X_plot_diff, Y_plot_diff)
  plot_df <- rbind(X_plot_raw, Y_plot_raw)
      
  color_type = c("#E64B35","#4DBBD5","#00A087","#3C5488","#F39B7F","#8491B4","#91D1C2","#EE4C97","#FFDC91","#0072B5","#7E6148","#B09C85")
  g <- ggplot() +
    geom_point(data=plot_df, aes(x=Dimension1, y=Dimension2, color=type, shape=class, label=ID), size=1) +
    geom_vline(xintercept=0) + geom_hline(yintercept=0) +
    gg_circle(r=1, xc=0, yc=0) + gg_circle(r=0.5, xc=0, yc=0) +
    labs(title="Canonical Correlation Analysis") +
    xlim(-1.05, 1.05) + ylim(-1.05, 1.05) +
    theme_bw() +
    scale_color_manual(values=color_type) +
    theme(plot.title = element_text(hjust = 0.5), text=element_text(face="bold"))
  return(list(g=g,plot_df=plot_df))

}

