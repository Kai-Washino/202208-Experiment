#2022年8月の実験結果を可視化，解析するためのプログラム

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import os
import glob

def main():
    path = "C:\\Users\\S2\\Documents\\実験\\2022年度8月 唾液分泌\\result"
    folder_list = glob.glob(path + '\\*')
    title_list = os.listdir(path)

    csv_list = []
    for name in folder_list:
        csv_list.append(glob.glob(name+'\\*.csv')[0])

    df_list = []
    for csv_name in csv_list:
        df_list.append(pd.read_csv(csv_name, header=None))


    turn_list=[]
    result_list=[]
    for df in df_list:
        turn_list.append(df.iloc[:1])
        df = df.drop(0)
        labels = ['before','after','no need']
        labels_dict = {num: label for num, label in enumerate(labels)}
        df = df.rename(columns = labels_dict)
        del df['no need']
        result_list.append(df['after']-df['before'])
    player_num = len(csv_list) 
    make_linegraph_1part(result_list, player_num, turn_list, title_list)
    make_linegraph_3part(result_list, player_num, turn_list, title_list)
    make_bargraph(result_list, player_num, turn_list, title_list) 

def make_linegraph_1part(result_list, player_num, turn_list, title_list):
    #result_listは1列の表示するグラフ，player_numはプレイヤーの人数，turu_listはにおいを噴射した時間，title_listはタイトル名
    plt.rcParams["font.size"] = 5
    fig_1part = plt.figure()
    subplot_area = []
    x = ['0', '5', '10', '15', '20', '25', '30', '35', '40', '45', '50', '55']
    separete = player_num // 3 + 1
    print(separete)
    # subplot_area.append(fig_1part.add_subplot(separete, separete, i+1))


    for i in range(player_num):
        subplot_area.append(fig_1part.add_subplot(3, separete, i+1))
        y = []
        for j in range(12):
            y.append(result_list[i].iloc[j])

        odor_time = []
        for j in range(3):
            odor_time.append(turn_list[i].at[0,j])
        marker_name = ['','','']
        for j in range(3):
            if(odor_time[j] == 0.0):
                marker_name[j] = "No"
            elif(odor_time[j] == 30.0):
                marker_name[j] = "30"
            else:
                marker_name[j] = "180"
            subplot_area[i].text(2 + j*4 ,y[2 + 4*j], marker_name[j], fontsize=5)

        subplot_area[i].plot(x, y, lw=1)
        subplot_area[i].set_title(title_list[i])

        # subplot_area[i].set_xlabel('time [minutes]')
        # subplot_area[i].set_ylabel('saliva volume [g]')
        # subplot_area[i].legend(loc = 'upper right')
        subplot_area[i].set_ylim(0, 1.0)
        plt.tick_params(labelsize=5)
    
    plt.tight_layout()
    plt.show()

def make_linegraph_3part(result_list, player_num, turn_list, title_list):
    #result_listは1列の表示するグラフ，player_numはプレイヤーの人数，turu_listはにおいを噴射した時間，title_listはタイトル名

    x = ['0', '5', '10', '15']
    fig_3part = plt.figure()
    subplot_area = []
    separete = player_num // 3 + 1
    for i in range(player_num):
        subplot_area.append(fig_3part.add_subplot(3, separete, i+1))
        y1 = []
        y2 = []
        y3 = []
        for j in range(4):
            y1.append(result_list[i].iloc[0+j])
            y2.append(result_list[i].iloc[4+j])
            y3.append(result_list[i].iloc[8+j])
        
        odor_time = []
        for j in range(3):
            odor_time.append(turn_list[i].at[0,j])

        color = ['red', 'red', 'red']
        for j in range(3):
            if(odor_time[j] == 0.0):
                color[j] = "red"
            elif(odor_time[j] == 30.0):
                color[j] = "skyblue"
            else:
                color[j] = "blue"

        subplot_area[i].plot(x, y1, label = str(odor_time[0]), color = color[0], lw =1)
        subplot_area[i].plot(x, y2, label = str(odor_time[1]), color = color[1], lw =1)
        subplot_area[i].plot(x, y3, label = str(odor_time[2]), color = color[2], lw =1)
        subplot_area[i].set_title(title_list[i])
        subplot_area[i].set_xlabel('time [minutes]')
        subplot_area[i].set_ylabel('saliva volume [g]')
        subplot_area[i].legend(loc = 'upper right')
        subplot_area[i].set_ylim(0, 1.0)
    plt.tight_layout()
    plt.show()


def make_bargraph(result_list, player_num, turn_list, title_list):
    relative_list_2to3 = []
    relative_list_2to4 = []
    absolute_list = []
    

    for i in range(player_num):
        y = []
        relative_list_2to3.append([title_list[i], 0, 0, 0])
        relative_list_2to4.append([title_list[i], 0, 0, 0])
        absolute_list.append([title_list[i], 0, 0, 0])
        for j in range(12):
            y.append(result_list[i].iloc[j])

        odor_time = []
        for j in range(3):
            odor_time.append(turn_list[i].at[0,j])

         
        for j in range(3):
            if(odor_time[j] == 0.0):
                relative_list_2to3[i][1] = y[2 + 4*j] - y[1 + 4*j]
                relative_list_2to4[i][1] = y[3 + 4*j] - y[1 + 4*j]
                absolute_list[i][1] = y[2 + 4*j]
            elif(odor_time[j] == 30.0):
                relative_list_2to3[i][2] = y[2 + 4*j] - y[1 + 4*j]
                relative_list_2to4[i][2] = y[3 + 4*j] - y[1 + 4*j]
                absolute_list[i][2] = y[2 + 4*j]
            else:
                relative_list_2to3[i][3] = y[2 + 4*j] - y[1 + 4*j]
                relative_list_2to4[i][3] = y[3 + 4*j] - y[1 + 4*j]
                absolute_list[i][3] = y[2 + 4*j]
    
    x = np.array([1, 2, 3])
    labels = ['無', '30秒', '180秒']
    
    margin = 0.2  
    totoal_width = 1 - margin
    average_list = [0, 0, 0]

    data_list = absolute_list #絶対値
    # data_list = relative_list_2to3 #におい噴射直後と直前の変化量
    # data_list = relative_list_2to4 #におい噴射直後の次と直前の変化量
    print(data_list)

    
    for i in range(player_num):
        temp_data = data_list[i]
        name = temp_data.pop(0)
        pos = x - totoal_width *( 1- (2*i+1)/player_num)/2
        plt.bar(pos, temp_data, width = totoal_width/player_num, label = name)
        for j in range(3):
            average_list[j] = average_list[j] + temp_data[j]

    plt.xticks(x, labels, fontname="MS Gothic")
    # print(average_list)

    plt.plot(1, average_list[0]/player_num, '*',markersize=20)
    plt.plot(2, average_list[1]/player_num, '*',markersize=20)
    plt.plot(3, average_list[2]/player_num, '*',markersize=20)
    plt.legend(loc = 'upper right')
    plt.show()
    

if __name__ == '__main__':
    main()