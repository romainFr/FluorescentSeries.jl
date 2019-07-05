## DeltaF/F
function deltaFF(fs::AxisArray,Fo::Array{Float64,1},B=0.0)
    length(Fo) != size(fs)[2] ? error("Fo vector should be the same length as the number of ROIs in the series.") :
    Fo = permutedims(Fo)
    newF = convert(Array{Union{Missing, Float64},3},((fs .- Fo)./(Fo .-B)))
    AxisArray(newF,AxisArrays.axes(fs)...)
end
