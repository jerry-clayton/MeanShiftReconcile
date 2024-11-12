

## Accept command line arguments for input LAS, tarball, and output file. 1st 2 are passed by user, 3rd is generated automatically in run.sh
args <- commandArgs(trailingOnly = TRUE)
input_las <- args[1]
tarfile <- args[2]
output_file <- args[3]

library(lidR)
library(MeanShiftR)
library(data.table)
library(sf)
library(plyr)

print(paste("input las:",input_las))
print(paste("tarball:",tarfile))

# use all available processor cores
set_lidr_threads(0)

# Unpack the tarball into a temp directory and print filenames
extract_dir <- tempdir()
untar(tarfile, exdir = extract_dir)
filenames <- Sys.glob(paste0(extract_dir,"/*"))

print(paste("RDS files found:", length(filenames)))
for (f in filenames){
    print(f)
    }

##  Read header and file separately so that we can save the LAS later
f_head <- readLASheader(input_las)
f_las <- readLAS(input_las)

# convert LAS to data.table for MeanShiftR package
las_dt <- lidR::payload(f_las) %>% as.data.table

# read in all segmented tiles to one list
pc.list <- vector("list",length(filenames))

for(file in 1:length(filenames)){
    curr <- as.data.table(readRDS(filenames[file]))
    pc.list[[file]] <- curr
    }
# combine tiles
    ms_result <- data.table::rbindlist(pc.list)
    print('data tables combined')
# Generate IDs
    ms_result[ , ID := .GRP, by = .(RoundCtrX, RoundCtrY, RoundCtrZ)]
    print("IDs generated")

    print("joining ms result to original data")
     
    # make merging IDs (for points, not trees) from xyz coords, store in variable 'concat'
     las_dt[, concat := paste(X,Y,Z, sep = "_")]
     ms_result[, concat := paste(X,Y,Z, sep = "_")]

     ms_result[, ID := ID]
     # left join (update-by-reference-join) (stackoverflow)
     # adds treeID to original lidR payload ONLY for those points with IDs

     las_dt[ms_result, on = "concat", ID := ID]
 
     # save meanshift-generated IDs to LAS format

     # specifically: use original header with updated data and then force the header to update with add_lasattribute_manual()
     flas <- LAS(las_dt, f_head)
     flas <- add_lasattribute_manual(flas, las_dt[,ID], name = "ID", desc = "tree ID", type = "int64", NA_value = 99999) ## 99999 is nodata value because 0 might be a valid ID

     writeLAS(flas, output_file)

     print("segmented las written")

##### 
##   End Reconciliation
#####
