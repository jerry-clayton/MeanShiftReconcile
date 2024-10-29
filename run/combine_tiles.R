

args <- commandArgs(trailingOnly = TRUE)
input_las <- args[1]
rds_dir <- args[2]
output_file <- paste0(input_las,".rds")

library(lidR)
library(MeanShiftR)
library(data.table)
library(sf)
library(plyr)

print(paste("input las:",input_las))
print(paste("rds dir:",rds_dir))

# use all available processor cores
set_lidr_threads(0)

#####
##   Begin function definitions for merging
#####

globstr <- paste0(rds_dir,"*.rds")
filenames <- Sys.glob(globstr)

print(paste("RDS files found:", length(filenames))

###
##   Begin reconciliation
###

# read header and file separately so that we can save the LAS later
f_head <- readLASheader(input_las)
f_las <- readLAS(input_las)

# convert LAS to data.table for MeanShiftR package
f_dt <- lidR::payload(f_las) %>% as.data.table

# read in all RDS files
pc.list <- list()
for(file in 1:length(filenames)){
    curr <- readRDS(filenames[file])
    pc.list <- append(pc.list, curr)
    }
      
    full.dt <- data.table::rbindlist(pc.list)
    print('data tables combined')
    
    full.dt[ , ID := .GRP, by = .(RoundCtrX, RoundCtrY, RoundCtrZ)]
    print("IDs generated")
    save_rds(full.dt, output_file)
    # print("joining ms result to original data")
     
    # # make IDs from xyz coords
    #  f_dt[, concat := paste(X,Y,Z, sep = "_")]
    #  ms_result[, concat := paste(X,Y,Z, sep = "_")]

    #  ms_result[, ID := ID]
    #  # left join (update-by-reference-join) (stackoverflow)
    #  # adds treeID to original lidR payload

    #  f_dt[ms_result, on = "concat", ID := ID]
 
    #  # save meanshift-generated IDs to LAS format
    #  # specifically: use original header with updated data and then force the header to update with add_lasattribute_manual()
    #  flas <- LAS(f_dt, f_head)
    #  flas <- add_lasattribute_manual(flas, f_dt[,ID], name = "ID", desc = "tree ID", type = "int64", NA_value = 99999)


    #  writeLAS(flas, output_file)

    #  print("segmented las written")

##### 
##   End Reconciliation
#####
