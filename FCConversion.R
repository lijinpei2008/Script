read_file_path <- "D:/Data/Program/20230107/expressionData.xlsx"
counts <- read.xlsx(read_file_path, sheetIndex = 2, header = TRUE)
database <- counts[, 2:7]

col_data <- data.frame(
    row.names = colnames(database),
    condition = factor(c(rep("control", 3), rep("case", 3))),
    levels = c("control", "case"))

# dds is DESeqDataSet object
dds <- DESeqDataSetFromMatrix(
                    countData = database,
                    colData = col_data,
                    design = ~condition)

dds <- DESeq(dds)
sizeFactors(dds)

res <- results(dds)
res <- as.data.frame(res)
res <- cbind(rownames(res), res)

colnames(res) <- c(
    "gengId",
    "baseMean",
    "log2FoldChange",
    "lfcSE",
    "stat",
    "pvalue",
    "padj")

write.table(
    res,
    "PvsW_gene.xlsx",
    sep = "\t",
    col.names = TRUE,
    row.names = FALSE,
    quote = FALSE,
    na = "")

# abs(
res_sig <- res
res_sig[which(res_sig$log2FoldChange > 0), "up_down"] <- "up"
res_sig[which(res_sig$log2FoldChange < 0), "up_down"] <- "down"

write.xlsx(
    res_sig,
    "PvsW_gene.xlsx",
    sheetName = "Sheet1",
    col.names = TRUE,
    row.names = TRUE
)
