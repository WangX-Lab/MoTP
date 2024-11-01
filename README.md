# MoTP

Multi-Omics Tumor Purity Prediction (MoTP) is a machine learning algorithm for accurately estimating tumor purity based on multi-omics data, including transcriptome (mRNA, microRNA, Long non-coding RNA) and DNA methylation data.



&nbsp;
&nbsp;

# Description

A novel algorithm that integrates mRNA expression, lncRNA expression, miRNA expression, and DNA methylation data within a uniform  machine learning framework to predict tumor purity. Benchmark experiments show that MoTP has superior performance compared to other tumor purity estimating algorithms.



&nbsp;

# Details

+ The function `Preprocess()` is preprocessing a list of omics data frames or matrices, including impute missing values and [0,1] scaled (maximum=1, minimum=0). This step is optional; you can process the data yourself, as long as the data has no missing values and the range is scaled to [0,1].
+ The function `MoTP()` is used to predict tumor purity from either single-omics or multi-omics data.
  + "data_list" is a collection of omics data frames or matrices. Specifically, each element in the list represents a different omics dataset, It is essential to ensure that row names are features and col names are samples. The sample names must remain consistent across all the omics datasets provided. The list must contain at least one omics dataset.
  + "omics_list" is a character vector indicating the type of each omics data in data_list. Default is c("mRNA", "miRNA", "lncRNA", "DNA-methylation"). Make sure the order is the same with "data_list".

&nbsp;
&nbsp;

# Installation

- You can install the released version of **MoTP** with:
  &nbsp;

```R
if (!requireNamespace("devtools", quietly = TRUE))
    install.packages("devtools")

devtools::install_github("WangX-Lab/MoTP")
```

&nbsp;
&nbsp;

# Examples

&nbsp;
&nbsp;

## **Apply MoTP with omics data** 

### **Prepare data**

```R
library(MoTP)
file_path <- system.file("extdata", "example.RData", package = "MoTP")
load(file_path)
ls()
#"file_path"  "lncrna"  "methylation"  "mirna"  "mrna"
```



**mRNA data**

```R
mrna[1:5,1:5]
```

| Sample | 100130426 | 100133144 | 100134869 | 10357    | 10431     |
| ------ | --------- | --------- | --------- | -------- | --------- |
| **S1** | 0.0000000 | 2.5500141 | 2.636706  | 6.303383 | 9.529827  |
| **S2** | 0.0000000 | 2.4765891 | 2.028675  | 6.363488 | 10.392884 |
| **S3** | 0.4710313 | 1.9169734 | 2.475163  | 6.625719 | 10.671783 |
| **S4** | 0.0000000 | 3.7624445 | 3.796764  | 6.300019 | 10.914296 |
| **S5** | 0.0000000 | 0.9733541 | 0.000000  | 6.464382 | 10.053460 |



**miRNA data**

```R
mirna[1:5,1:5]
```

| Sample | hsa-let-7a-1 | hsa-let-7a-2 | hsa-let-7a-3 | hsa-let-7b | hsa-let-7c |
| ------ | ------------ | ------------ | ------------ | ---------- | ---------- |
| **S1** | 14.43064     | 14.42567     | 14.42991     | 14.13457   | 12.55568   |
| **S2** | 14.16773     | 14.17590     | 14.18695     | 13.28409   | 11.83922   |
| **S3** | 13.36032     | 13.36814     | 13.35466     | 12.28092   | 10.40663   |
| **S4** | 12.94559     | 12.93629     | 12.95119     | 12.85132   | 8.19243    |
| **S5** | 14.07908     | 14.07327     | 14.07395     | 14.36202   | 10.28470   |





**lncRNA data**

```R
lncrna[1:5,1:5]
```

| Sample | **LINC01587** | **AC000111.6** | **XXbac-B461K10.4** | **IGF2-AS** | **TPTEP1** |
| ------ | ------------- | -------------- | ------------------- | ----------- | ---------- |
| **S1** | 1.584963      | 0              | 2.000000            | 9.294621    | 10.70908   |
| **S2** | 1.000000      | 0              | 3.807355            | 9.665336    | 10.05799   |
| **S3** | 5.357552      | 0              | 2.807355            | 1.584963    | 10.67772   |
| **S4** | 4.584963      | 0              | 2.807355            | 9.523562    | 3.00000    |
| **S5** | 0.000000      | 0              | 1.584963            | 2.000000    | 5.83289    |

&nbsp;

**DNA methylation data**

```R
methylation[1:5,1:5]
```

| Sample | cg04750166 | cg12313215 | cg20073910 | cg25831071 | cg20980303 |
| ------ | ---------- | ---------- | ---------- | ---------- | ---------- |
| **S1** | 0.0173     | 0.0170     | 0.0484     | 0.1287     | NA         |
| **S2** | 0.0157     | 0.0248     | 0.0312     | 0.5802     | NA         |
| **S3** | 0.0162     | 0.0148     | 0.0600     | 0.7650     | NA         |
| **S4** | 0.0154     | 0.0158     | 0.0553     | 0.6093     | NA         |
| **S5** | 0.0186     | 0.0171     | 0.0355     | 0.4455     | NA         |




## Apply MoTP to single omics data

```R
data_list = list(mrna) #If your input is mRNA data, you need to make sure the feature is Gene ID
data_pre = Preprocess(data_list)
Purity = MoTP(data_pre, omics_list = c("mRNA"))
```

&nbsp;
&nbsp;


## **Apply MoTP to multi-omics data**



```R
data_list = list(mrna,mirna,lncrna,methylation)
data_pre = Preprocess(data_list)
Purity = MoTP(data_pre, omics_list = c("mRNA", "miRNA", "lncRNA", "DNA-methylation"))
```


&nbsp;
# Contact

E-mail any questions to Xiaosheng Wang (xiaosheng.wang@cpu.edu.cn)
