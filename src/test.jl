include("data.jl")
include("algorithms.jl")

using Random, Statistics, StatsBase, Printf

function generate_rnd_squence(n::Int)
    return shuffle(1:n)
end

function is_equal(a::Benchmark, b::Benchmark)
    return abs(a.opt_cost - b.opt_cost) < 1e-4
end

function warmpup(input_file::String, budget_factor::Float64, dev_factor::Float64)
    params = Params(budget_factor, dev_factor)
    data = read_input(input_file, params)
    for exp = 1:3
        Random.seed!(exp)
        sequence = generate_rnd_squence(data.n)
        benchmark_dp = solve_DP(data, sequence)
        benchmark_milp = solve_MILP(data, sequence)
    end
end

function run(
    input_file::String,
    budget_factor::Float64,
    dev_factor::Float64,
    EXPERIMENTS::Int,
    warmup::Bool = false,
)
    params = Params(budget_factor, dev_factor)
    data = read_input(input_file, params)
    benchmarks_MILP = Benchmark[]
    benchmarks_DP = Benchmark[]
    instance_name = string(split(input_file, "/")[end])

    if warmup
        warmpup(input_file, budget_factor, dev_factor)
    end

    cnt = 0
    for exp = 1:EXPERIMENTS
        Random.seed!(exp)
        sequence = generate_rnd_squence(data.n)

        benchmark_dp = solve_DP(data, sequence)
        benchmark_milp = solve_MILP(data, sequence)

        if !is_equal(benchmark_dp, benchmark_milp)
            println("Different optimal costs!")
            println("DP:\n", benchmark_dp)
            println("MILP:\n", benchmark_milp)
            @show sequence
            cnt += 1
        else
            push!(benchmarks_MILP, benchmark_milp)
            push!(benchmarks_DP, benchmark_dp)
        end
    end
    dp_avg_runtime = geomean([b.runtime_in_seconds for b in benchmarks_DP]) # geometric mean
    milp_avg_runtime = geomean([b.runtime_in_seconds for b in benchmarks_MILP]) # geometric mean
    @printf(
        "%s %.2f %.2f %.6f %.6f\n",
        instance_name,
        budget_factor,
        dev_factor,
        dp_avg_runtime,
        milp_avg_runtime
    )
    return cnt
end

if length(ARGS) != 4
    println("Invalid number of arguments!")
    println(
        "Usage: julia test.jl <input_file> <budget_factor> <deviation_factor> <experiments>",
    )
    exit(1)
end

run(ARGS[1], parse(Float64, ARGS[2]), parse(Float64, ARGS[3]), parse(Int, ARGS[4]))
