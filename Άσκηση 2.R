library(haven)     # �������� �� ����������
library(ggplot2)

regression<-read.table("cars1920.txt",header=T)
attach(regression)
names(regression)
View(regression)      # ������� ��� �� ����� �� ������� ���������
head(regression, n = 11)      
tail(regression, n = 11) # ���� ����� ����� �� 0 ����� �� ������ ������ 
#���� �� ����� ��� ������� �� 0 ����� � ������ ���������
# save(regression, file="example 1-reg") # ������ �����������

is.data.frame(regression)  # ������� ����������� ��� �������� ���������
str(regression) #����� tbl data frame
dim(regression)    #������� ������� ��� ������                
names(regression) 
apply(regression,MARGIN=2,"class") #�� ����� ����� ���� �����

# ��������� ��������� ���������� �� ��������� (Ordered factor)
regression$speed   # �� ����� ����� �� ������� �������
fspeed <- as.ordered(regression$speed)
levels(fspeed) <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19)
# �������� ��� ���� ���������� ��� ������� ���������
regression1 <- cbind.data.frame(regression,fspeed) #�� ��������� data frame
View(regression1)

#------------------------------------------------------------------------
# ������� 1:  �������� ������� ���������� �� ��� ggplot2
#                
#------------------------------------------------------------------------

#  � ��������� "ggplot" - "����������" �������� ���������� 
# ��������� ��������� ��� ������ ��������� �������������
ggplot(data = regression1) +
  geom_point(mapping = aes(x = speed, y = dist), shape=21, size = 3) +
  labs(x  = "��������",  y  = "��������")  +
  geom_smooth(mapping = aes(x = speed, y = dist), 
              method  = "lm",  se = FALSE)+
  labs(title = "������ 1", subtitle = NULL)

#�������� ��� �� ��� ���������� ����������� ������ ���� ����� �������� ��� ���
#��������� � �������� ������� ��������� ��� � ��������. ������ ��� ��������� ��� 
#13 ��� 18 ������ ���� ������ ����� ��������� ���� �� �� ����� ��������.

# ggsave("regression1.pdf") # ���������� �� ����� pdf

#------------------------------------------------------------------------
# ������� 2:    �������� ������������ �� �� ��������� lm
#                
#------------------------------------------------------------------------

names(regression1)

# � ��������� ��� ����� ��������� �������������
lmod <- lm(dist ~ speed, regression1)

names(lmod)   # ������������ ��� ��������� ������������ ����������
summary(lmod)  
#������ ������������� ������������ �� �������� ����� ��� -29.069.. ��� 43.201..
#�� 50% (����� - ����� ������������) ��������� ����� �������?
#� ����� ���� ��� ����� ���� ������ �� ��� ����� ���������� � ��������?
#�� ������������ ��� ���������� ��� �� �.�.?
#coefficients:��� ���� �������� ��� �����������������, � �������� ��������� ���� 3.93
#�� t value ������� �� �������� �� estimate std �� �� error
#� ���������� �� ������ � �0 ����� 1.49e-12

#------------------------------------------------------------------------
#������� 3-4     ������������ ������� (������������)
#                
#------------------------------------------------------------------------

# 1. ������� ����������� ��� ��������� ���� �������� ��������
par(mfrow=c(1,3))
qqnorm(residuals(lmod),ylab="Residuals",main="")
qqline(residuals(lmod))
hist(residuals(lmod),xlab="Residuals",main="")
par(mfrow=c(1,1))
shapiro.test(residuals(lmod)) #����� ���������� ��� ������� ����� ������ ������������
#��� ������ ���������� ���� �������� ��������
plot(lmod, which = 2)         #������ ��� ���������� �������� ������ 
plot(lmod)


# 2 ������� �������� (����������� ��� ��������� ��� ���������)
par(mfrow = c(1,2))
plot(fitted(lmod),residuals(lmod),xlab="Fitted",ylab="Residuals")
abline(h=0)

plot(lmod, which = 1)  # � ��������� ��� ��������� ��������
plot(lmod, which = 3)
par(mfrow = c(1,1))


# 3 ������� �������������� 1�� ����� ��� ��������� (Durbin-Watson test)
n <- length(residuals(lmod))
plot(tail(residuals(lmod),n-1) ~ head(residuals(lmod),n-1), xlab=
       expression(hat(epsilon)[i]),ylab=expression(hat(epsilon)[i+1]))
abline(h=0,v=0,col=grey(0.75))

require(lmtest)
dwtest(dist ~ speed, data=regression1) 
#������ ��� ������ ��������� 1�� ����� ��� ���������


# 4 ������ ����������� ������������ (Mahalanobis)
# ������ �� �������� Mahalanobis > 2p/n ������ �� ���������� ���������
lmod <- lm(dist ~ speed, regression1)
hatv <- hatvalues(lmod)  # Mahalanobis
head(hatv)
sum(hatv)       # ������ ��� �������� = p = 2 (������ ����������)
mah <- 2*2/50   
plot(hatv,ylab="Leverages")
abline(h = mah)
hatv[hatv > mah]
# ������ ������: 1,2,50
# ���� ����� cook & inf.measures

# 5. Cook's distance 
cook <- signif(cooks.distance(lmod), 3)
cook
# �� ����� ��������� ���������� ��� �� ���������� ��� �������������
plot(lmod, which = 4)
# ������ ������ 23,39,49

# ��������������� �������� ��������� ��� R
# ��� �������� ��� ���� ����� ����������� ���������
# ������� ��� ���������� ���� ����������� ��� �.�.
imI <- influence.measures(lmod)
summary(imI)
#�� lmod ���� ���� ��� ������������
# ������ �������� ������ 1,2,23,49,50

#------------------------------------------------------------------------
#������� 6-9  �������� ����������� ��� ��������� (������ ������)
#                
#------------------------------------------------------------------------

lmod.f <- lm(dist ~ fspeed, regression1) #�� fdistance �� ��� ����� ���������
summary(lmod.f) #intercept : � ������� ����� ���� 40.725
anova(lmod, lmod.f) 
#��������� �� ��� ������� �� ������ ��� ���� �� ��� ��������� ��������
#������� ��� F �������� 
#�0 �� ��� ������� ����� ����
#�� ��� �������� ������ �� ������ ��� ��������� ��� �� ���� ��� ?

#����������� ��� �� ������ ������ (�������� ��� ��������� ��� ��� ����������� ���
#��������� ���� ����� ����� ��� x) ��� ����� ���������� ��������� 
#F(17, 31)= 1.2369, p =0.2948  , �������� �� ������� ����� �������.
hist(speed,xlab="Speed",main="")
hist(as.numeric(fspeed),xlab="fSpeed",main="")

#������� 7
# pure error (�������� ��� ��������� ��� ��� �����������)
sqrt(11353.5/48) #236.531
sqrt(6764.8/31) # 218.219
#��� �������� ����� �� ������� �������, �� ��� ����������������� �����
#����� ���� ��������� ��������

# x2
lmod2 <- lm(dist ~ speed +I(speed^2), regression1)
summary(lmod2) #����� ������� ��� �� � ��� �� �^2 
summary(lmod)

anova(lmod2, lmod.f)  

sqrt(10824.7/48) #225.514
sqrt(6764.8/31) # 218.219
#��� ��� ���� �� ������� ������� ����� ��������

#������� 9: ������� ������������ ��� ��������� ��� ���� ��������

#���������� 1
shapiro.test(lmod.f$residuals)
# ��� ������� �� �� shapiro test W=0.977 p=0.456 �� �������� ���������� 
# �������� ��������

#���������� 2
plot(lmod.f$fitted.values,lmod.f$residuals,xlab = "Fitted.values",ylab = "Residuals")
abline(lm(lmod.f$residuals ~ lmod.f$fitted.values),col="red") 

par(mfrow=c(2,2))
plot(lmod.f, which = 1)
plot(lmod.f, which = 2)
plot(lmod.f, which = 3)
plot(lmod.f, which = 4)
par(mfrow=c(1,1))


inf.f <- influence.measures(lmod.f)
attributes(lmod.f)

summary(inf.f)  
class(inf.f) #
str(inf.f) # ����� ����� ��� 3 ��������

#� ������� ��� ���� �������� ����� 
lmod.f <- lm(dist ~ fspeed, regression1)

# �� ����� ��������� ��� ���������� ���� ��� �������� ��� ������� ����� ��������� ��� �� ����� ��� ���������� 
#���� ��� �������� ����. �� Adjusted R-squared ��� �������� ��� ���������������� ���� ��� �������� ����� ��������� 
#�� ����� �� �� ������ ����� �� �������� ������� ����� ���� ��� ���������� ��������
regression1 <- regression1[ -c(1,2,49,50),]
lmod <- lm(dist ~ speed, regression1)
summary(lmod)
shapiro.test(residuals(lmod)) 

lmod.f <- lm(dist ~ fspeed, regression1)
summary(lmod.f)
shapiro.test(residuals(lmod.f))
#
#