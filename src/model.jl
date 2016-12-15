export Model, back!, update!, param

# Basic model API

abstract Model

back!(m::Model, Δ) = error("Backprop not implemented for $(typeof(m))")
update!(m, η) = m

graph(m) = nothing

# Model parameters

type Param{T}
  x::T
  Δx::T
end

param(x) = Param(x, zero(x))

state(p::Param) = p.x

function accumulate!(p::Param, Δ)
  p.Δx .+= Δ
  return p
end

function update!(p::Param, η)
  p.x .-= p.Δx .* η
  p.Δx[:] = 0
  return p
end

state(x) = x
accumulate!(x, Δ) = x

@forward Param.x Base.size

function Base.show(io::IO, p::Param)
  print(io, "Param", size(p.x))
end

# Anonymous models

export Capacitor

type Capacitor <: Model
  graph::IVertex{Any}
end

(m::Capacitor)(xs...) = interpret(reifyparams(m.graph), xs...)

graph(cap::Capacitor) = cap.graph
