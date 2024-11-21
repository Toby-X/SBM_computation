# Metrics used
if (!require(aricode)) install.packages("aricode")
if (!require(MLmetrics)) install.packages("MLmetrics")
library(MLmetrics)
library(aricode)

# Usage
# ARI(y_true, y_pred)
# NMI(y_true, y_pred)
# F1_Score_macro(y_true, y_pred)
# F1_Score_micro(y_true, y_pred)
# Accuracy(y_true, y_pred)
