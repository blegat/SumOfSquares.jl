using DynamicPolynomials
@polyvar x

poly = x^4 - 2x^2

using SumOfSquares

struct OnSign <: Certificate.OnMonomials end
using PermutationGroups
import SymbolicWedderburn
SymbolicWedderburn.coeff_type(::OnSign) = Float64
function SymbolicWedderburn.action(::OnSign, p::Permutation, mono::AbstractMonomial)
    if p.perm == perm"(1)(2)" || iseven(DynamicPolynomials.degree(mono))
        return 1 * mono
    else
        @assert p.perm == perm"(1,2)"
        return -1 * mono
    end
end
G = PermGroup([perm"(1,2)"])

import CSDP
solver = CSDP.Optimizer
model = Model(solver)
@variable(model, t)
@objective(model, Max, t)
certificate = Certificate.SymmetricIdeal(Certificate.MaxDegree(SOSCone(), MonomialBasis, maxdegree(poly)), G, OnSign())
con_ref = @constraint(model, poly - t in SOSCone(), ideal_certificate = certificate)
optimize!(model)
value(t)

gram_matrix(con_ref)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

