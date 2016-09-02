module FluorescentSeries

import Base: getindex,hcat,quantile,length,setindex!,size,vcat
# package code goes here
include("core.jl")

export
AbstractFluorescentSerie,
FluorescentSerie,
times,
fluo,
rois,
avgImage,
metadata,
deltaFF


end # module
