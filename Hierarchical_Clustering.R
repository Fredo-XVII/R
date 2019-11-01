# HCLUST Code

### CLUSTERING (May not need)
Hiearchical Clustering
```{r, fig.asp = .67, fig.width = 12, fig.align = "center", message=FALSE}
# 1. SCALE DATA: SCALED

# 2. Compute dissimilarity matrix
DIST_ITEM <- dist(ITEM_RANK_2DELTA[c(10)], method = "euclidean")  # c(2,9)
#DIST_ITEM <- dist(ITEM_RANK_2DELTA[,2:ncol(ITEM_RANK_2DELTA[c(-9,-10)])], method = "euclidean")  # c(2,9)
# Hierarchical clustering using Ward's method
ITEM.HC <- hclust(DIST_ITEM, method = "ward.D") # # "ward.D", "ward.D2", "single", "complete", "average", "median", "centroid"
ITEM.HC 
# Visualize
plot(ITEM.HC, cex = 0.90) # plot tree
#plot(res.hc,labels=ITEM_RANK_2DELTA$MDSE_ITEM_I,main='Default from hclust')

# Cut tree into 4 groups
ITEM_HC_CLUSTERS <- cutree(ITEM.HC, k = 2) # Six groups has the best distribution

```
<br></br>

Hiearchical Clusters Graph:
```{r}
table(ITEM_K_CLUSTER$cluster,ITEM_HC_CLUSTERS)
plot(ITEM_RANK_2DELTA[,c(10,9)], col = (ITEM_HC_CLUSTERS ) ) # ITEM_HC_CLUSTERS +1 
plot(ITEM_RANK_2DELTA[,c(10,2)], col = as.factor( ifelse(ITEM_RANK_2DELTA$EM >=0,1,0) & ifelse(ITEM_RANK_2DELTA$SLS_A_DD >=0,1,0)) ) # ITEM_HC_CLUSTERS +1 
ITEM_RANK_2DELTA %>% 
  ggplot(aes(x = EM_COST, y = SLS_A_DD)) + geom_point(color = as.factor(ITEM_HC_CLUSTERS)) #+ facet_grid(aes(ITEM_HC_CLUSTERS))
```
