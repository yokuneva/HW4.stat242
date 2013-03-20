


setwd("/home/jenya/hw6")
library(parallel)
library(randomForest)
##################################################create a list of 22 file names
data=list.files()


###################################################get sample via lapply

getSample = function(listOfFiles){do.call("rbind",lapply(listOfFiles, function (x){
  
  k=read.csv(x)
  set.seed(1985)
  k[sample(1:nrow(k), 100000, replace = FALSE),]
}))
}

ourSample = getSample(data)

system.time(getSample(data))


################################################substitute lapply with mclapply

RNGkind("L'Ecuyer-CMRG")
set.seed(1985)
mc.cores = detectCores()

results = mclapply(data,  function (x){
  
  k=read.csv(x)
  i = sample(1:nrow(k), 100000, replace = FALSE)
  k = k[i,]
}, mc.cores = mc.cores)








################################################parallelize the above with parLapplyLB
RNGkind("L'Ecuyer-CMRG")
cl = makeCluster(detectCores(), type = "FORK")
clusterSetRNGStream(cl, 1985)

results = parLapplyLB(cl, list.files(), function (x){
  
  k=read.csv(x)
  k[sample(1:nrow(k), 100000, replace = FALSE),]
})


stopCluster(cl)
###############################################################do the above with clusterApplyLB
RNGkind("L'Ecuyer-CMRG")

cl = makeCluster(detectCores(), type = "FORK")
clusterSetRNGStream(cl, 1985)

data=list.files()
results = clusterApplyLB(cl, data, function (x){
  
  k=read.csv(x)
  k[sample(1:nrow(k), 100000, replace = FALSE),]
})

stopCluster(cl)



######read data into R and then sample getting 100000 obs per year with parSapply


getData = do.call("rbind", lapply(data, read.csv))

system.time(do.call("rbind", lapply(data, read.csv)))

RNGkind("L'Ecuyer-CMRG")
set.seed(1985)
cl = makeCluster(4, type = "FORK")

results = parSapply(cl, getData$year, function(x) {
  x[sample(1:nrow(x), 100000, replace = FALSE),]
})


stopCluster(cl)


#################################################
sapply(ourSample, function (x) length(unique(x)))
sapply(ourSample, class)

ourSample$DayOfWeek = factor(ourSample$DayOfWeek)






###########################################################random forest in parallel

RNGkind("L'Ecuyer-CMRG")

cl = makeCluster(detectCores(), type = "FORK")
clusterSetRNGStream(cl, 1985)
clusterEvalQ(cl, ls())

results = clusterCall(cl, function(...) { replicate(5, {
  
  k =randomForest(ArrDelay ~ DayOfWeek + DepDelay + Distance,
                  replace = TRUE, 
                  data = ourSample, ntree=10, na.action = na.omit)
  
})})

stopCluster(cl)



################################predict method for random forest object in parallel

RNGkind("L'Ecuyer-CMRG")

cl = makeCluster(detectCores(), type = "FORK")
clusterSetRNGStream(cl, 1985)
clusterEvalQ(cl, ls())

results = clusterCall(cl, function(...) {
  
  p = predict(k)
  
})})

stopCluster(cl)













