gene_detail = read.delim("/home/zhihl/Project/CRC/RNA_analysis/mart_export_mouse_geneid_symbol.txt", sep="\t", header=T)
essemble_to_entrez = function (deg_list){
  entrez_map = as.data.frame(unlist(as.list(org.Mm.egENSEMBL2EG)))
  ind<-match(deg_list, rownames(entrez_map))
  deg_eg = entrez_map[ind,]
  return(deg_eg)
}

ensembl_to_symbol = function(ensemble_list, name){
  if (name == "mouse")
  {symbol = gene_detail[match(ensemble_list, gene_detail$ensembl_gene_id),"external_gene_name"]}
  if (name == "human")
  {symbol = human_gene_detail[match(ensemble_list, human_gene_detail$ensembl_gene_id),"external_gene_name"]}
  return(as.vector(symbol)) 
}

#construct matrix


library("maSigPro")
library(org.Mm.eg.db)
library("clusterProfiler")



Time = c(rep(0, 3), rep(2, 3), rep(4, 3), rep(7, 3), rep(10, 3), rep(0, 3), rep(2, 3), rep(4, 3), rep(7, 3), rep(10, 3), rep(0, 3), rep(2, 3), rep(4, 3), rep(7, 3), rep(10, 3)) 
Replicates = rep(1:15, each=3)
Control = c(rep(0,30), rep(1, 15))
H3K27ac = c(rep(1,15), rep(0,30))
H3K4me1 = c(rep(0,15), rep(1,15), rep(0,15))
#input = c(rep(1,15), rep(0,15))

marker = c("H3K27ac", "H3K4me1")

CRC.design = cbind(Time,Replicates, Control, H3K27ac, H3K4me1)
#rownames(CRC.design) <- paste("Array", c(1:90), sep = "")
sample_vector = c()
for (mark in c(marker, "Input")){
  for (we in c("ctrl", "2weeks", "4weeks", "7weeks", "10weeks")){
    for ( rep in c("1", "2" ,"3")){
      sample = paste(paste(we, rep, sep="_"), mark, sep="_")
      sample_vector = c(sample_vector, sample)
    }
  }
}
rownames(CRC.design) = sample_vector
d <- make.design.matrix(CRC.design, degree = 4)
d

marker = "enhancer"
data_table = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip_v2/", marker, "/", marker, "_total_readCount.100k.txt", sep="")
Rdata_file = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip_v2/", marker, "/masigpro_", marker,".RData", sep="")
summary_pdf = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip_v2/", marker, "/masigpro_", marker,"_result.pdf", sep="")


df = read.delim(data_table, sep="\t", header=T, row.names=1, check.names=FALSE)
df = data.matrix(df)
df = scale(df, center = TRUE, scale = TRUE)
fit <- p.vector(df, d, Q = 0.05, MT.adjust = "BH", min.obs = 5)
tstep <- T.fit(fit, step.method = "backward", alfa = 0.05)

load(Rdata_file)

get<-get.siggenes(tstep, rsq=0.75, vars="all")
save(tstep, file = Rdata_file)
pdf(summary_pdf)
cluster_result = see.genes(get$sig.genes, k = 9, newX11 = FALSE)
dev.off()

output_dir = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip_v2/", marker, "/", marker, "_", sep="")

i = 1
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()



i = 2
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 3
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 4
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 5
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()

i = 6
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 7
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()

i = 8
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 9
clu1 = cluster_result$cut[cluster_result$cut == i]
symbol_vector = ensembl_to_symbol(names(clu1), "mouse")
gene_table = data.frame(ensembl = names(clu1), symbol = symbol_vector)
table_name = paste(output_dir, i , "_gene_list.txt", sep="")
write.table(gene_table, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_cluster_rna.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
ego <- enrichKEGG(gene          = essemble_to_entrez(names(clu1)),
                  keyType       = "kegg",
                  organism      = "mmu",
                  pAdjustMethod = "BH",
                  pvalueCutoff  = 0.01)
table_name = paste(output_dir, i , "_KEGG.txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , "_KEGG.pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
