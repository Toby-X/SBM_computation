res_gibbs <- list()
for (j in 1:10){
    load(paste0("Research/SBM_computation/data/sbm_gibbs_seed_", (j-1) * 10 + 1, ".RData"))
    res_gibbs <- rbind(res_gibbs, res)
}
save(res_gibbs, file = "Research/SBM_computation/data/sbm_gibbs_1000.RData")

res_gibbs <- list()
for (j in 1:10){
    load(paste0("./sbm_gibbs_seed_", (j-1) * 10 + 1, ".RData"))
    res_gibbs <- rbind(res_gibbs, res)
}
save(res_gibbs, file = "./sbm_gibbs_2000.RData")

res <- list()
for (j in c(250, 500, 1000, 2000)){
    load(paste0("./data/sbm_gibbs_", j, ".RData"))
    res <- rbind(res, res_gibbs)
}
save(res, file = "./data/sbm_gibbs.RData")
