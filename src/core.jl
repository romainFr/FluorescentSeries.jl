
abstract AbstractFluorescentSerie

type FluorescentSerie<:AbstractFluorescentSerie
    raw::Array{Float64,2}
    timeframe::Vector{Float64}
    rois::Array{Array{Int64,1},1}
    avg::AbstractArray{Float64}
    meta::Any

    function FluorescentSerie(raw::Array{Float64,2},
                              timeframe::Vector{Float64},
                              rois::Array{Array{Int64,1},1},
                              avg::AbstractArray{Float64},
                              meta::Any)
        size(raw)[1] != length(timeframe) ? error("Signal should be same length as the timeframe."):
        size(raw)[2] != length(rois) ? error("Number of rois should correspond to the number of columns of data"):
        new(raw,timeframe,rois,avg,meta)
    end
end

# Missing metadata
FluorescentSerie(raw::Array{Float64,2},timeframe::Vector{Float64},rois::Array{Array{Int64,1},1},avg::AbstractArray{Float64}) = FluorescentSerie(raw,timeframe,rois,avg,nothing)

## Add tests for time dim being the last one ?
# Constructing from a ROI image and the raw data
function FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},roiIm::AbstractArray{Int64,N},avg::AbstractArray{Float64,N},meta::Any,period::Float64,summaryFunc::Function=sum)
    #Images.assert_time_dim_last(rawImage)
    N2 != (N+1) ? error("Rois should have one less dimension than the raw data"):
    size(rawImage)[1:N] != size(roiIm) ? error("ROI image has a different size than the data"):
    nt = size(rawImage)[N2]
    results = zeros(nt,maximum(roiIm))
    rois = Array{Array{Int64,1},1}(maximum(roiIm))
    for i in 1:maximum(roiIm)
        for j in 1:nt
            rois[i] = find(roiIm.==i)
            results[j,i] = summaryFunc(slicedim(rawImage,N2,j)[rois[i]])
        end
    end
    timeframe = collect(0:period:((nt-1)*period))
    
    FluorescentSerie(results,timeframe,rois,avg,meta)
end


## If Rois are given as an array of indices
function FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::Array{Array{Int64,1},1},avg::AbstractArray{Float64,N},meta::Any,period::Float64,summaryFunc::Function=sum)
    #Images.assert_time_dim_last(rawImage)
    N2 != (N+1) ? error("Average image should have one less dimension than the raw data"):
    nt = nimages(rawImage)
    results = zeros(nt,length(rois))
    for i in eachindex(rois)
        for j in 1:nt
            results[j,i] = summaryFunc(slicedim(rawImage,N2,j)[rois[i]])
        end
    end
    timeframe = collect(0:period:((nt-1)*period))
    
    FluorescentSerie(results,timeframe,rois,avg,meta)
end


function FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},meta::Any,period::Float64,summaryFunc::Function=sum)
    avg = mean(rawImage,N2)
    FluorescentSerie(rawImage,rois,avg,meta,period,summaryFunc)
end

FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},avg::AbstractArray{Float64,N},period::Float64,summaryFunc::Function=sum)=FluorescentSerie(rawImage,rois,avg,nothing,period,summaryFunc)

function FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},avg::AbstractArray{Float64,N},summaryFunc::Function=sum)
    period = rawImage["period"]
    FluorescentSerie(rawImage,rois,avg,nothing,period,summaryFunc)
end

FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},period::Float64,summaryFunc::Function=sum)=FluorescentSerie(rawImage,rois,nothing,period,summaryFunc)

function FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},summaryFunc::Function=sum)
    period = rawImage["period"]
    FluorescentSerie(rawImage,rois,nothing,period,summaryFunc)
end


### Methods
length(fs::AbstractFluorescentSerie) = length(fs.timeframe)
size(fs::AbstractFluorescentSerie) = size(fs.raw)


typealias RealIndex{T<:Real} Union{T, AbstractVector{T}, Colon}
## GetIndex
## One,one
function getindex(fs::FluorescentSerie,n::RealIndex,ro::RealIndex)
    FluorescentSerie(getindex(fs.raw,n,ro),getindex(fs.timeframe,n),fs.rois,fs.avg,fs.meta)
end

## In case only one column is present.
function getindex(fs::FluorescentSerie,n::RealIndex)
    FluorescentSerie(getindex(fs.raw,n),getindex(fs.timeframe,n),fs.rois,fs.avg,fs.meta)
end

## SetIndex
function setindex!(fs::FluorescentSerie,X,n::RealIndex,ro::RealIndex)
    FluorescentSerie(setindex!(fs.raw,X,n,ro),fs.timeframe,fs.rois,fs.avg,fs.meta)
end

function setindex!(fs::FluorescentSerie,X,n::RealIndex)
    FluorescentSerie(setindex!(fs.raw,X,n),fs.timeframe,fs.rois,fs.avg,fs.meta)
end


## Accessors
times(fs::FluorescentSerie) = fs.timeframe

fluo(fs::FluorescentSerie) = fs.raw

rois(fs::FluorescentSerie) = fs.rois

avgImage(fs::FluorescentSerie) = fs.avg

metadata(fs::FluorescentSerie) = fs.meta

## Concatenation
function hcat(fs::FluorescentSerie,gs::FluorescentSerie)
    fs.timeframe != gs.timeframe ? error("Can only concatenate ROI series with the same timebase."):
    avg = (fs.avg + gs.avg)/2
    FluorescentSerie(hcat(fluo(fs),fluo(gs)),times(fs),vcat(fs.rois,gs.rois),avg,(fs.meta,gs.meta))
end

function vcat(fs::FluorescentSerie,gs::FluorescentSerie)
    fs.rois != gs.rois ? error("Can only concatenate if the series have the same ROIs"):
    timeframe = [fs.timeframe;gs.timeframe+fs.timeframe[end]+gs.timeframe[1]]
    avg = (fs.avg + gs.avg)/2
    FluorescentSerie(vcat(fluo(fs),fluo(gs)),timeframe,fs.rois,avg,(fs.meta,gs.meta))
end


## Others
## Quantile, useful for baseline calculations
function quantile(fs::FluorescentSerie,p)
    results = Array{Float64}(size(fs)[2])
    for i in 1:size(fs)[2]
        results[i] = quantile(fs.raw,p)
    end
    results
end

## DeltaF/F
function deltaFF!(fs::FluorescentSerie,Fo::Array{Float64,1},B::Float64=0)
    length(Fo) != size(fs)[2] ? error("Fo vector should be the same length as the number of ROIs in the series."):
    for i in eachindex(Fo)
        fs[:,i] = (fs[:,i] .- Fo[i])./(Fo[i]-B)
    end
    fs
end

deltaFF(fs::FluorescentSerie,Fo::Array{Float64,1},B::Float64=0) = deltaFF!(copy(fs),Fo,B)

### TODO :
# - Plots.jl recipes
