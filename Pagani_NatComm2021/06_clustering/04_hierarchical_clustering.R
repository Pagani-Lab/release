# this procedure calculates a correlation matrix and perform agglomerative cluster analysis 

# loading required libraries
library('gplots')
library('corrplot')
library('RColorBrewer')

# loading the data. data is a matrix where colums are variables and rows are subjects
#mydata=read.table("globalconn_euclidean_distance_matrix.txt", header=F, sep=",")
#mydata=read.table("globalconn_cosine_distance_matrix.txt", header=F, sep=",")
#mydata=read.table("globalconn_correlation_distance_matrix.txt", header=F, sep=",")
#mydata=read.table("seed_based_insula_euclidean_distance_matrix.txt", header=F, sep=",")
mydata=read.table("seed_based_insula_cosine_distance_matrix.txt", header=F, sep=",")
#mydata=read.table("seed_based_insula_correlation_distance_matrix.txt", header=F, sep=",")

# transforming data to data.frame to data.matrix
mydata_matrix<-data.matrix(mydata, rownames.force = NA)

# loading and reversing color palettes
hmcol<-rev(brewer.pal(9,"YlOrRd"))



# set size of the heatmap
dev.new(width=16, height=16)

# visualising the matrix without agglomerative clustering
matrix_without_dendrogram <- heatmap.2(mydata_matrix,
				revC=F, # diagonal is top left to bottom right
	 			symm=T, # matrix is symmetrical
				trace=c("none"), # don't display trace	
				col=hmcol, # color of the cells
				key=T,density.info="none",keysize=1,key.title=F,key.xlab="seed_based_insula_cosine_distance_matrix",
				cexRow=0.4,cexCol=0.4, # size labels x and y axis
				dendrogram='none',     
				Rowv=FALSE,
				Colv=FALSE) 



# set size of the heatmap
dev.new(width=16, height=16)

# visualising the matrix with agglomerative clustering
matrix_with_dendrogram <- heatmap.2(mydata_matrix,
				revC=T, # diagonal is top left to bottom right
	 			symm=T, # matrix is symmetrical
				trace=c("none"), # don't display trace	
				col=hmcol, # color of the cells
				key=T,density.info="none",keysize=1,key.title=F,key.xlab="seed_based_insula_cosine_distance_matrix",
				cexRow=0.4,cexCol=0.4) # size labels x and y axis





matrix_sorted <- mydata_matrix[matrix_with_dendrogram$rowInd, matrix_with_dendrogram$rowInd]

write.csv (matrix_sorted, file = "seed_based_insula_cosine_distance_matrix_sorted.txt")



png(filename="your/file/location/name.png")
plot(fit)
dev.off()







#-------------------------------------------------------
# EXTRAS
#-------------------------------------------------------

brewer.pal.info
         maxcolors category colorblind
BrBG            11      div       TRUE
PiYG            11      div       TRUE
PRGn            11      div       TRUE
PuOr            11      div       TRUE
RdBu            11      div       TRUE
RdGy            11      div      FALSE
RdYlBu          11      div       TRUE
RdYlGn          11      div      FALSE
Spectral        11      div      FALSE
Accent           8     qual      FALSE
Dark2            8     qual       TRUE
Paired          12     qual       TRUE
Pastel1          9     qual      FALSE
Pastel2          8     qual      FALSE
Set1             9     qual      FALSE
Set2             8     qual       TRUE
Set3            12     qual      FALSE
Blues            9      seq       TRUE
BuGn             9      seq       TRUE
BuPu             9      seq       TRUE
GnBu             9      seq       TRUE
Greens           9      seq       TRUE
Greys            9      seq       TRUE
Oranges          9      seq       TRUE
OrRd             9      seq       TRUE
PuBu             9      seq       TRUE
PuBuGn           9      seq       TRUE
PuRd             9      seq       TRUE
Purples          9      seq       TRUE
RdPu             9      seq       TRUE
Reds             9      seq       TRUE
YlGn             9      seq       TRUE
YlGnBu           9      seq       TRUE
YlOrBr           9      seq       TRUE
YlOrRd           9      seq       TRUE






# checking the colours of a palette and build the color bar
brewer.pal.info
mypalette<-brewer.pal(11,"Spectral")
image(1:7,1,as.matrix(1:7),col=mypalette,yaxt="n",bty="n")

# http://cran.r-project.org/web/packages/RColorBrewer/RColorBrewer.pdf


# ulterore modifica
tiff("plot.tiff", width = 20, height = 20, units = 'cm', res = 300)
heatmap.2(corr_matrix_i, revC=T, symm=T, trace=c("none"), col=hmcol, key=F,offsetRow=0.3, offsetCol=0.3,scale=c("none","row","column")) 
dev.off()


# add Rowv=True to print a vector with the reordered labels - useful for legend
h <- heatmap.2(corr_matrix, revC=T, Rowv=TRUE,  symm=T, trace=c("none"), col=hmcol, key=TRUE, keysize=0.85, key.title=F,key.xlab="Pearson's r", density.info="none", margins = c(3,3), offsetRow=0.1, offsetCol=0.1, cexRow=0.2, cexCol=0.2) 

h$rowInd

rownames(corr_matrix)[h$rowInd]


