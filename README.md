Official R implementation of the paper: 

**"Some cool name"**

Requirements
-------------

1. mlsbm
2. sbm

Installation
-------------

Auto installation is performed once train.r is run.

Methods
--------------------------

We use the following methods:
1. [Spectral1](./methods/Spectral1.r)
2. [Spectral2](./methods/Spectral2.r)
3. [Spectral3](./methods/Spectral3.r)
4. [Spectral4](./methods/Spectral4.r)
5. [Variational Bayes](./methods/Variational_Bayes.r)
6. [Variational EM](./methods/Variational_EM.r)
7. [Gibbs Sampling](./methods/Gibbs_Sampling.r)
8. [HMC](./methods/HMC.r)

Experiments
============

These are the instructions to train and test the methods reported in the paper in the various conditions.

**Data generation** This is an example of how to prepare the data for training:

(To be changed)

```
cd filelists/DATASET_NAME/
sh download_DATASET_NAME.sh
```

**Sampling** Our methods can be trained using the following syntax:

(To be changed)
```
python train.py --dataset="CUB" --method="CDKT" --train_n_way=5 --test_n_way=5 --n_shot=1 --seed=1 --train_aug --steps=2 --tau=0.2 --loss="ELBO"
```

This will train CDKT 5-way 1-shot on the CUB dataset with seed 1, temperature 0.2, and the ELBO loss. The `dataset` string can be one of the following: `CUB`, `miniImagenet`, `cross`. At training time the best model is evaluated on the validation set and stored as `best_model.tar` in the folder `./save/checkpoints/DATASET_NAME`. The parameter `--train_aug` enables data augmentation. The parameter `seed` set the seed for pytorch, numpy, and random. Set `--seed=0` or remove the parameter for a random seed. The parameter `steps` controls the task-level update steps for mean-field approximation. The parameter `tau` sets the temperature for the logistic-softmax likelihood. The parameter `loss` can be `ELBO` or `PLL`, corresponding to the ELBO loss and the predictive likelihood loss. Additional parameters are provided in the file `io_utils.py`, such as `mean` and `kernel`, where `mean` sets the prior mean for GP (default is 0) and the choices of kernel include `linear`, `rbf`,  `matern`, `poli1`, `poli2`, `bncossim`.

**Visulization** For visulization, run the code as follows:

(To be changed)
```
python calibrate.py --dataset="CUB" --method="CDKT" --train_n_way=5 --test_n_way=5 --n_shot=1 --seed=1 --train_aug --steps=2 --tau=0.2 --loss="ELBO"
```
