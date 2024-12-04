# 培训 - 202411

## 目录

- [Rstudio相关基础](#Rstudio相关基础)
  - [下载安装](#下载安装)

  - [基础设置](#基础设置)

  - [可视化作图](#可视化作图)
    - [安装需要的包并加载](#安装需要的包并加载)

    - [导入数据](#导入数据)

    - [可视化](#可视化)

    - [更改主题](#更改主题)

    - [导出为图片](#导出为图片)

    - [导出为PPT](#导出为PPT)

  - [善用AI](#善用AI)

# Rstudio相关基础

## 下载安装

RStudio：目前公认最好的 R 语言 IDE。

R语言：[清华镜像下载-Windows](https://mirrors.tuna.tsinghua.edu.cn/CRAN/bin/windows/base/); [其他版本](https://mirrors.tuna.tsinghua.edu.cn/CRAN/)

Rstudio下载：[rstudio-desktop](https://posit.co/download/rstudio-desktop/)

RTools(仅windows)：[Rtools-windows](https://cran.rstudio.com/bin/windows/Rtools/)

下载完成后双击打开，**推荐全部使用默认设置**，直接下一步；**更改了安装路径的，出问题自己解决**。

## 基础设置

1. 设置镜像

   ![](rstudio.install.images/PixPin_2024-11-12_10-07-03_KCwD7Eqgq1.png)
2. 安装pak，这个包能够更加方便的安装其他包，比自带的好用，但有时候也会抽风，随便你用哪个安装都行。

   ![](rstudio.install.images/PixPin_2024-11-12_10-09-10_OVMCEoS5XL.png)
3. 安装其他包；左下角区域输入`pak::pkg_install("tidyverse")`，并按下回车。其中引号内为包名。
   > 部分包也可以直接使用上面安装pak的方法
   ![](rstudio.install.images/PixPin_2024-11-12_10-10-52_gc5btcCxXI.png)
4. 加载包

   ![](rstudio.install.images/PixPin_2024-11-12_10-18-56_8ENVzmV8L5.png)
5. 运行代码
   1. 左上角为打开的文件或变量预览区。新建文件后会直接在左上角打开。

      ![](rstudio.install.images/PixPin_2024-11-12_11-06-59_ce6YLyzsL9.png)
   2. 选中代码点击run运行

      ![](rstudio.install.images/PixPin_2024-11-12_11-07-35_xg81bxOO4y.png)

## 可视化作图

尽可能少的使用代码来进行作图。

### 安装需要的包并加载

```r
pak::pkg_install('tidyverse')
pak::pkg_install('officer')
pak::pkg_install('rvg')
pak::pkg_install('esquisse')
pak::pkg_install('ggplotAssist')
pak::pkg_install('ggThemeAssist')
pak::pkg_install('ggplotgui')
```

### 导入数据

1. 点击import

   ![](rstudio.install.images/PixPin_2024-11-12_10-24-52_4zoEXkXHtC.png)
2. 弹出的窗口选择文件，点击打开；或者直接双击打开
3. 左侧按需选择，右上角是原始文件，右下角是解析后的格式；点击Import

   ![](rstudio.install.images/PixPin_2024-11-12_10-27-17_j1k1VAuV7Q.png)

### 可视化

1. 选择插件

   ![](rstudio.install.images/PixPin_2024-11-12_10-29-23_Ka1soLjH9Z.png)

   ![](rstudio.install.images/PixPin_2024-11-12_10-30-06_Ki_kwIy1Rt.png)

1) 在打开的网页中导入变量；

   ![](rstudio.install.images/PixPin_2024-11-12_10-32-06_XYivX_MGFo.png)
2) 基础火山图示例

   ![](rstudio.install.images/PixPin_2024-11-12_10-40-56_48LTI8fYN0.png)
3) 将代码粘贴到左上角

### 更改主题

![](rstudio.install.images/PixPin_2024-11-12_10-43-27_zfhHqK4ptr.png)

![](rstudio.install.images/PixPin_2024-11-12_10-44-42_nrOfNObdzD.png)

![](rstudio.install.images/PixPin_2024-11-12_10-45-41_e_cs_ribpy.png)

### 导出为图片

![](rstudio.install.images/PixPin_2024-11-12_10-46-48_ePLzdrsxRu.png)

### 导出为PPT

![](rstudio.install.images/PixPin_2024-11-12_10-47-47_8TNvd0dUKK.png)

![](rstudio.install.images/PixPin_2024-11-12_10-48-17_9XXW3C6Zbt.png)

![](rstudio.install.images/PixPin_2024-11-12_10-48-33_fMeL7wJxbk.png)

![](rstudio.install.images/PixPin_2024-11-12_10-49-46_N9HCti6eQE.png)

## 善用AI

![](rstudio.install.images/PixPin_2024-11-12_11-00-27_Qj93mGDyR2.png)

![](rstudio.install.images/PixPin_2024-11-12_10-59-10_lxaWVyffUH.png)

