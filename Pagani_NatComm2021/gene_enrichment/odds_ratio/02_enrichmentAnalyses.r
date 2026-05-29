# this code tests significant overlapping between the list previously obtained and
# the list resulting from genes that are found to be differentialy expressed in the
# autism cortex AND the interesection between tsc2 and mTOR interactomes (PPI analysis) 

# source main enrichment script, edit /path/genelistOverlap.r
source("genelistOverlap.r")

# rootpath where files are located, edit the path of the root folder
rootpath = "/media/DATA1/IIT_17Sep_Tsc2/05_gene_decoding/23_correlation_values_filtered_only_site_added_mean_ASD4_CTR3/"

# this reads the gene list, edit the folder name (path) and the list name (txt file) 
postimg_fdr05 = unique(as.character(read.delim(file.path(rootpath,"results","genesample_pos_thres_results.txt"),header=FALSE)$V1))
negtimg_fdr05 = unique(as.character(read.delim(file.path(rootpath,"results","genesample_neg_thres_results.txt"),header=FALSE)$V1))
posORnegtimg_fdr05 = unique(as.character(read.delim(file.path(rootpath,"results","genesample_posORneg_thres_results.txt"),header=FALSE)$V1))

# background totals to use for enrichment analyses 
ns_gex_background = 20787
asd_pm_background = 16398


## ASD DE co-expression modules from frontal and temporal cortex tissue 
# This gene set comes from Parikshak et al., 2016, Nature <https://www.nature.com/articles/nature20612> and includes all genes within the co-expression modules M4, M9, M10, M16, M19, and M20. Parikshak et al., found that these co-expression modules are differentially expressed in ASD frontal and temporal cortex tissue. See the figure below, which is Figure 4 from Parikshak et al.,. The list of genes and their co-expression module labels can be found in Supplementary Table 2a from Parikshak et al., <https://www.nature.com/articles/nature20612#supplementary-information>.

# ASD DE co-expression modules reported from Parikshak et al., 2016, Nature (M4, M9, M10, M16, M19, M20)
fname = "parikshak_2016_DEmods_M4_M9_M10_M16_M19_M20.txt"
asd_de_mods = unique(as.character(read.delim(file.path(rootpath,fname),header=FALSE)$V1))

## Protein-Protein Interaction (PPI) analyses to get mTOR or TSC2 network genes
# To get these genes, I went to STRING-DB <https://string-db.org> and did a query of the seed gene (TSC2 or mTOR), with the settings at medium confidence (0.4) and no more than 500 interactors in the 1st shell. Below are those settings, for reproducibility.

### Top 500 genes interacting with mTOR
# See here for the full results of that analysis <https://string-db.org/cgi/network.pl?taskId=8PgrAsf230MG>
mtor500 = unique(as.character(read.delim(file.path(rootpath,"mtor500.txt"),header=FALSE)$V1))

### Top 500 genes interacting with TSC2
# See here for the full results of that analysis <https://string-db.org/cgi/network.pl?taskId=Dka9DrbHO9a6>
tsc2500 = unique(as.character(read.delim(file.path(rootpath,"tsc2500.txt"),header=FALSE)$V1))



## Enrichment between ASD DE co-expression modules and mTOR or TSC2 networks

#### Are ASD DE co-expression modules enriched for TSC2 interactors?
res = genelistOverlap(asd_de_mods, tsc2500, asd_pm_background); asd_de_mods_AND_tsc2500 = res[[1]]$overlapping_genes;sort(asd_de_mods_AND_tsc2500)

#### Are ASD DE co-expression modules enriched for mTOR interactors?
res = genelistOverlap(asd_de_mods, mtor500, asd_pm_background); asd_de_mods_AND_mtor500 = res[[1]]$overlapping_genes;sort(asd_de_mods_AND_mtor500)

#### Which genes are both within ASD DE co-expression modules AND are TSC2 or mTOR interactors?
asd_de_mods_AND_tscORmtor500 = unique(c(asd_de_mods_AND_tsc2500,asd_de_mods_AND_mtor500))
sort(asd_de_mods_AND_tscORmtor500)

#### Are Insula Seed-Based-Analysis ASD>TD genes enriched for genes that are ASD DE co-expressed and are either TSC2 or mTOR interactors?
res_pos = genelistOverlap(postimg_fdr05, asd_de_mods_AND_tscORmtor500, ns_gex_background)
res_neg = genelistOverlap(negtimg_fdr05, asd_de_mods_AND_tscORmtor500, ns_gex_background)
res_posORneg = genelistOverlap(posORnegtimg_fdr05, asd_de_mods_AND_tscORmtor500, ns_gex_background)

res_pos = genelistOverlap(postimg_fdr05, asd_de_mods_AND_tscORmtor500, ns_gex_background); postimg_fdr05_asd_de_mods_AND_tscORmtor500 = res_pos[[1]]$overlapping_genes;sort(postimg_fdr05_asd_de_mods_AND_tscORmtor500)

res_neg = genelistOverlap(negtimg_fdr05, asd_de_mods_AND_tscORmtor500, ns_gex_background); negtimg_fdr05_asd_de_mods_AND_tscORmtor500 = res_neg[[1]]$overlapping_genes;sort(negtimg_fdr05_asd_de_mods_AND_tscORmtor500)



