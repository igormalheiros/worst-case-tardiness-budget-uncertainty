# Computing the worst-case total tardiness with budget uncertainty

This repository contains the implementations to compute the worst-case total tardiness for a sequence of scheduled jobs with release and due dates with budget uncertainty. Two approaches are implemented. The first one is based on a polynomial-time algorithm proposed by [Malheiros et al. 2024](https://hal.science/hal-04351032/file/main.pdf). The second is based on a Mixed-Integer-Linear Programming (MILP) formulation and uses the CPLEX solver (another solver can be easily replaced with the JuMP interface). 

# Instances

The instances to test them come from the traveling salesperson problem with time windows [Dumas et al. 1995](https://doi.org/10.1287/opre.43.2.367). We use the Euclidian distances among the jobs as the nominal processing time. Specifically, for a sequence `[1, 2, 3, 4]` the nominal processing times are: `[dist(1, 2), dist(2, 3), dist(3, 4), dist(4, 1)]`.

# Running the algorithms

Recommended requirements:

- Julia 1.9
- JuMP v1.18.1
- CPLEX 22.1.1 (you can replace it with another one that you have in your machine)

Every run builds a random sequence of jobs based on the instance and evaluates using both approaches.

```
julia test.jl instance_name budget_factor deviation_factor n_exp
```

Where `instance_name` is the path to the instance file, `budget_factor` is the percentual budget of maximum deviated processing times, `deviation_factor` is the additional deviation to the nominal processing time, and `n_exp` is the total number of experiments using the configuration of same (`instance_name`, `budget_factor`, `deviation_factor`).

The output is in the form:

```
instance_name budget_factor deviation_factor dp_runtime milp_runtime
```

Where `dp_runtime` and `milp_runtime` are the geometric mean time in seconds taken to solve `n_exp` random sequences of the same configuration (`instance_name`, `budget_factor`, `deviation_factor`) for the dynamic programming and MILP algorithms respectively.

# References

**The instances**: Y. Dumas, J. Desrosiers, É. Gélinas, M. M. Solomon, An optimal algorithm for the traveling salesman problem with time windows, Oper. Res. 43 (1995) 367–371. URL: https://doi.org/10.1287/opre.43.2.367. doi:10.1287/OPRE.43.2.367

**The algorithms**: I. Malheiros, A. Pessoa, M. Poss, A. Subramanian, Computing the worst-case due dates violations with
budget uncertainty.

# License

[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen)](./LICENSE)

This project is licensed under the [MIT License](./LICENSE).