struct ApproxFunProblem{P,S} <: DEProblem
    prob::P
    space::S
end

function ApproxFunProblem(prob;n = ncoefficients(prob.u0))
  sp = space(prob.u0)
  _prob = ODEProblem((t,u)->pad!(prob.f(t,Fun(sp,u)).coefficients,n),pad!(prob.u0.coefficients,n),prob.tspan)
  return ApproxFunProblem(_prob,sp)
end

struct ApproxFunSolution{SOL,S}
    sol::SOL
    space::S
end

(sol::ApproxFunSolution)(t) = Fun(sol.space,sol.sol(t))
(sol::ApproxFunSolution)(t,x) = sol(t)(x)

@inline Base.getindex(sol::ApproxFunSolution, I::Int...) = Fun(sol.space,sol.sol[I[end]])[Base.front(I)...]
@inline Base.getindex(sol::ApproxFunSolution, I::Int) = Fun(sol.space,sol.sol[I])
@inline Base.getindex(sol::ApproxFunSolution, I::Colon) = Fun.(sol.space,sol.sol[I])
@inline Base.getindex(sol::ApproxFunSolution, I::AbstractArray{Int}) = Fun.(sol.space,sol.sol[I])

@inline Base.length(sol::ApproxFunSolution) = length(sol.sol)
@inline function Base.endof(sol::ApproxFunSolution)
    endof(sol.sol)
end
@inline Base.size(sol::ApproxFunSolution) = size(sol.sol)
@inline Base.eachindex(sol::ApproxFunSolution) = Base.OneTo(length(sol.u))

function DiffEqBase.init(prob::ApproxFunProblem,alg,args...;kwargs...)
    init(prob.prob,alg,args...;kwargs...)
end
function DiffEqBase.solve(prob::ApproxFunProblem,alg,args...;kwargs...)
    sol = solve(prob.prob,alg,args...;kwargs...)
    ApproxFunSolution(sol,prob.space)
end

function Base.show(io::IO, A::ApproxFunProblem)
  print(io,"Problem: ")
  show(io,A.prob)
  println(io)
  print(io,"Space: ")
  show(io, A.space)
end
