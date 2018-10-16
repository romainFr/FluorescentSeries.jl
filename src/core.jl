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
    size_spatial(rawImage) != size(roiIm) ? error("ROI image has a different size than the data") :
    rois = Array{Array{Int64,1},1}(maximum(roiIm))
    for i in 1:maximum(roiIm)
        rois[i] = LinearIndices(findall(roiIm.==i))
    end
    FluorescentSerie(rawImage,rois,summaryFunc)
end

# Constructing from an Array and  associated metadata
function FluorescentSerie(img::AbstractArray,metadata::Dict,rois::Array{Array{CartesianIndex{3},1},1},summaryFunc::Function=sum)
    
    framesPerTrial = metadata["framesPerTrial"]
    nMax = maximum(framesPerTrial)
    results = zeros(Float64,(nMax,length(rois),length(framesPerTrial)))
    ax = range(0,step=metadata["samplingTime"],length=nMax)
    for i in eachindex(rois)
        startPoint = 0
        roiIm = img[rois[i],:]
        for t in 1:length(framesPerTrial)
            nt = framesPerTrial[t]
            for j in 1:nt
                results[j,i,t] = summaryFunc(roiIm[:,startPoint+j])
            end
            startPoint+=nt
        end
    end
    AxisArray(results,Axis{:time}(ax),Axis{:ROI}(1:length(rois)),Axis{:trial}(1:length(framesPerTrial)))
end


function FluorescentSerie(rawImage::AbstractArray,metadata::Dict,roiIm::AbstractArray{Int64},summaryFunc::Function=sum)
    size(rawImage)[1:3] != size(roiIm)[1:3] ? error("ROI image has a different size than the data") :
    rois = Array{Array{CartesianIndex{3},1},1}(undef,maximum(roiIm))
    for i in 1:maximum(roiIm)
        rois[i] = findall(roiIm[:,:,:,1].==i)
    end
    FluorescentSerie(rawImage,metadata,rois,summaryFunc)
end
