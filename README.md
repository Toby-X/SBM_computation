Official R and Stan implementation of the paper: 

**"Beyond Asymptotics: Practical Insights into Community Detection in Complex Networks"**

Installation
-------------

Auto installation is performed once train.r is run.

Methods
--------------------------

We use the following methods:
1. [Spectal Clustering](./methods/spectral_clustering.R)
2. [Regularized Spectal Clustering](./methods/spectral_regularized.R)
3. [Spectal Clustering with $L_2$ Normalization](./methods/spectral_l2.R)
4. [SCORE](./methods/spectral_score.R)
5. [Variational Bayes](./methods/Variational_Bayes.R)
6. [Variational EM](./methods/Variational_EM.R)
7. [Gibbs Sampling](./methods/Gibbs_Sampling.R)

Experiments
============

Data
--------------------------

Data used in the report can be obtained from [data](./data/).

Visualization
--------------------------

Various visualization is provided in [visualization](./analysis/Vis.rmd).

Training
--------------------------
These are the instructions to train the methods reported in the paper in the various conditions.

Our methods can be trained in parallel using the following syntax:

```
Rscript ./train/train_METHODNAME.R
```

where METHODNAME should be replaced by the abbreviation of [methods](./methods/).