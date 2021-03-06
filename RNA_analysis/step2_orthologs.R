#this script is used to compare RNA with human genetic data
#the data:/home/zhihl/Project/CRC/RNA_analysis/all_diff_data.txt

#--------------install package-----------------------------------
install_biomaRt = function (){
  if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
  BiocManager::install("biomaRt", version = "3.8")
}

#--------------analysis-------------------------------------------
library("biomaRt")
library("org.Hs.eg.db")

df_all = read.delim("/home/zhihl/Project/CRC/RNA_analysis/all_diff_data.txt",sep = "\t", header=T)
#df_all = read.delim("/home/zhihl/Project/CRC/RNA_analysis_0418_non_unique_bam/all_diff_data.txt",sep = "\t", header=T)
mouse_gene_transcript = read.delim("/home/zhihl/Project/CRC/RNA_analysis/mart_export_mouse_gene_transcript.txt", sep="\t", header=T)
orthologs_table = read.delim("/home/zhihl/Project/CRC/RNA_analysis/mart_export_humanGene_mouseGene.txt", sep="\t", header=T)



#3. convert essemble to entrez 
essemble_to_entrez = function (deg_list){
  entrez_map = as.data.frame(unlist(as.list(org.Mm.egENSEMBL2EG)))
  ind<-match(deg_list, rownames(entrez_map))
  deg_eg = entrez_map[ind,]
  return(deg_eg)
}

#4. convert essemble transcript to gene
trans2gene = function(deg_list){
  mouse_table = mouse_gene_transcript
  rownames(mouse_table) = mouse_table$Transcript.stable.ID
  select_table = mouse_table[deg_list,]
  deg_gene = select_table[,1]
  return(deg_gene)
}


#5. orthologs of mouse and human
mouse2human = function(deg_list){
  orthologs = orthologs_table
  ind = match(deg_list, orthologs$Mouse.gene.stable.ID)
  human_genes = orthologs[ind,]
  gene_list = unique(na.omit(human_genes[,1]))
  return(gene_list)
}

#6. diff orthologs
diff_gene = function(col_1, col_2, fold_change=2 ,id_type="SYMBOL"){
  #col_1: col name of log2 fold change
  #col_2: col name of padj
  #fold_change: log2 fold change
  #id_type: "SYMBOL", "ENTRIZEID" ....
  #return list of up and down genes
  
  week_df = df_all[,c(col_1, col_2)]
  diff_week_up = rownames(na.omit(week_df[week_df[,1] > fold_change & week_df[,2] < 0.01, ]))
  diff_week_down = rownames(na.omit(week_df[week_df[,1] < -(fold_change) & week_df[,2] < 0.01, ]))
  down_gene = mouse2human(diff_week_down)
  up_gene = mouse2human(diff_week_up)
  
  cols <- c("SYMBOL", "ENTREZID")
  up_symbol = select(org.Hs.eg.db, keys=as.vector(up_gene), columns=cols, keytype="ENSEMBL")
  up_list = unique(up_symbol[, id_type])
  down_symbol = select(org.Hs.eg.db, keys=as.vector(down_gene), columns=cols, keytype="ENSEMBL")
  down_list = unique(down_symbol[, id_type])
  return (list(up_list, down_list))
}

diff_genes_10w = diff_gene(col_1 = "log2FoldChange.10wkVSctrl", col_2 = "padj.10wkVSctrl")
diff_genes_7w = diff_gene(col_1 = "log2FoldChange.7wkVSctrl", col_2 = "padj.7wkVSctrl")
diff_genes_4w = diff_gene(col_1 = "log2FoldChange.4wkVSctrl", col_2 = "padj.4wkVSctrl")
diff_genes_2w = diff_gene(col_1 = "log2FoldChange.2wkVSctrl", col_2 = "padj.2wkVSctrl")

# divide groups
commom_cancer_up = intersect(diff_genes_10w[[1]], diff_genes_7w[[1]])
commom_cancer_down = intersect(diff_genes_10w[[2]], diff_genes_7w[[2]])


commom_colits_up = intersect(diff_genes_4w[[1]], diff_genes_2w[[1]])
commom_colits_down = intersect(diff_genes_4w[[2]], diff_genes_2w[[2]])

commom_all_up = intersect(commom_cancer_up, commom_colits_up)
commom_all_down = intersect(commom_cancer_down, commom_colits_down)

commom_can_up = setdiff(commom_cancer_up,commom_all_up)
commom_can_down = setdiff(commom_cancer_down, commom_all_down)

commom_col_up = setdiff(commom_colits_up,commom_all_up)
commom_col_down = setdiff(commom_colits_down, commom_all_down)

commom_col_list = list(commom_col_up, commom_col_down)
commom_can_list = list(commom_can_up, commom_can_down)
commom_all_list = list(commom_all_up, commom_all_down)


#paper 1
paper1_analysis = function(list_of_genes ){
  p_data = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/up.tsv", sep = "\t", header=F)
  whole_genes = unique(list_of_genes[[2]])
  genes_type1 = unique(p_data$V1)
  commom = intersect(whole_genes, genes_type1)
  pValue = phyper(length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), lower.tail = F)
  print(paste("down", length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), pValue, sep=","))
  
}

paper1_analysis(list_of_genes = commom_all_list)
paper1_analysis(list_of_genes = commom_can_list)
paper1_analysis(list_of_genes = commom_col_list)





#paper 2: Integrated analyses of multi-omics reveal global patterns of methylation and hydroxymethylation and screen the tumor suppressive roles of HADHB in colorectal cancer 
paper2_analysis = function(diff_genes_w){
  all_data = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/paper2/data.txt", sep = "\t", header=T)
  up_data = all_data[all_data$up == 6, ]
  down_data = all_data[all_data$down == 6, ]
  
  up_list = unique(as.vector(up_data$symbol))
  down_list = unique(as.vector(down_data$symbol))
  
  
  #print("up gene overlap:")
  commom = intersect(diff_genes_w[[1]], up_list)
  #print(commom)
  #hypergenomic test
  pValue = phyper(length(commom), length(up_list), 20000 - length(up_list), length(diff_genes_w[[1]]), lower.tail = F)
  print(paste("up", length(commom), length(up_list), 20000 - length(up_list), length(diff_genes_w[[1]]), pValue, sep=","))
  
  
  #print("down gene overlap")
  commom = intersect(diff_genes_w[[2]], down_list)
  #print(commom)
  #hypergenomic test
  pValue = phyper(length(commom), length(down_list), 20000 - length(down_list), length(diff_genes_w[[2]]), lower.tail = F)
  print(paste("down", length(commom), length(down_list), 20000 - length(down_list), length(diff_genes_w[[2]]), pValue, sep=","))
}

result = paper2_analysis(diff_genes_w = commom_all_list)
result = paper2_analysis(diff_genes_w = commom_can_list)
result = paper2_analysis(diff_genes_w = commom_col_list)



#paper 3:Gene Expression Classification of Colon Cancer into Molecular Subtypes: Characterization, Validation, and Prognostic Value
f_intersect = function (x, diff_genes_w){
  total_gene = 20000
  data_1 = data_all[data_all[, x[1]] > 0 & data_all[, x[2]] < 0.05,]
  up_list = unique(as.vector(data_1$Gene.Symbol))
  #print(up_list)
  data_1 = data_all[data_all[, x[1]] < 0 & data_all[,x[2]] < 0.05,]
  down_list = unique(as.vector(data_1$Gene.Symbol))
  
  print("up gene overlap:")
  commom = intersect(diff_genes_w[[1]], up_list)
  #print(commom)
  #hypergenomic test
  pValue = phyper(length(commom), length(up_list), 20000 - length(up_list), length(diff_genes_w[[1]]), lower.tail = F)
  print(paste(x[1], "up", length(commom), length(up_list), 20000 - length(up_list), length(diff_genes_w[[1]]), pValue, sep=","))
  
  
  print("down gene overlap")
  commom = intersect(diff_genes_w[[2]], down_list)
  #print(commom)
  #hypergenomic test
  pValue = phyper(length(commom), length(down_list), 20000 - length(down_list), length(diff_genes_w[[2]]), lower.tail = F)
  print(paste(x[2], "down", length(commom), length(down_list), 20000 - length(down_list), length(diff_genes_w[[2]]), pValue, sep=","))
  
}

paper3_analysis = function(diff_genes_w){
  data_all = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/paper3/data.txt",sep = "\t", header=T)
  select_subtype_columns = c("logFC.C1vsCx", "logFC.C2vsCx", "logFC.C3vsCx", "logFC.C4vsCx", "logFC.C5vsCx", "logFC.C6vsCx")
  select_adj_columns = c("adjpv.C1vsCx", "adjpv.C2vsCx", "adjpv.C3vsCx", "adjpv.C4vsCx", "adjpv.C5vsCx", "adjpv.C6vsCx")
  select_frame = data.frame(logFC = select_subtype_columns, adjPv = select_adj_columns)
  apply(select_frame, 1, f_intersect, diff_genes_w)
}

result = paper3_analysis(diff_genes_w = diff_genes_10w)
result = paper3_analysis(diff_genes_w = diff_genes_7w)
result = paper3_analysis(diff_genes_w = diff_genes_4w)
result = paper3_analysis(diff_genes_w = diff_genes_2w)


result = paper3_analysis(diff_genes_w = commom_all_list)
result = paper3_analysis(diff_genes_w = commom_can_list)
result = paper3_analysis(diff_genes_w = commom_col_list)


#paper 4 :Reversal of gene expression changes in the colorectal normal-adenoma pathway by NS398 selective COX2 inhibitor 
paper4_analysis = function(diff_genes_w){
  up_data = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/paper4/up.txt", sep = "\t", header=T)
  down_data = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/paper4/down.txt", sep = "\t", header=T)
  
  up_list = unique(up_data$Gene.Symbol)
  down_list = unique(down_data$Gene.Symbol)
  
  
  print("up gene overlap:")
  commom = intersect(diff_genes_w[[1]], up_list)
  #print(commom)
  #hypergenomic test
  pValue = phyper(length(commom), length(up_list), 20000 - length(up_list), length(diff_genes_w[[1]]), lower.tail = F)
  print(paste("up", length(commom), length(up_list), 20000 - length(up_list), length(diff_genes_w[[1]]), pValue, sep=","))
  
  
  print("down gene overlap")
  commom = intersect(diff_genes_w[[2]], down_list)
  #print(commom)
  #hypergenomic test
  pValue = phyper(length(commom), length(down_list), 20000 - length(down_list), length(diff_genes_w[[2]]), lower.tail = F)
  print(paste("down", length(commom), length(down_list), 20000 - length(down_list), length(diff_genes_w[[2]]), pValue, sep=","))
}

result = paper4_analysis(diff_genes_w = commom_all_list)
result = paper4_analysis(diff_genes_w = commom_can_list)
result = paper4_analysis(diff_genes_w = commom_col_list)

#paper 5: Subtypes of primary colorectal tumors correlate with response to targeted treatment in colorectal cell lines 

paper5_analysis = function(list_of_genes ){
  p_data = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/paper5/type_2_data.txt", sep = "\t", header=T)
  whole_genes = unique(list_of_genes[[1]])
  genes_type1 = unique(p_data$ENTREZ.gene.id)
  commom = intersect(whole_genes, genes_type1)
  pValue = phyper(length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), lower.tail = F)
  print(paste("up", length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), pValue, sep=","))
  
}

paper5_analysis(list_of_genes = commom_all_list)
paper5_analysis(list_of_genes = commom_can_list)
paper5_analysis(list_of_genes = commom_col_list)


#paper 6:Identification and validation of a tumor-infiltrating Treg transcriptional signature conserved across species and tumor types. 


paper6_analysis = function(list_of_genes ){
  p_data = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/paper6/up_human.txt", sep = "\t", header=T)
  whole_genes = unique(list_of_genes[[1]])
  genes_type1 = unique(p_data$GeneSymbol)
  commom = intersect(whole_genes, genes_type1)
  pValue = phyper(length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), lower.tail = F)
  print(paste("up", length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), pValue, sep=","))
  
  
  p_data = read.delim("/home/zhihl/Project/CRC/RNA_analysis/reference_diff_gene_paper1/paper6/down_human.txt", sep = "\t", header=T)
  whole_genes = unique(list_of_genes[[2]])
  genes_type1 = unique(p_data$GeneSymbol)
  commom = intersect(whole_genes, genes_type1)
  pValue = phyper(length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), lower.tail = F)
  print(paste("down", length(commom), length(genes_type1), 20000 - length(genes_type1), length(whole_genes), pValue, sep=","))
  
}

paper6_analysis(list_of_genes = commom_all_list)
paper6_analysis(list_of_genes = commom_can_list)
paper6_analysis(list_of_genes = commom_col_list)






