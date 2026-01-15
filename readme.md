PCG Pseudorandom Number Generator
==
A minimal PCG implementation. For a full-featured PCG, see
[RandomNumbers.jl](https://github.com/JuliaRandom/RandomNumbers.jl).

[![standwithukraine](docs/StandWithUkraine.svg)](https://ukrainewar.carrd.co/)


Usage
--

```julia
using PcgRandom

rng = Pcg64Random(42)
dice = rand(rng, 1:20)
```


Installation
--

```julia-repl
julia> ]
pkg> add https://github.com/paiv/pcg64-julia
```
