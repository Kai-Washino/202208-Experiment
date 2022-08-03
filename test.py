# 棒の配置位置、ラベルを用意

import numpy as np
import matplotlib.pyplot as plt

x = np.array([1, 2, 3, 4])
labels = ["Apple", "Banana", "Carrot", "Daikon"]
 
# 各系列のデータを用意
height = np.random.rand(4)
height2 = np.random.rand(4)
height3 = np.random.rand(4)
height4 = np.random.rand(4)
height5 = np.random.rand(4)
data = [height, height2,height3,height4, height5]
 
# マージンを設定
margin = 0.2  #0 <margin< 1
totoal_width = 1 - margin
 
# 棒グラフをプロット
for i, h in enumerate(data):
    pos = x - totoal_width *( 1- (2*i+1)/len(data) )/2
    plt.bar(pos, h, width = totoal_width/len(data))
    # print(pos)
    print(i)
    print(h)
    print(len(data))
plt.xticks(x, labels)
plt.show()