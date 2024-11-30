res_gibbs <- list()
for (j in 1:10){
    load(paste0("Research/SBM_computation/data/sbm_gibbs_seed_", (j-1) * 10 + 1, ".RData"))
    res_gibbs <- rbind(res_gibbs, res)
}
save(res_gibbs, file = "Research/SBM_computation/data/sbm_gibbs_1000.RData")
