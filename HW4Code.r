setwd("/home/jenya/hw5")


origin.count=system("cut -d',' -f17 *.csv|
                    egrep -i '(SFO|LAX|SMF|OAK)'| 
                    sort | uniq -c", intern = TRUE)




setwd("/home/jenya/hw5")
origin.delay=
  readLines(pipe("cut -d',' -f15,17  *.csv | 
                 egrep -i '(SFO|LAX|SMF|OAK)'",open="r+"))





readLines(origin.delay,n=100)

setwd("/home/jenya")

data = bzfile("/home/jenya/Years1987_1999.tar.bz2")

dak=readLines(data, n=11)



