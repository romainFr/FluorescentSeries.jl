

## Add tests for time dim being the last one ?
# Constructing from a ROI image and the raw data
#function FluorescentSerie{T,N,N2}(rawImage::AbstractArray{T,N2},roiIm::AbstractArray{Int64,N},period::Float64,summaryFunc::Function=sum)
    #Images.assert_time_dim_last(rawImage)
#    N2 != (N+1) ? error("Rois should have one less dimension than the raw data"):
#    size(rawImage)[1:N] != size(roiIm) ? error("ROI image has a different size than the data"):
#    nt = size(rawImage)[N2]
#    results = zeros(nt,maximum(roiIm))
#    rois = Array{Array{Int64,1},1}(maximum(roiIm))
#    for i in 1:maximum(roiIm)
#        for j in 1:nt
#            rois[i] = find(roiIm.==i)
#            results[j,i] = summaryFunc(slicedim(rawImage,N2,j)[rois[i]])
#        end
#    end
#    timeframe = range(0,period,nt)
#    
#    AxisArray(results,Axis{:time}(timeframe),Axis{:ROI}(1:length(rois)))
#end



#function FluorescentSerie{T,N}(rawImage::AbstractArray{T,N},rois::Array{Array{Int64,1},1},period::Float64,summaryFunc::Function=sum)
#    nt = nimages(rawImage)
#    results = zeros(nt,length(rois))
#    for i in eachindex(rois)
#        for j in 1:nt
#            results[j,i] = summaryFunc(slicedim(rawImage,N,j)[rois[i]])
#        end
#    end
#    timeframe = collect(range(0,period,nt))
#    
#    AxisArray(results,Axis{:time}(timeframe),Axis{:ROI}(1:length(rois)))
#end

#function FluorescentSerie{T,N,N2}(rawImage::AbstractArray{T,N2},rois::AbstractArray{Int64,N},summaryFunc::Function=sum)
#    period = rawImage["period"]
#    FluorescentSerie(rawImage,rois,period,summaryFunc)
#end







## If Rois are given as an array of indices
function FluorescentSerie(img::AxisArray,rois::Array{Array{Int64,1},1},summaryFunc::Function=sum)
    nt = nimages(img)
    ax = timeaxis(img)
    results = zeros(nt,length(rois))
    for i in eachindex(rois)
        for j in 1:nt
            results[j,i] = summaryFunc(img[ax(j)][rois[i]])
        end
    end
    AxisArray(results,ax,Axis{:ROI}(1:length(rois)))
end

# Constructing from a ROI image and the raw data
function FluorescentSerie(rawImage::AxisArray,roiIm::AbstractArray{Int64},summaryFunc::Function=sum)
    size_spatial(rawImage) != size(roiIm) ? error("ROI image has a different size than the data"):
    rois = Array{Array{Int64,1},1}(maximum(roiIm))
    for i in 1:maximum(roiIm)
        rois[i] = find(roiIm.==i)
    end
    FluorescentSerie(rawImage,rois,summaryFunc)
end
