# -*- coding: utf-8 -*-
import numpy as np
import matplotlib.pyplot as plt
from math import log

###正常情况无卸载机制###

el = np.random.randint(1, 10, 100)  # 一个cpu周期的本地的能耗
y = []
cl = np.random.randint(1, 10, 100)  # 计算此任务所需的能力，能cpu周期规划
d = np.random.randint(300, 800, 100)  # 每个计算任务的大小
x = np.linspace(10, 100, 10, dtype=int)  # x个移动设备

print(x)
for i in x:
    print(i)
    sum = 0
    for j in range(i):
        sum = sum + (2 * cl[j] * el[j]) / 100  # 加了个2调整系数
    #  print(sum)
    y.append(sum);
print(y)
plt.plot(x, y, color='blue', linestyle='-')
plt.title('Handsome Programmers picture')

###########第一级卸载机制如下###############
pl = np.random.randint(1, 10, 100)  # 扩大了10倍，使用的时候请注意,本地功率
tl = []  # 本地计算任务消耗时间
GR = []  # 传给MEC服务器的设备集合
GL = []  # 本地计算任务的集合
GO = []  # 继续筛选的集合
le = []  # 单个任务本地消耗的能耗
ns = []  # 在小基站计算的设备数目
nm = []  # 在大基站计算的设备数目
L = []
p = {}


def findMin(alist):
    findMin = alist[0];
    for i in range(1, len(alist)):
        if alist[i] < findMin:
            findMin = alist[i]
    return findMin


tl = (cl * 10.0) // pl  # deadline和tmax的精度不对，已修正
dead = np.random.randint(5, 10, 100)
print(x)

for i in range(0, 99):
    print('this i is=====', i)
    if tl[i] > dead[i]:
        print('success!!!')
        GR.append(i)
    elif tl[i] <= dead[i]:
        le = cl * el
        print('wonderful!!!')
        ns = d / ((dead - cl / 4) * log((1 + 40 * 20 / 100), 2))  # {论文里的公式}【【大基站和小基站的传输功率未知这里统一成20W】】？？背景噪声功率
        nm = d / ((dead - cl / 4) * log((1 + 80 * 20 / 100), 2))  # {论文里的公式}【【大基站和小基站的传输功率未知这里统一成20W】】？？背景噪声功率
        L = [40 * ns[i], 80 * nm[i]]  # warning!40和80的单位，而且忘记乘10000
        c = findMin(L)
        p[i] = c / 100  # 调整系数
        if el[i] < p[i]:
            GL.append(i)
            print('GL!')
        elif el[i] >= p[i]:
            GO.append(i)
            print('2')
print('next is the answer of first Offloading')
print('GR=', GR)
print('GL=', GL)
print('GO=', GO)
###########第二级卸载机制############
# 图中第二条线
len1 = len(GR)
len2 = len(GL)
len3 = len(GO)
z = []
v = []
test = []
sum1 = 0
sum2 = 0

for i in range(0, 99):
    # sum1=0
    for j in range(len1):
        if GR[j] == i:
            r = log((1 + 40 * 20 / 100), 2)
            sum1 = sum1 + (d[i] / r + cl[i] * 0.0001) / 1500  ###warning 1500准备调节
            sum2 = sum2 + (d[i] / r + cl[i] * 0.0001) / 1500  ###warning 1500准备调节
            #       print('ONE SUM',sum1)
            break;
    for j in range(len2):
        if GL[j] == i:
            r = log((1 + 80 * 20 / 100), 2)
            sum1 = sum1 + (2 * cl[i] * el[i]) / 100  # 加了个调节系数的2
            sum2 = sum2 + (2 * cl[i] * el[i]) / 100  # 加了个调节系数的2
            # sum1 = sum1+(2*d[i]/r+cl[i]*0.0001)/1000###warning 1000准备调节,2是大基站的p
            # =print('TWO SUM',sum1)
            break;
    sum1 = sum1 + (d[i] / r + cl[i] * 0.0001) / 800  ###warning 1500准备调节
    rm = log((1 + 80 * 20 / 100), 2)
    rs = log((1 + 40 * 20 / 100), 2)
    tm = d / rm + c / 4
    ts = d / rs + d * 0.0001 + c / 4
    if tm[i] < ts[i]:
        sum2 = sum2 + (2 * d[i] / rm + cl[i] * 0.0001) / 1500  ###warning 1000准备调节，2是大基站比小基站多的
    else:
        sum2 = sum2 + (d[i] / rs + cl[i] * 0.0001) / 1500  ###warning 1000准备调节
        #         print('THREE SUM',sum1)
    # print(sum)
    if i == 0 or (i + 1) % 10 == 0:
        z.append(sum1);
        v.append(sum2);
print(z)
print(v)
plt.plot(x, z, color='red', linestyle='--')
plt.plot(x, v, color='green', linestyle=':')
plt.show()
###########第二级卸载机制############
###因为不知道信道怎么根据任务大小而分配，难道和信道增益有关？
##分配好了之后，再怎么量化考虑？
###########信道数未考虑##########
# rm=[]#速率
# rs=[]#速率
# leng=len(GO)
# rm[i]=log((1+40),2)
# ct=2**(d[i]/dead[i]-rm[i])-1
# snr=#信噪比
##第三级卸载机制##
###########第三级卸载机制############
########第三条线#########