module PcgRandom

export Pcg64Random

import Random: Random, AbstractRNG, SamplerType, SamplerUnion, seed!

"""
PCG64 member of the PCG family.

pcg64 = pcg_engines::setseq_xsl_rr_128_64
"""
mutable struct Pcg64Random <: AbstractRNG
    s::UInt128
    const i::UInt128
end

@inline function Pcg64Random(seed=nothing; increment::Integer=PCG64_INCREMENT,
    stream::Union{<:Integer,Nothing}=nothing)
    if isnothing(stream)
        seed!(Pcg64Random(0, increment), seed)
    elseif typeof(stream) <: Unsigned
        seed!(Pcg64Random(0, ((UInt128(stream) << 1) | 1)), seed)
    else
        seed!(Pcg64Random(0, ((unsigned(Int128(stream)) << 1) | 1)), seed)
    end
end


const PCG64_MULTIPLIER = 0x2360ed051fc65da44385df649fccf645
const PCG64_INCREMENT = 0x5851f42d4c957f2d14057b7ef767814f

_bump(s::UInt128, i::UInt128) = s * PCG64_MULTIPLIER + i


Random.rng_native_52(::Pcg64Random) = UInt64

@inline function Random.rand(r::Pcg64Random, ::SamplerType{UInt64})
    s = _bump(r.s, r.i)
    res = bitrotate(xor(s % UInt64, UInt64(s >> 64)), -Int(s >> 122))
    r.s = s
    return res
end

@inline function Random.rand(r::Pcg64Random, T::SamplerUnion(Bool,
    Int8, Int16, Int32, Int64, UInt8, UInt16, UInt32))
    S = T[]
    rand(r, UInt64) % S
end

@inline function Random.rand(r::Pcg64Random, ::SamplerType{UInt128})
    a = rand(r, UInt64)
    b = rand(r, UInt64)
    UInt128(a) << 64 + b
end

@inline Random.rand(r::Pcg64Random, ::SamplerType{Int128}) =
    rand(r, UInt128) % Int128

Random.seed!(r::Pcg64Random, ::Nothing) = seed!(r, rand(UInt128))
Random.seed!(r::Pcg64Random, seed::Signed) = seed!(r, unsigned(Int128(seed)))
Random.seed!(r::Pcg64Random, seed::Unsigned) = seed!(r, UInt128(seed))

@inline function Random.seed!(r::Pcg64Random, seed::UInt128)
    r.s = _bump(seed + r.i, r.i)
    return r
end


advance!(r::Pcg64Random, delta::Integer) =
    advance!(r, unsigned(Int128(delta)))

function advance!(r::Pcg64Random, delta::UInt128)
    cur_mult = PCG64_MULTIPLIER
    cur_plus = r.i
    acc_mult = UInt128(1)
    acc_plus = UInt128(0)
    while delta > 0
       if isodd(delta)
          acc_mult *= cur_mult
          acc_plus = acc_plus * cur_mult + cur_plus
       end
       cur_plus = (cur_mult + 1) * cur_plus
       cur_mult *= cur_mult
       delta >>>= 1;
    end
    r.s = acc_mult * r.s + acc_plus
    nothing
end


backstep!(r::Pcg64Random, delta::Integer) = advance!(r, -delta)

end
