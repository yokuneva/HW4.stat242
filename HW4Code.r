####################################################################################################
##                                                                                               ###
##                     HW 4                                                                     ####
####################################################################################################


setwd("/home/jenya/hw5")

##############################################################count number of flights leaving each airport

origin.count = system("cut -d',' -f17 *.csv|
                    egrep -i '(SFO|LAX|SMF|OAK)'| 
                    sort | uniq -c", intern = TRUE)



############################################################################convert to data frame for
#####################################################################################plot

k=data.frame(origin.count)
names(k)=c("count")

m=as.data.frame(t(matrix(unlist(strsplit(as.character(k$count), 
                                split = "[1-9] ")), nrow =2)))

m$V1 = as.numeric(gsub(" ","",m$V1))

barplot(m$V1, beside = TRUE, names.arg = m$V2)



#################################################################open the connection 
origin.delay = pipe("cut -d',' -f15,17  1987.csv | 
                     egrep -i '(SFO|LAX|SMF|OAK)'",open="r+")



c=readLines(origin.delay, n=10)

c = sapply(readLines(origin.delay, n=100), mean)


c=function (x){
  readLines(x,n=10)
}


c(origin.delay)



