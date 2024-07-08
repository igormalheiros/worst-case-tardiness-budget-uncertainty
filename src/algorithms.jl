using JuMP, Test, CPLEX
import MathOptInterface

function solve_DP(data::Data, sequence::Vector{Int})
    n = length(sequence)
    Γ = data.budget
    r = get_release_dates(data, sequence)
    d = get_due_dates(data, sequence)
    p̄ = get_nominal_processing_times(data, sequence)
    p̂ = get_deviation_processing_times(data, sequence)

    function p(i::Int, γ::Int)
        return p̄[i] + γ * p̂[i]
    end

    elapsed_time = @elapsed begin
        F = fill(-Inf, n, Γ + 1, n + 2)
        d_1 = d[1]
        r_1 = r[1]
        p̄_1 = p̄[1]
        p̂_1 = p̂[1]

        for β = 0:n
            F[1, 1, β+1] = max(0.0, r_1 + p̄_1 - d_1) + β * (r_1 + p̄_1)
            F[1, 2, β+1] = max(0.0, r_1 + p̄_1 + p̂_1 - d_1) + β * (r_1 + p̄_1 + p̂_1)
        end

        for i = 2:n
            r_i = r[i]
            d_i = d[i]
            p̄_i = p̄[i]
            p̂_i = p̂[i]
            prec_i = i - 1
            for γ = 0:min(Γ, i)
                γ_idx = γ + 1
                for β = 0:n
                    β_idx = β + 1
                    max_val = -Inf

                    for δ = 0:1
                        if δ == 1 && γ == 0
                            continue
                        end

                        p = (p̄_i + δ * p̂_i)

                        max_val = max(
                            F[prec_i, γ_idx-δ, β_idx+1] + (β + 1) * p - d_i,
                            F[prec_i, γ_idx-δ, 1] + (β + 1) * r_i + (β + 1) * p - d_i,
                            F[prec_i, γ_idx-δ, β_idx] + β * p,
                            F[prec_i, γ_idx-δ, 1] + (β) * r_i + β * p,
                            max_val,
                        )
                    end
                    F[i, γ_idx, β_idx] = max_val
                end
            end
        end
    end
    return Benchmark(F[n, Γ+1, 1], elapsed_time)
end

function solve_MILP(data::Data, sequence::Vector{Int})
    n = length(sequence)
    Γ = data.budget
    r = get_release_dates(data, sequence)
    d = get_due_dates(data, sequence)
    p̄ = get_nominal_processing_times(data, sequence)
    p̂ = get_deviation_processing_times(data, sequence)

    elapsed_time = @elapsed begin
        Ā = Int[]
        for i = 1:n
            push!(Ā, max(r[i], i == 1 ? 0 : Ā[i-1]) + p̄[i] + p̂[i])
        end
        M1 = [d[i] - (r[i] + p̄[i]) for i = 1:n]
        M2 = [(Ā[i] - d[i]) for i = 1:n]
        M3 = [(Ā[i] - r[i]) for i = 1:n]
        M4 = [i == 1 ? 0 : (r[i] - (r[i-1] + p̄[i-1])) for i = 1:n]

        model = Model(CPLEX.Optimizer; add_bridges = false)
        JuMP.set_silent(model)
        set_optimizer_attribute(model, "CPX_PARAM_THREADS", 1)
        set_attribute(model, "CPX_PARAM_EPGAP", 1e-6)

        @variable(model, τ[1:n] >= 0)
        @variable(model, t[1:n] >= 0)
        @variable(model, δ[1:n], Bin)
        @variable(model, u[1:n], Bin)
        @variable(model, v[1:n], Bin)

        @objective(model, Max, (sum(τ[i] for i = 1:n)))

        @constraint(model, t[1] == r[1] + p̄[1] + δ[1] * p̂[1])
        @constraint(model, [i = 1:n], τ[i] <= (t[i] - d[i]) + M1[i] * (1 - u[i]))
        @constraint(model, [i = 1:n], τ[i] <= M2[i] * u[i])
        @constraint(model, [i = 1:n], τ[i] >= t[i] - d[i])
        @constraint(
            model,
            [i = 2:n],
            t[i] <= r[i] + M3[i] * (1 - v[i]) + p̄[i] + δ[i] * p̂[i]
        )
        @constraint(model, [i = 2:n], t[i] <= t[i-1] + M4[i] * v[i] + p̄[i] + δ[i] * p̂[i])
        @constraint(model, [i = 2:n], t[i] >= t[i-1] + p̄[i] + δ[i] * p̂[i])
        @constraint(model, [i = 2:n], t[i] >= r[i] + p̄[i] + δ[i] * p̂[i])

        @constraint(model, sum(δ[i] for i = 1:n) <= Γ)

        JuMP.optimize!(model)
    end

    return Benchmark(Int(round(JuMP.objective_value(model))), elapsed_time)
end
