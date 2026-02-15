# Airfoil Shape Optimisation using PSO (Folder B)

![Project Status](https://img.shields.io/badge/status-active-brightgreen)
![Language](https://img.shields.io/badge/language-MATLAB-blue)
![License](https://img.shields.io/badge/license-MIT-green)

This project focuses on **direct aerodynamic shape optimisation** of airfoils using **Particle Swarm Optimisation (PSO)** coupled with the **XFOIL** solver. The goal is to maximize the Lift-to-Drag ratio ($L/D$) while adhering to geometric and stability constraints.

## Table of Contents

- [Project Overview](#project-overview)
- [Mathematical Formulation](#mathematical-formulation)
- [Airfoil Parameterisation (CST)](#airfoil-parameterisation-cst)
- [Optimisation Algorithms](#optimisation-algorithms)
- [Software Architecture](#software-architecture)
- [Installation & Usage](#installation--usage)
- [Results & Performance](#results--performance)
- [Visual Outputs](#visual-outputs)

---

## Project Overview

This module implements a numerical optimisation loop where:
1.  **PSO** generates candidate airfoil shapes defined by CST parameters.
2.  **CST** constructs the airfoil coordinates from the design variables.
3.  **XFOIL** evaluates the aerodynamic performance ($C_l, C_d$) of each candidate.
4.  The loop iterates to minimize the objective function (maximize efficiency).

**Key Features:**
-   Stochastic global search (PSO).
-   Robust handling of XFOIL convergence failures via penalty functions.
-   Geometric constraints for feasible manufacturing.

---

## Mathematical Formulation

The optimisation problem is formally defined as:

$$
\begin{aligned}
& \text{minimize} & & f(\mathbf{x}) = \frac{C_d}{C_l} + P(\mathbf{x}) \\
& \text{subject to} & & \mathbf{x} \in [\mathbf{x}_{lb}, \mathbf{x}_{ub}] \\
& & & g_1(\mathbf{x}) : t_{max} \geq 0.10c \\
& & & g_2(\mathbf{x}) : W_u > W_l \quad \text{(Geometric Validity)} \\
& & & g_3(\mathbf{x}) : \text{Aerodynamic Convergence (XFOIL)}
\end{aligned}
$$

Where:
-   $\mathbf{x}$ is the vector of **6 CST weights** (3 Upper, 3 Lower).
-   $P(\mathbf{x})$ is a penalty function ($f=100$) applied if constraints are violated or XFOIL crashes.

---

## Airfoil Parameterisation (CST)

The Class-Shape Transformation (CST) method is used to represent the airfoil geometry.
$$
y(x) = C(x) \cdot S(x) + x \cdot \Delta z_{te}
$$
-   **Class Function:** $C(x) = x^{0.5} (1-x)^{1.0}$ (Round nose, sharp tail).
-   **Shape Function:** Using 3rd order Bernstein Polynomials, resulting in **6 design variables** (weights).

---

## Optimisation Algorithms

### Particle Swarm Optimisation (PSO)
The core algorithm is a custom PSO implementation designed for the noisy XFOIL objective landscape.

**Update Equations:**
$$
v_{i}^{t+1} = w v_{i}^{t} + c_1 r_1 (p_{best,i} - x_{i}^{t}) + c_2 r_2 (g_{best} - x_{i}^{t})
$$
$$
x_{i}^{t+1} = x_{i}^{t} + v_{i}^{t+1}
$$

**Parameter Study (`PSO_Parameter_Study.m`):**
A dedicated script compares different tuning strategies:
1.  **Baseline:** Balanced exploration/exploitation ($w=1.0 \to 0.4$, $c_1=2, c_2=2$).
2.  **Social:** High social component ($c_2=2.5$), fast convergence but risk of premature stagnation.
3.  **Independent:** High cognitive component ($c_1=2.5$), high diversity but slower convergence.

---

## Software Architecture

The implementation is contained entirely within **Folder B**:

| File | Description |
| :--- | :--- |
| `PSO_Airfoil_Optimisation.m` | **Main Entry Point.** Runs the full PSO optimisation, plots convergence in real-time, and saves results. |
| `PSO_Parameter_Study.m` | Conducts a parameter study to compare different PSO hyperparameter sets. |
| `CST_airfoil.m` | Generates airfoil coordinates $(x,y)$ from the 6 CST weights. |
| `createAirfoil.m` | Utility script to manually define CST weights and visualise the resulting airfoil shape. |
| `xfoil.m` | MATLAB wrapper that writes `airfoil.txt`, executes `run.bat`, and parses `out.txt`. |
| `run.bat` | Batch script to drive the `xfoil.exe` binary. |
| `PSO_XFOIL_Results.mat` | Stores the final optimised designs and history. |

---

## Installation & Usage

### Prerequisites
-   **MATLAB** with Optimization Toolbox.
-   **XFOIL** executable (`xfoil.exe`) must be present in the `B/` folder.
-   Windows Environment (due to `run.bat` dependency).

### 1. Run the Main Optimisation
To perform a single optimisation run with visualisation:
```matlab
cd B
PSO_Airfoil_Optimisation
```
*Output:* Real-time plots of $C_d/C_l$, Best $C_L$, Best $C_D$.

### 2. Run Parameter Study
To benchmark different PSO settings:
```matlab
cd B
PSO_Parameter_Study
```
*Output:* Comparison plot of convergence rates for different swarm behaviors.

---

## Results & Performance

Typical results obtained from `PSO_Airfoil_Optimisation`:
-   **Best Fitness ($C_d/C_l$):** ~0.0125 - 0.0130
-   **Evaluations:** 2000 (20 particles * 100 iterations)
-   **Runtime:** ~20-40 minutes (depending on XFOIL convergence speed).

### Visualisation
The script generates a dual-plot:
1.  **Top:** Convergence of the global best fitness (Objective Function).
2.  **Bottom:** Evolution of Lift ($C_L$) and Drag ($C_D$) coefficients for the best candidate.

---
