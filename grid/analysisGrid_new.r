# Required packages
require("dggridR") 

# Input Parameters
resolution <- 5  # Resolution of the processing grid (see the ISEA3H information)
shapefile_basename <- "dggrid"
memory_limit <- 16000  # Only used if running on Windows


# Define paths
shapefile_path = file.path(".", "output")
shapefile_full_name = paste0(shapefile_basename, "_", resolution)

# Set memory size that R can access - higher (10 and up) resolution levels require
#   increasing large memory allocation
memory.limit(memory_limit)

# Create the processing grid
dggs <- dgconstruct(res=resolution)
global <- dgearthgrid(dggs, frame=FALSE)

# Prepare the grid for output
global.cell <- data.frame(cell=getSpPPolygonsIDSlots(global),row.names=getSpPPolygonsIDSlots(global))
global <- SpatialPolygonsDataFrame(global, global.cell)

for(i in 1:length(global@polygons)) {
  if(max(global@polygons[[i]]@Polygons[[1]]@coords[,1]) -
     min(global@polygons[[i]]@Polygons[[1]]@coords[,1]) > 270) {
    global@polygons[[i]]@Polygons[[1]]@coords[,1] <- (global@polygons[[i]]@Polygons[[1]]@coords[,1] +360) %% 360
  }
}

# Write the shapefile to local
# Note: It takes about three days to export the 13 grid, an hour for the 12 grid,
#   10 mins for the 11, and much quicker for the smaller resolutions (computer dependent)
writeOGR(global, shapefile_path, shapefile_full_name, "ESRI Shapefile", overwrite_layer=TRUE)
