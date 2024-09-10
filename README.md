# Computing the worst-case total tardiness with budget uncertainty

Let a set of $n$ jobs scheduled in the order $[n]=\{1,2,\ldots,n\}$. For each job, we are given a release date $r_i$, a due date $d_i$, a nominal processing time $\bar{p}_i$ and a deviation $\hat{p}_i$. The actual processing time of job $i$ is given by $\bar{p}_i + \delta_i \hat{p}_i$, where $\delta_i \in \\{0,1\\}$ is a binary optimization variable that satisfies the constraint 

$$\sum_{i \in [n]} \delta_i \leq \Gamma,$$

for a given positive integer $\Gamma$. This repository contains implementations to compute the vector $\delta$ that maximizes the total tardiness. Two approaches are implemented. The first one is based on a polynomial-time algorithm proposed by [Malheiros et al. 2024](https://doi.org/10.1016/j.orl.2024.107148). The second is based on a Mixed-Integer-Linear Programming (MILP) formulation and uses the CPLEX solver (another solver can be easily replaced with the JuMP interface). 

# Instances

The instances to test them come from the traveling salesperson problem with time windows [Dumas et al. 1995](https://doi.org/10.1287/opre.43.2.367). We use the Euclidian distances among the jobs as the nominal processing time. For, for a sequence `[1, 2, 3, 4]` the nominal processing times are: `[dist(1, 2), dist(2, 3), dist(3, 4), dist(4, 1)]`.

# Running the algorithms

Recommended requirements:

- Julia 1.9
- JuMP v1.18.1
- CPLEX 22.1.1 (you can replace it with another one that you have in your machine)

Every run builds a random sequence of jobs based on the instance and evaluates it using both approaches.

```
julia test.jl instance_name budget_factor deviation_factor n_exp
```

The `instance_name` is the path to the instance file, the `budget_factor` represents the budget for the maximum deviated processing times as a percentage of the total number of jobs, the `deviation_factor` represents the additional deviation applied to the nominal processing time as a percentage, and the `n_exp` is the total number of experiments conducted using the same configuration (`instance_name`, `budget_factor`, `deviation_factor`).

The output is in the form:

```
instance_name budget_factor deviation_factor dp_runtime milp_runtime
```

The `dp_runtime` and the `milp_runtime` are the geometric mean time in seconds taken to solve `n_exp` random sequences of the same configuration (`instance_name`, `budget_factor`, `deviation_factor`) for the dynamic programming and MILP algorithms respectively.

# References

**The instances**: Y. Dumas, J. Desrosiers, É. Gélinas, M. M. Solomon, An optimal algorithm for the traveling salesman problem with time windows, Oper. Res. 43 (1995) 367–371. URL: https://doi.org/10.1287/opre.43.2.367. doi:10.1287/OPRE.43.2.367

**The algorithms**: I. Malheiros, A. Pessoa, M. Poss, A. Subramanian, Computing the worst-case due dates violations with budget uncertainty, Operations Research Letters. 56 (2024) 107148. URL: https://doi.org/10.1016/j.orl.2024.107148

# License

[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen)](./LICENSE)

This project is licensed under the [MIT License](./LICENSE).
