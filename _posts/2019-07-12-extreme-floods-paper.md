---
layout: post
title: Johannesson et al "Approximate Bayesian inference for spatial flood frequency analysis"
category: publication
---

Árni V. Johannesson, Birgir Hrafnkelsson, Raphaël Huser, Haakon Bakka, Stefan 
Siegert (2019). **Approximate Bayesian inference for spatial flood frequency 
analysis.** arXiv preprint 1907.04763 (submitted to Extremes)

- [arXiv link](https://arxiv.org/abs/1907.04763)

**Abstract**

Extreme floods cause casualties, widespread property damage, and damage to 
vital civil infrastructure. Predictions of extreme floods within gauged and 
ungauged catchments is crucial to mitigate these disasters. A Bayesian 
framework is proposed for predicting extreme floods using the generalized 
extreme-value (GEV) distribution. The methodological challenges consist of 
choosing a suitable parametrization for the GEV distribution when multiple 
covariates and/or latent spatial effects are involved, balancing model 
complexity and parsimony using an appropriate model selection procedure, and 
making inference based on a reliable and computationally efficient approach. We 
propose a latent Gaussian model with a novel multivariate link function for the 
location, scale and shape parameters of the GEV distribution. This link 
function is designed to separate the interpretation of the parameters at the 
latent level and to avoid unreasonable estimates of the shape parameter. 
Structured additive regression models are proposed for the three parameters at 
the latent level. Each of these regression models contains fixed linear effects 
for catchment descriptors. Spatial model components are added to the two first 
latent regression models, to model the residual spatial structure unexplained 
by the catchment descriptors. To achieve computational efficiency for large 
datasets with these richly parametrized models, we exploit a Gaussian-based 
approximation to the posterior density. This approximation relies on site-wise 
estimates, but, contrary to typical plug-in approaches, the uncertainty in 
these initial estimates is properly propagated through to the final posterior 
computations. We applied the proposed modeling and inference framework to 
annual peak river flow data from 554 catchments across the United Kingdom. The 
framework performed well in terms of flood predictions for ungauged catchments. 


