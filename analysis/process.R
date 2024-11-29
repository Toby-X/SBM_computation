if (!require(tidyverse)){
  install.packages("tidyverse")
}

library(tidyverse)

# load data
load("./data/sbm_sc.RData")
load("./data/sbm_sl2.RData")
load("./data/sbm_ss.RData")
load("./data/sbm_sscore.RData")
load("./data/sbm_vb.RData")

# transform data into data frame
res_sc_dm <- data.frame(sc)
res_sc_df <- data.frame(data.matrix(res_sc_dm))
res_ss_dm <- data.frame(ss)
res_ss_df <- data.frame(data.matrix(res_ss_dm))
res_sl2_dm <- data.frame(sl2)
res_sl2_df <- data.frame(data.matrix(res_sl2_dm))
res_sscore_dm <- data.frame(sscore)
res_sscore_df <- data.frame(data.matrix(res_sscore_dm))
res_vb_dm <- data.frame(res_vb)
res_vb_df <- data.frame(data.matrix(res_vb_dm))

res_full <- rbind(res_sc_df, res_ss_df, res_sl2_df, res_sscore_df, res_vb_df)
res_full$method <- rep(c("SC", "Simplex", "L2", "SCORE", "VB"),
                       each = nrow(res_sc_df))
res_full$N <- as.factor(res_full$N)
res_full$K <- as.factor(res_full$K)
res_full$beta <- as.factor(res_full$beta)
res_full$b <- as.factor(res_full$b)

## summary statistics
res_sum_ARI <- res_full %>% group_by(N,K,beta,b,method) %>% 
  summarize(med = median(Z_ARI), mad = mad(Z_ARI))
res_sum_NMI <- res_full %>% group_by(N,K,beta,b,method) %>% 
  summarize(med = median(Z_NMI), mad = mad(Z_NMI))
## seem to have some issues
res_sum_ACC <- res_full %>% group_by(N,K,beta,b,method) %>% 
  summarize(med = median(1-Z_Accuracy), mad = mad(1-Z_Accuracy))
res_sum_time <- res_full %>% group_by(N,K,beta,b,method) %>% 
  summarize(med = median(time), mad = mad(time))

ggplot(res_sum_ARI, aes(x = log(as.numeric(as.character(N))), y = med,
                        color = method)) + 
  geom_line(lwd=0.75) + 
  geom_point() + 
  geom_errorbar(aes(ymin = med - mad, ymax = med + mad), width = 0.1) + 
  facet_grid(K ~ beta + b) + 
  ggtitle("ARI")

ggplot(res_sum_ARI, aes(x = log(as.numeric(as.character(N))), y = med, color = method, lty = K)) + 
  geom_line(lwd=0.75) + 
  geom_point() + 
  geom_errorbar(aes(ymin = med - mad, ymax = med + mad), width = 0.1) + 
  facet_grid(beta ~ b) + 
  ggtitle("ARI")


# Similar but this is better
res_sum_NMI$K <- paste0("K = ",res_sum_NMI$K)
res_sum_NMI$beta <- paste0("beta = ",res_sum_NMI$beta)
res_sum_NMI$b <- paste0("b = ",res_sum_NMI$b)
ggplot(res_sum_NMI, aes(x = as.numeric(as.character(N)), y = med,
                        color = method)) + 
  geom_line(lwd=0.75) + 
  geom_point() + 
  geom_errorbar(aes(ymin = med - mad, ymax = med + mad), width = 0.1) + 
  facet_grid(K ~ beta + b) + 
  ggtitle("NMI") +
  # theme_minimal() +
  theme(
    axis.title.x = element_text(size = 14),
    axis.title.y = element_text(size = 14),
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    plot.title = element_text(size = 16)
  ) + 
  xlab("N") + 
  scale_x_log10() + 
  ylab("NMI")


