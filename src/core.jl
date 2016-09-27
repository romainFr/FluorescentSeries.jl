
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
    timeframe = collect(range(0,period,nt))
    
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
    timeframe = collect(range(0,period,nt))
    
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

function FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},avg::AbstractArray{Float64,N},meta::Any,summaryFunc::Function=sum)
    period = rawImage["period"]
    FluorescentSerie(rawImage,rois,avg,meta,period,summaryFunc)
end

function FluorescentSerie{T<:Number,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},meta::Any,summaryFunc::Function=sum)
    period = rawImage["period"]
    FluorescentSerie(rawImage,rois,meta,period,summaryFunc)
end

### Methods
length(fs::AbstractFluorescentSerie) = length(fs.timeframe)
size(fs::AbstractFluorescentSerie) = size(fs.raw)


typealias RealIndex{T<:Real} Union{T, AbstractVector{T}, Colon}
## GetIndex
## One,one
function getindex(fs::FluorescentSerie,n::RealIndex,ro::RealIndex)
    FluorescentSerie(getindex(fs.raw,n,ro),getindex(fs.timeframe,n),fs.rois[ro],fs.avg,fs.meta)
end

function getindex(fs::FluorescentSerie,n::Real,ro::RealIndex)
    FluorescentSerie(getindex(fs.raw,n:n,ro),getindex(fs.timeframe,n:n),fs.rois[ro],fs.avg,fs.meta)
end

function getindex(fs::FluorescentSerie,n::Real,ro::Real)
    FluorescentSerie(getindex(fs.raw,n:n,ro:ro),getindex(fs.timeframe,n:n),fs.rois[ro:ro],fs.avg,fs.meta)
end

function getindex(fs::FluorescentSerie,n::RealIndex,ro::Real)
    FluorescentSerie(getindex(fs.raw,n,ro:ro),getindex(fs.timeframe,n),fs.rois[ro:ro],fs.avg,fs.meta)
end


## In case only one column is present.
function getindex(fs::FluorescentSerie,n::RealIndex)
    size(fs)[2] != 1 ? error("Dimension mismatch - serie has more than one ROI."):
    FluorescentSerie(getindex(fs.raw,n,:),getindex(fs.timeframe,n),fs.rois,fs.avg,fs.meta)
end

function getindex(fs::FluorescentSerie,n::Real)
    size(fs)[2] != 1 ? error("Dimension mismatch - serie has more than one ROI."):
    FluorescentSerie(getindex(fs.raw,n:n,:),getindex(fs.timeframe,n:n),fs.rois,fs.avg,fs.meta)
end

## BitArray


## SetIndex
function setindex!(fs::FluorescentSerie,X,n::RealIndex,ro::RealIndex)
    FluorescentSerie(setindex!(fs.raw,X,n,ro),fs.timeframe,fs.rois,fs.avg,fs.meta)
end

function setindex!(fs::FluorescentSerie,X,n::Real,ro::Real)
    FluorescentSerie(setindex!(fs.raw,X,n:n,ro:ro),fs.timeframe,fs.rois,fs.avg,fs.meta)
end

function setindex!(fs::FluorescentSerie,X,n::Real,ro::RealIndex)
    FluorescentSerie(setindex!(fs.raw,X,n:n,ro),fs.timeframe,fs.rois,fs.avg,fs.meta)
end

function setindex!(fs::FluorescentSerie,X,n::RealIndex,ro::Real)
    FluorescentSerie(setindex!(fs.raw,X,n,ro:ro),fs.timeframe,fs.rois,fs.avg,fs.meta)
end

function setindex!(fs::FluorescentSerie,X,n::RealIndex)
    size(fs)[2] != 1 ? error("Dimension mismatch - serie has more than one ROI."):
    FluorescentSerie(setindex!(fs.raw,X,n),fs.timeframe,fs.rois,fs.avg,fs.meta)
end

function setindex!(fs::FluorescentSerie,X,n::Real)
    size(fs)[2] != 1 ? error("Dimension mismatch - serie has more than one ROI."):
    FluorescentSerie(setindex!(fs.raw,X,n:n),fs.timeframe,fs.rois,fs.avg,fs.meta)
end

## Accessors
times(fs::FluorescentSerie) = fs.timeframe

fluo(fs::FluorescentSerie) = fs.raw

rois(fs::FluorescentSerie) = fs.rois

avgImage(fs::FluorescentSerie) = fs.avg

metadata(fs::FluorescentSerie) = fs.meta

## Concatenation 
function hcat(fs::FluorescentSerie...)
    any(x -> x.timeframe != fs[1].timeframe,fs) ? error("Can only concatenate ROI series with the same timebase."):
    avg = mean([x.avg for x in fs])
    FluorescentSerie(hcat([x.raw for x in fs]...),times(fs[1]),vcat([x.rois for x in fs]...),avg,(unique([x.meta for x in fs])...))
end

function vcat(fs::FluorescentSerie...)
    any(x -> x.rois != fs[1].rois,fs) ? error("Can only concatenate if the series have the same ROIs"):
    timelags = cumsum([0;[x.timeframe[end] for x in fs][1:end-1]])
    timeframe = vcat([x.timeframe for x in fs] .+ timelags...)
    avg = mean([x.avg for x in fs])
    FluorescentSerie(vcat([x.raw for x in fs]...),timeframe,fs[1].rois,avg,(unique([x.meta for x in fs])...))
end

##
copy(fs::FluorescentSerie) = FluorescentSerie(copy(fs.raw),copy(fs.timeframe),copy(fs.rois),copy(fs.avg),fs.meta)


# - Plots.jl recipes
