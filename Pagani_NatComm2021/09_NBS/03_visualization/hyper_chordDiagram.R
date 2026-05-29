# http://www.stat.columbia.edu/~tzheng/files/Rcolor.pdf

# load libraries
library('circlize')
library('RColorBrewer')
library('tidyverse')


# clear memory
circos.clear

# load connectivity matrix
data_matrix = as.matrix(read.table("hyper_matrix.csv", sep=",", header=F))
rownames(data_matrix) =  c("Control", "DMN", "DorsAtten", "Limbic", "Salience", "SomatoMotor", "TemporoParietal", "Visual", "Subcortical")
colnames(data_matrix) = rownames(data_matrix) 


# load names and colors
labels_and_colors = read.table("names_and_colors.csv", sep=",", header=T)

# colors of the links
link_color = colorRamp2(c(-20, 0, 20), c("darkblue", "white", "red"), transparency = 0.1)



# colors of the sectors
sector_color = c(Control = "#e09600", 
		DMN = "#c5464e", 
		DorsAtten = "#2e7800", 
		Limbic = "#e0f7a2", 
		Salience = "#bc49fd",
		SomatoMotor = "#5584b8",
		TemporoParietal = "#b81000",
		Visual = "#76228a",
		Subcortical = "#215a98")


# save to png
png(filename = "hyper_chordDiagnam_1.png", 
		width = 15, 
		height = 15, 
		units = "cm", 
		res= 600, 
		pointsize = 4)

# set chordDiagram parameters
# fontsize
par(cex = 5.5)

# gap between sectors
circos.par(gap.after = 3)

# plot chordDiagram
chordDiagram(data_matrix, 
	     annotationTrack = c("grid", "name"), 
	     preAllocateTracks = list(track.height = 0.01),
	     grid.col = sector_color,
	     symmetric = TRUE, 
	     col = link_color,
	     scale = TRUE,
	     self.link = 2,
	     link.largest.ontop = TRUE,
	     annotationTrackHeight = c(0.15,0.15)
)

title("Hyperconnected subtype")

dev.off()

# make color legend
myPalette = colorRampPalette(c("darkblue", "white", "red"))

plot(0:1, 0:1, type="n", bty="n", xaxs="i",
     xaxt="n", yaxt="n", xlab="", ylab="")   

colorbar.plot(0.5, 0.05, 1:100, col=myPalette(1000),
     strip.width = 0.2, strip.length = 1.1)

