## DeltaF/F
function deltaFF(fs::AxisArray,Fo::Array{Float64,1},B::Float64=0.0)
    length(Fo) != size(fs)[2] ? error("Fo vector should be the same length as the number of ROIs in the series."):
    Fo = Fo.'
    newF = (fs .- Fo)./(Fo-B)
    AxisArray(newF,axes(fs)...)
end
