## Math

(+)(fs::FluorescentSerie,n::Number) = fs .+ n

(+)(n::Number,fs::FluorescentSerie) = n .+ fs
  
(+)(fs::FluorescentSerie,n::AbstractArray) = fs .+ n

(+)(n::AbstractArray,fs::FluorescentSerie) = n .+ fs 

function (.+)(fs::FluorescentSerie,n::Number)
    fs.raw = fs.raw .+ n
    fs
end

function (.+)(n::Number,fs::FluorescentSerie)
    fs.raw = fs.raw .+ n
    fs
end

function (.+)(fs::FluorescentSerie,n::AbstractArray)
    fs.raw = fs.raw .+ n
    fs
end

function (.+)(n::AbstractArray,fs::FluorescentSerie)
    fs.raw = fs.raw .+ n
    fs
end

(-)(fs::FluorescentSerie,n::Number) = fs .- n

(-)(n::Number,fs::FluorescentSerie) = n .- fs
  
(-)(fs::FluorescentSerie,n::AbstractArray) = fs .- n

(-)(n::AbstractArray,fs::FluorescentSerie) = n .- fs 

function (.-)(fs::FluorescentSerie,n::Number)
    fs.raw = fs.raw .- n
    fs
end

function (.-)(n::Number,fs::FluorescentSerie)
    fs.raw = fs.raw .- n
    fs
end

function (.-)(fs::FluorescentSerie,n::AbstractArray)
    fs.raw = fs.raw .- n
    fs
end

function (.-)(n::AbstractArray,fs::FluorescentSerie)
    fs.raw = fs.raw .- n
    fs
end

(*)(fs::FluorescentSerie,n::Number) = fs .* n

(*)(n::Number,fs::FluorescentSerie) = n .* fs
  
(*)(fs::FluorescentSerie,n::AbstractArray) = fs .* n

(*)(n::AbstractArray,fs::FluorescentSerie) = n .* fs 

function (.*)(fs::FluorescentSerie,n::Number)
    fs.raw = fs.raw .* n
    fs
end

function (.*)(n::Number,fs::FluorescentSerie)
    fs.raw = fs.raw .* n
    fs
end

function (.*)(fs::FluorescentSerie,n::AbstractArray)
    fs.raw = fs.raw .* n
    fs
end

function (.*)(n::AbstractArray,fs::FluorescentSerie)
    fs.raw = fs.raw .* n
    fs
end

(/)(fs::FluorescentSerie,n::Number) = fs ./ n

(/)(n::Number,fs::FluorescentSerie) = n ./ fs
  
(/)(fs::FluorescentSerie,n::AbstractArray) = fs ./ n

(/)(n::AbstractArray,fs::FluorescentSerie) = n ./ fs 

function (./)(fs::FluorescentSerie,n::Number)
    fs.raw = fs.raw ./ n
    fs
end

function (./)(n::Number,fs::FluorescentSerie)
    fs.raw = fs.raw ./ n
    fs
end

function (./)(fs::FluorescentSerie,n::AbstractArray)
    fs.raw = fs.raw ./ n
    fs
end

function (./)(n::AbstractArray,fs::FluorescentSerie)
    fs.raw = fs.raw ./ n
    fs
end

function (.^)(fs::FluorescentSerie,n::Number)
    fs.raw = fs.raw .^ n
    fs
end

function (.^)(fs::FluorescentSerie,n::AbstractArray)
    fs.raw = fs.raw .^ n
    fs
end

for func in (:sin,:cos,:tan,:asin,:acos,:atan,:sinh,:cosh,:tanh,:asinh,:acosh,
             :atanh,:exp,:log,:log2,:log10,:sqrt,:lgamma,:log1p,:erf,:erfc)
    @eval begin
        $func(fs::FluorescentSerie) = function(fs::FluorescentSerie)
            fs.raw = $func(fs.raw)
            fs
        end
    end
end

## Quantile, useful for baseline calculations
function quantile(fs::FluorescentSerie,p)
    results = Array{Float64}(size(fs)[2])
    for i in 1:size(fs)[2]
        results[i] = quantile(fs.raw[:,i],p)
    end
    results
end

## DeltaF/F
function deltaFF!(fs::FluorescentSerie,Fo::Array{Float64,1},B::Float64=0.0)
    length(Fo) != size(fs)[2] ? error("Fo vector should be the same length as the number of ROIs in the series."):
    for i in eachindex(Fo)
        fs[i:i,:] = (fs[i:i,:] .- Fo[i])./(Fo[i]-B)
    end
    fs
end

deltaFF(fs::FluorescentSerie,Fo::Array{Float64,1},B::Float64=0.0) = deltaFF!(copy(fs),Fo,B)
