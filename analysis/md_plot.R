# required libraries
# install.packages('bio3d', repos='http://cran.us.r-project.org')
# install.packages('lattice', repos='http://cran.us.r-project.org')
# install.packages('ncdf4', repos='http://cran.us.r-project.org')



library(bio3d)

# example: `Rscript ../../scripts/md_plot.R test wt $PWD md_0_10 md_0_10_fit`


args <- commandArgs(trailingOnly = TRUE)

# project_id <- 't5ah2'
project_id <- args[1]
# variant_id <- 'wt'
variant_id <- args[2]

# workdir <- '/mnt/data/yinying/project/t5ah2/md/process/output_unbonded'
workdir <- args[3]

# pdb_prefix <- 'md_0_200'
pdb_prefix <- args[4]
# dcd_prefix <- 'md_0_200_fit'
dcd_prefix <- args[5]


pdbfile <- paste(workdir,  '/', pdb_prefix, '.pdb', sep = '')
dcdfile <- paste(workdir, '/', dcd_prefix, '.dcd', sep = '')

print(paste('Processing', dcdfile))

pdb <- read.pdb(pdbfile)
dcd <- read.dcd(dcdfile)

dir.create("csvs")
dir.create("img")
dir.create("pca")

# prepare
ca.inds <- atom.select(pdb, elety="CA")

xyz <- fit.xyz(fixed=pdb$xyz, mobile=dcd,
               fixed.inds=ca.inds$xyz,
               mobile.inds=ca.inds$xyz)
print('Prepared for plot.')

print('Reading RMSD...')
rd <- rmsd(xyz[1,ca.inds$xyz], xyz[,ca.inds$xyz])

# create a empty pdf
print('Ploting RMSD...')
pdf(paste('img/',project_id, ".", variant_id, "_rmsd_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
# do the plot
plot(rd, typ="l", ylab="RMSD", xlab="Frame No.")
points(lowess(rd), typ="l", col="red", lty=2, lwd=2)
# finish plot by closing the plot obj
dev.off()

# save rmsd traj

print('Saving RMSD table...')
write.csv(rd, file=paste('csvs/',variant_id, '_rmsd_200ns.csv', sep = ''))


# plot rmsd histogram
print('Ploting RMSD hist...')
pdf(paste('img/',project_id, ".",variant_id, "_rmsd_his_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
hist(rd, breaks=40, freq=FALSE, main="RMSD Histogram", xlab="RMSD")
lines(density(rd), col="gray", lwd=3)
dev.off()

# plot global rms fluctuation
print('Reading RMSF...')
rf <- rmsf(xyz[,ca.inds$xyz])


print('Ploting RMSF...')
pdf(paste('img/',project_id, ".", variant_id, "_rmsf_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
plot(rf, ylab=paste("RMSF - ", variant_id), xlab="Residue Position", typ="l")
dev.off()
# save rmsf

print('Saving RMSF...')
write.csv(rf, file=paste('csvs/', variant_id, '_rmsf_200ns.csv', sep = ''))


# plot pca
print('Ploting PCA...')
pdf(paste('img/',project_id, ".", variant_id, "_pca_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
pc <- pca.xyz(xyz[,ca.inds$xyz])
plot(pc, col=bwr.colors(nrow(xyz)) )
dev.off()


# plot conformation clusters
print('Reading Conformation Clusters...')
pdf(paste('img/',project_id, ".", variant_id, "_conf_cluster_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
hc <- hclust(dist(pc$z[,1:2]))
grps <- cutree(hc, k=2)
plot(pc, col=grps)
dev.off()


# plot per residue PC1 
print('Reading PC1...')
pdf(paste('img/',project_id, ".", variant_id, "_pres_pc1_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
plot.bio3d(pc$au[,1], ylab="PC1 (A)", xlab="Residue Position", typ="l")
points(pc$au[,2], typ="l", col="blue")
dev.off()

# plot per residue PC2
print('Reading PC2...')
pdf(paste('img/',project_id, ".", variant_id, "_pres_pc2_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
plot.bio3d(pc$au[,2], ylab="PC2 (A)", xlab="Residue Position", typ="l")
points(pc$au[,2], typ="l", col="blue")
dev.off()


print('New dir created: pca')
print('Saving PCA structure...')
# dump the pc1 and pc2 structure
p1 <- mktrj.pca(pc, pc=1, b=pc$au[,1], file=paste('pca/', project_id, '.', variant_id, '_pc1.pdb', sep = ''))
p2 <- mktrj.pca(pc, pc=2, b=pc$au[,2], file=paste('pca/', project_id, '.', variant_id, '_pc2.pdb', sep = ''))


# dump the pc1 trajectory, which can be loaded to PyMOL using `load_traj` command
print('Saving PCA Traj...')
write.ncdf(p1, paste('pca/', project_id, '.', variant_id, '_trj_pc1.nc', sep = ''))
write.ncdf(p2, paste('pca/', project_id, '.', variant_id, '_trj_pc2.nc', sep = ''))

print('Prepare Residue Cross Correlation matrix...')
# prepare residue cross correlation matrix
cij<-dccm(xyz[,ca.inds$xyz])

# plot it in 2d 

print('Ploting RCC...')
pdf(paste('img/',project_id, ".", variant_id, "_rcc_", pdb_prefix ,"_plot.pdf", sep = ''), width = 7, height = 5)
plot(cij)
dev.off()

# dump cji matrix to csv for further analysis
print('Saving RCC table...')
write.csv(cij, file = paste('csvs/',project_id,'.',variant_id, '_rcc-cij.csv', sep = ''))

q()

