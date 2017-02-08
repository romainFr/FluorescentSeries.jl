module FluorescentSeries
using AxisArrays, Unitful, SimpleTraits, ImageAxes

import Base: +,.+,-,.-,*,.*,/,./,.^,sin,cos,tan,asin,acos,atan,sinh,cosh,tanh,asinh,acosh,atanh,exp,log,log2,log10,sqrt,lgamma,log1p,erf,erfc
import Base: copy,getindex,hcat,quantile,length,setindex!,size,vcat
# package code goes here
include("core.jl")
include("algorithms.jl")

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
