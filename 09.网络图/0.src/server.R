
source("0.src/source.R")

# server <- function(input, output) {}

server <- function(input, output, session) {
  
  
  output$node_select <- renderUI({
    req(input$node_path)
    nodes <- read_tsv(input$node_path$datapath, show_col_types = FALSE)
    col_names = colnames(nodes)
    tagList(
      # helpText("节点形状为离散变量（字符），节点颜色和大小为连续变量（数字）"),
      selectInput("node_col_shape", "选择节点形状列", choices = col_names[-1], selected = col_names[2]),
      selectInput("node_col_color", "选择节点颜色列", choices = col_names[-1], selected = col_names[3]),
      selectInput("node_col_size",  "选择节点大小列", choices = col_names[-1], selected = col_names[4])
    )
  })
  output$edge_select <- renderUI({ 
    req(input$edge_path)
    edges <- read_tsv(input$edge_path$datapath, show_col_types = FALSE)
    col_names = colnames(edges)
    tagList(
      # helpText("连线颜色列为连续变量（数字）"),
      selectInput("edge_col_color", "选择连线颜色列", choices = col_names[-c(1,2)], selected = col_names[3])
    )
  })
  
  observeEvent(input$run, {
    if (is.null(input$edge_path)) {
      showModal(modalDialog( title = "错误", "请上传edge文件。", easyClose = TRUE, footer = NULL ))
      return()
    }
    
    if (is.null(input$node_path)) {
      showModal(modalDialog( title = "错误", "请上传node文件。", easyClose = TRUE, footer = NULL ))
      return()
    }
    
    mytheme <-  theme_minimal() +
      theme(
        panel.grid = element_blank(),
        axis.line = element_blank(),
        axis.ticks =element_blank(),
        axis.text =element_blank(),
        axis.title = element_blank(),
        plot.margin=unit(c(0,0,0,0), "null"),
        panel.spacing=unit(c(0,0,0,0), "null")
      )
    
    # 
    # input = list(
    #   edge_path = list(datapath = "1.input/cytoscape/demo.ko_enrich.pathway.edges.txt"),
    #   node_path = list(datapath = "1.input/cytoscape/demo.ko_enrich.pathway.nodes.txt"),
    #   prefix  = "out",
    #   color_edge = "#A50026,#D73027,#F46D43,#FDAE61,#FEE08B,#FFFFBF,#D9EF8B,#A6D96A,#66BD63,#1A9850,#006837",
    #   color_node = "#E64B35,#4DBBD5,#00A087,#3C5488,#F39B7F,#8491B4,#91D1C2,#DC0000,#7E6148,#B09C85,#E41A1C,#377EB8,#4DAF4A,#984EA3,#FF7F00,#FFFF33,#A65628,#F781BF,#1B9E77,#D95F02,#7570B3,#E7298A,#66A61E,#E6AB02,#A6761D,#666666",
    #   edge_col_color = "Class_A_source",
    #   node_col_shape = "Class_A",
    #   node_col_color = "pvalue",
    #   node_col_size  = "Count",
    #   width = 8,
    #   height = 8,
    #   layout = "circ"
    # )
    
    out_dir = "2.output"
    out_prefix = paste0(out_dir,"/",input$prefix)
    check_dir_exists(out_dir)
    
    # 
    #-------main--------
    # 这里是逻辑代码
    
    
    
    edges <- read_tsv(input$edge_path$datapath, show_col_types = FALSE)
    colnames(edges)[1:2] <- c("node1","node2")
    
    edges$node1 <- as.character(edges$node1)
    edges$node2 <- as.character(edges$node2)
    
    nodes <- read_tsv(input$node_path$datapath,show_col_types = FALSE) %>% filter(ID %in% c(edges$node1,edges$node2))
    
    color_edge <- strsplit(input$color_edge, ",")[[1]]
    color_node <- strsplit(input$color_node, ",")[[1]]
    
    
    edge_node <- table(c(edges$node1,edges$node2)) %>% sort() %>% names()
    edges <- edges[(edges$node1 %in% edge_node ) & (edges$node2 %in% edge_node ),]
    nodes <- nodes[nodes$ID %in% unique(c(edges$node1,edges$node2)),]
    
    
    nodes[,"color"] <- nodes[,input$node_col_color] 
    nodes[,"size"]  <- nodes[,input$node_col_size]  
    nodes[,"shape"] <- nodes[,input$node_col_shape] 
    
    edges[,"color"] <- edges[,input$edge_col_color] 
    
    ggraph <- tidygraph::tbl_graph(nodes = nodes, edges = edges)
    # write_graph(ggraph, file = paste(out_prefix,layout,"gml",    sep="."), format = "gml")
    write_graph(ggraph, file = paste(out_prefix,"graphml",sep="."), format = "graphml") # gephi可以打开
    
    for (layout in input$layout){
      showNotification(paste("开始画",layout))
      if (layout == "circ"){
        nodes <- nodes %>%   mutate(id = c(1:nrow(nodes)),
                                    angle = 90 - 360 * id / nrow(nodes),
                                    hjust = ifelse(angle < -90, 1, 0) ,
                                    angle = ifelse(angle < -90, angle+180, angle)) 
        
        ggraph <- tidygraph::tbl_graph(nodes = nodes, edges = edges)
        g <- ggraph(ggraph,layout = 'linear', circular = TRUE) +
          geom_node_point(aes(x = x*1.08, y = y*1.08,
                              color = color, size = size, shape=shape))
        if(input$label){
          g <- g + geom_node_text(aes(x = x*1.16, y = y*1.16, label = ID,
                                      angle = angle, hjust = hjust, color = color), size = 2.8, alpha = 1)
        }
        coord_fixed()
        if(input$arrow){
          g <- g + geom_edge_link(arrow =arrow(angle = 15, length = unit(0.03, "npc"),
                                               ends = "last", type = "closed") , #color="#80a492",
                                  edge_alpha = 0.2, edge_width=0.8,aes(color=color))
        }else{
          g <- g + geom_edge_arc(aes(edge_colour = color), edge_alpha = 0.6,edge_width=0.5)
          
        }
        
      }else{
        g <- ggraph(ggraph,layout = layout) +
          # geom_edge_fan(aes(edge_colour = color), edge_alpha = 0.6,edge_width=0.5) +
          geom_node_point(aes(color=color,size=size, shape=shape))
        if(input$label){
          g <- g + geom_node_text(aes(label = ID))
        }
        if(input$arrow){
          g <- g + geom_edge_link(arrow =arrow(angle = 15, length = unit(0.03, "npc"),
                                               ends = "last", type = "closed") , #color="#80a492",
                                  edge_alpha = 0.2, edge_width=0.8,aes(color=Class_A_source))
          
        }else{
          g <- g + geom_edge_fan(aes(edge_colour = color), edge_alpha = 0.6,edge_width=0.5)
        }
      }
      
      if(is.numeric(nodes$color)){ # 
        g <- g + scale_color_gradientn(colors = colorRampPalette(color_node)(1000))
      }else{
        if(length(unique(nodes$color))>length(color_node)){color_node=colorRampPalette(color_node)(length(unique(nodes$color)))}
        g <- g + scale_color_manual(values = color_node)
      }
      if(is.numeric(edges$color)){
        g <- g + scale_edge_color_gradientn(colors = colorRampPalette(color_edge)(1000))
      }else{
        if(length(unique(edges$color))>length(color_edge)){color_edge=colorRampPalette(color_edge)(length(unique(edges$color)))}
        g <- g + scale_edge_color_manual(values = color_edge)
      }

      if(is.numeric(nodes$size)){
        g <- g + scale_size_binned(range = input$node_size_size)
      }
                
      
      g <- g +
        expand_limits(x = c(-2.0, 2.0), y = c(-2.0, 2.0))+
        coord_fixed()+
        labs(size = "node_size", edge_colour = "edge_color")+
        guides(size = guide_legend(order = 3),color = guide_legend(order = 2),shape=guide_legend(order=1)) +
        mytheme
      
      ggsave(paste(out_prefix,layout,"svg",sep="."),g,width=input$width, height=input$height)
      ggsave(paste(out_prefix,layout,"pdf",sep="."),g,width=input$width, height=input$height)
      ggsave(paste(out_prefix,layout,"png",sep="."),g,width=input$width, height=input$height,bg="white", units="in", dpi=300)
      
    }
    
    output$ggraph_plot <- renderPlot({
      g
    })
    
    
    
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



# is_discrete <- function(column) {
#   if (is.factor(column)) {
#     return(TRUE)
#   }
#   if (is.integer(column) || (is.numeric(column) && length(unique(column)) < 10)) {
#     return(TRUE)
#   }
#   return(FALSE)
# }
