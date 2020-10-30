---
layout: post
title: Hrafnkelsson et al "Max-and-Smooth - A two-step approach for approximate Bayesian inference in latent Gaussian models"
category: publication
---

Birgir Hrafnkelsson, Stefan Siegert, Raphaël Huser, Haakon Bakka, Árni V. Jóhannesson, (2020). **Max-and-Smooth: a two-step approach for approximate Bayesian inference in latent Gaussian models.** Bayesian Analysis, [doi:10.1214/20-BA1219](https://dx.doi.org/10.1214/20-BA1219)

- [arXiv link](https://arxiv.org/abs/1907.11969)
- [journal link](https://dx.doi.org/10.1214/20-BA1219)


**Abstract**

With modern high-dimensional data, complex statistical models are necessary,
requiring computationally feasible inference schemes. We introduce
Max-and-Smooth, an approximate Bayesian inference scheme for a flexible class
of latent Gaussian models (LGMs) where one or more of the likelihood parameters
are modeled by latent additive Gaussian processes. Our proposed inference
scheme is a two-step approach. In the first step (Max), the likelihood function
is approximated by a Gaussian density with mean and covariance equal to either
(a) the maximum likelihood estimate and the inverse observed information,
respectively, or (b) the mean and covariance of the normalized likelihood
function. In the second step (Smooth), the latent parameters and
hyperparameters are inferred and smoothed with the approximated likelihood
function. The proposed method ensures that the uncertainty from the first step
is correctly propagated to the second step. Because the prior density for the
latent parameters is assumed to be Gaussian and the approximated likelihood
function is Gaussian, the approximate posterior density of the latent
parameters (conditional on the hyperparameters) is also Gaussian, thus
facilitating efficient posterior inference in high dimensions. Furthermore, the
approximate marginal posterior distribution of the hyperparameters is
tractable, and as a result, the hyperparameters can be sampled independently of
the latent parameters. We show that the computational cost of Max-and-Smooth is
close to being insensitive to the number of independent data replicates, and
that it scales well with increased dimension of the latent parameter vector
provided that its Gaussian prior density is specified with a sparse precision
matrix. In the case of a large number of independent data replicates, sparse
precision matrices, and high-dimensional latent vectors, the speedup is
substantial in comparison to an MCMC scheme that infers the posterior density
from the exact likelihood function. The accuracy of the Gaussian approximation
to the likelihood function increases with the number of data replicates per
latent model parameter. The proposed inference scheme is demonstrated on one
spatially referenced real dataset and on simulated data mimicking spatial,
temporal, and spatio-temporal inference problems. Our results show that
Max-and-Smooth is accurate and fast.



