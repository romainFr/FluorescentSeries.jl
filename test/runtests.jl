using FluorescentSeries
using Base.Test

# write your own tests here
@test 1 == 1
myFs = FluorescentSerie(ones(20,3),collect(1.0:20.0),Array{Int64,1}[[1;4;3],[2;8;9],[3;10;34;]],zeros(5,5))
