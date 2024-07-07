using DelimitedFiles, Printf
import Base.show
import Base.zeros

struct Position
    x::Float64
    y::Float64
end

function distance(position1::Position, position2::Position)
    return sqrt((position1.x - position2.x)^2 + (position1.y - position2.y)^2)
end

function show(io::IO, position::Position)
    println(io, "Position: ($(position.x), $(position.y))")
end

struct ProcessingTime
    nominal::Int
    deviation::Int
end

nominal(processing_time::ProcessingTime) = processing_time.nominal
deviation(processing_time::ProcessingTime) = processing_time.deviation

function zeros(::Type{ProcessingTime}, n::Int, m::Int)
    return [ProcessingTime(0.0, 0.0) for _ = 1:n, _ = 1:m]
end

struct Job
    id::Int
    position::Position
    release_date::Int
    due_date::Int
end

id(job::Job) = job.id
release_date(job::Job) = job.release_date
due_date(job::Job) = job.due_date
distance(job1::Job, job2::Job) = distance(job1.position, job2.position)

function show(io::IO, job::Job)
    println(io, "Job: $(job.id)")
    println(io, "Position: $(job.position)")
    println(io, "Release Date: $(job.release_date)")
    println(io, "Due Date: $(job.due_date)")
end

struct Data
    n::Int
    budget::Int
    jobs::Vector{Job}
    processing_times::Matrix{ProcessingTime}
end

n(data::Data) = data.n
budget(data::Data) = data.budget
job(data::Data, i::Int) = data.jobs[i]
nominal_processing_time(data::Data, i::Int, j::Int) = nominal(data.processing_times[i, j])
deviation_processing_time(data::Data, i::Int, j::Int) =
    deviation(data.processing_times[i, j])

struct Params
    budget_factor::Float64
    dev_factor::Float64
end

budget_factor(params::Params) = params.budget_factor
dev_factor(params::Params) = params.dev_factor

struct Benchmark
    opt_cost::Int
    runtime_in_seconds::Float64
end

function show(io::IO, benchmark::Benchmark)
    @printf(io, "(%d, %.2f)", benchmark.opt_cost, benchmark.runtime_in_seconds)
end

function is_useful_line(line::String)
    line = replace(line, "\t" => " ")
    split_line = split(line, " ")
    split_line = filter(x -> x != "", split_line)
    return !isempty(split_line) && isdigit(split_line[1][1])
end

function read_input(input_file::String, params::Params)
    deviation_factor = dev_factor(params)
    match_result = match(r"n(\d+)w", input_file)[1]
    n = parse(Int, match_result)
    budget = floor(n * budget_factor(params))

    file = open(input_file, "r")
    lines = readlines(file)
    close(file)

    # Read Jobs data
    jobs = Job[]
    for line in lines
        if !is_useful_line(line)
            continue
        end

        line = replace(line, "\t" => " ")
        split_line = split(line, " ")
        split_line = filter(x -> x != "", split_line)
        id = parse(Int, split_line[1])

        if id == 1
            continue
        end

        if id > (n + 1)
            break
        end

        x = parse(Float64, split_line[2])
        y = parse(Float64, split_line[3])
        release_date = Int(parse(Float64, split_line[5]))
        due_date = Int(parse(Float64, split_line[6]))
        position = Position(x, y)

        push!(jobs, Job(id, position, release_date, due_date))
    end

    # Compute processing times
    processing_times = zeros(ProcessingTime, n, n)
    for i = 1:n
        for j = 1:n
            processing_time = distance(jobs[i], jobs[j])
            nominal = Int(floor(processing_time))
            deviation = Int(floor(nominal * deviation_factor))
            processing_times[i, j] = ProcessingTime(nominal, deviation)
        end
    end

    return Data(n, budget, jobs, processing_times)
end

get_jobs_sequence(data::Data, sequence::Vector{Int}) = [job(data, i) for i in sequence]

function get_release_dates(data::Data, sequence::Vector{Int})
    jobs = get_jobs_sequence(data, sequence)
    return [release_date(job) for job in jobs]
end

function get_due_dates(data::Data, sequence::Vector{Int})
    jobs = get_jobs_sequence(data, sequence)
    return [due_date(job) for job in jobs]
end

function get_nominal_processing_times(data::Data, sequence::Vector{Int})
    n = length(sequence)
    p̄ = [nominal_processing_time(data, sequence[i-1], sequence[i]) for i = 2:n]
    push!(p̄, nominal_processing_time(data, sequence[n], sequence[1]))
    return p̄
end

function get_deviation_processing_times(data::Data, sequence::Vector{Int})
    n = length(sequence)
    p̂ = [deviation_processing_time(data, sequence[i-1], sequence[i]) for i = 2:n]
    push!(p̂, deviation_processing_time(data, sequence[n], sequence[1]))
    return p̂
end
