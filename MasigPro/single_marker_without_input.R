args=commandArgs(T)


library("maSigPro")
Time = c(rep(0, 3), rep(2, 3), rep(4, 3), rep(7, 3), rep(10, 3), rep(0, 3), rep(2, 3), rep(4, 3), rep(7, 3), rep(10, 3))
Replicates = rep(1:10, each=3)
Control = c(rep(0,30))
H3K27ac = c(rep(1,15), rep(0,15))
H3K4me1 = c(rep(0,15), rep(1,15))
#input = c(rep(1,15), rep(0,15))

marker = c("H3K27ac", "H3K4me1")

CRC.design = cbind(Time,Replicates, Control, H3K27ac , H3K4me1)
#rownames(CRC.design) <- paste("Array", c(1:90), sep = "")
sample_vector = c()
for (mark in c(marker)){
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
data_table = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip/", marker, "/", marker, "_total_readCount_50k.txt", sep="")
Rdata_file = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip/", marker, "/masigpro_", marker,".RData", sep="")
summary_pdf = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip/", marker, "/masigpro_", marker,"_result.pdf", sep="")


df = read.delim(data_table, sep="\t", header=T, row.names=1, check.names=FALSE)
#df = df[1:500, ]
df = data.matrix(df)
df = scale(df, center = TRUE, scale = TRUE)
#NBp <- p.vector(df, d, counts=TRUE)


fit <- p.vector(df, d, Q = 0.05, MT.adjust = "BH", min.obs = 5)
tstep <- T.fit(fit, step.method = "backward", alfa = 0.05)

get<-get.siggenes(tstep, rsq=0.7, vars="all")
save(tstep, file = Rdata_file)
pdf(summary_pdf)
cluster_result = see.genes(get$sig.genes, k = 9, newX11 = FALSE)
dev.off()



output_dir = paste("/home/zhihl/Project/CRC/Chip_analysis/MaSigPro/chip/", marker, "/", marker, "_", sep="")



mean_df = data.frame(a=  rowMeans(df[,1:3]), b = rowMeans(df[,4:6]), c = rowMeans(df[,7:9]), d = rowMeans(df[,10:12]), e = rowMeans(df[,13:15]))
range_df =  rowRanges(as.matrix(mean_df))
hist(range_df[,2] - range_df[,1])

df_sub = as.matrix(get$sig.genes$sig.profiles)
mean_result_df = data.frame(a=  rowMeans(df_sub[,1:3]), b = rowMeans(df_sub[,4:6]), c = rowMeans(df_sub[,7:9]), d = rowMeans(df_sub[,10:12]), e = rowMeans(df_sub[,13:15]))
range_df_sub =  rowRanges(as.matrix(mean_result_df))
hist(range_df_sub[,2] - range_df_sub[,1])



i = 1
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 2
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 3
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 4
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 5
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 6
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 7
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 8
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()


i = 9
clu1 = cluster_result$cut[cluster_result$cut == i]
#clu9 = cluster_result$cut[cluster_result$cut == 9]
#clu15 = cluster_result$cut[cluster_result$cut == 15]
#deg_list = c(names(clu8), names(clu9), names(clu15))

library(org.Mm.eg.db)
library("clusterProfiler")
ego <- enrichGO(gene          = names(clu1),
                keyType       = "ENSEMBL",
                OrgDb         = "org.Mm.eg.db",
                ont           = "ALL",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.01,
                qvalueCutoff  = 0.01)

table_name = paste(output_dir, i , ".txt", sep="")
write.table(ego@result, table_name, sep="\t", quote=F, row.names=F, col.names = T, na="NA", eol="\n")
pdf_name = paste(output_dir, i , ".pdf", sep="")
pdf(pdf_name, width=10, height=10)
dotplot(ego, showCategory=15)
dev.off()
