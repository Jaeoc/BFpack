library(polycor)
my_data <- mtcars[, c(1,3,4,5,6,7)]
res <- cor(my_data)
res <- hetcor(my_data)
BF(res)
BF(res,hypothesis="disp_with_mpg > wt_with_mpg > 0")


