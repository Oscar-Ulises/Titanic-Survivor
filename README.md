# Titanic-Survivor
Titanic-Survivor es un proyecto de clasificación que pretende predecir através de diferentes parámetros si sobrevirías a una de las catástrofes marítimas más importantes de la historia, el hundimiento del Titanic.
La tabla de datos que me permitió elaborar la aplicación fue extraída de Kaggle, la cual contiene 12 variables y 891 observaciones, la variable a predecir es Survived donde 1 = sobrevivencia y 0 = fallecimiento.

## Limpieza de la tabla.
Para realizar la aplicación, primero es necesario conocer cuáles son los datos con los que contamos y si es necesario modificarla para poder ajustar nuestros modelos correctamente.

Como lo mencioné anteriormente, la tabla cuenta con 12 variables: PassengerId, Survived, Name, Sex, Age, SibSp, Parch, Ticket, Fare, Cabin y Embarked. Dejaremos a un lado 'PassangerId', 'Name', 'Ticket' y 'Cabin', pues éstas no son variables cuantitativas ni cualitativas, solamente datos de los pasajeros. 

Procedo a crear un subconjunto con las variables que sí serán tomadas en cuenta y con la función summary obtendremos las medidas centrales de cada:
```{r,echo=FALSE}
library(ggplot2)
library(caret)
library(rpart)
library(rpart.plot)
setwd("C:/Users/52473/Desktop/Titanic_app")
train<- read.csv("train.csv",header = TRUE)
train <- subset(train,select = c(2,3,5,6,7,8,10,12))
train<- data.frame(train)
attach(train)
summary(train)
```
Los valores máximo y mínimo en las variables que no son factores serán tomados como referencia para los límites paramétricos de la aplicación, ninguna variable presenta valores extremos. Aunque la edad('Age') de los pasajeros tiene muchos valores faltantes. 
```{r,echo=FALSE}
Survived<-as.factor(Survived)
train$Survived<-Survived
```

### Pclass
Pclass es una variable cualitativa que representa la clase en la que viajan, tiene tres posibles resultados: 1 = Clase Alta (aquí viaja la gente rica), 2 = Clase Media (Se les considera ricos y es la segunda más popular) y 3 = Clase Baja (Aquí viaja la mayoría de las personas).

Visiblemente existe una tendencia a sobrevivir si se viaja en primera clase, contrario a lo que sucede en tercera clase. Donde la probabilidad frecuentista de fallecer es notablemente más alta.
```{r,echo=FALSE}
Pc<- c()
for( i in 1:length(Pclass)){
  if( Survived[i] == 1 & Pclass[i] == 1){
    Pc[i] = "Primera Clase y Sobrevivió" 
  } else if (Survived[i] == 0 & Pclass[i] == 1){
    Pc[i] = "Primera Clase y No Sobrevivió"
  } else if (Survived[i] == 1 & Pclass[i] == 2){
    Pc[i] = "Segunda Clase y Sobrevivió"
  } else if (Survived[i] == 0 & Pclass[i] == 2){
    Pc[i] = "Segunda Clase y No Sobrevivió"
  } else if (Survived[i] == 1 & Pclass[i] == 3){
    Pc[i] = "Tercera Clase y Sobrevivió"
  } else if (Survived[i] == 0 & Pclass[i] == 3){
    Pc[i] = "Tercera Clase y No Sobrevivió"
  }}

Pclass<- as.factor(Pclass)
train$Pclass<-Pclass

#table(Pc)
tabla_clase<- data.frame(Clase=c("Primera clase","Primera clase","Segunda clase","Segunda clase","Tercera clase","Tercera clase"), Sobrevivencia=c("Sí","No","Sí","No","Sí","No"),Valor=c(136,80,87,97,119,372))

ggplot(data = tabla_clase, aes(x= Clase, y = Valor, fill = Sobrevivencia))+geom_bar(stat = "identity", position = position_dodge())+theme_minimal()+scale_fill_brewer(palette="Paired")
```

### Sex
En el caso del sexo, existe una mayor probabilidad de fallecer para las personas del sexo masculino. Las mujeres sobrevivieron más que los hombres, pero además hay muchas más sobrevivientes que fallecidas. Por ende es una variable de suma importancia para el modelo de clasificación. Por ser una variable cualitativa será tratada como factor.

```{r, echo=FALSE}
Se<- c()
for( i in 1:length(Sex)){
  if( Survived[i] == 1 & Sex[i] == "male"){
    Se[i] = "Masculino y Sobrevivió" 
  } else if (Survived[i] == 0 & Sex[i] == "male"){
    Se[i] = "Masculino y No Sobrevivió"
  } else if (Survived[i] == 1 & Sex[i] == "female"){
    Se[i] = "Femenino y Sobrevivió"
  } else if (Survived[i] == 0 & Sex[i] == "female"){
    Se[i] = "Femenino y No Sobrevivió"
  }}

Sex<- as.factor(Sex)
train$Sex<-Sex

#table(Se)
tabla_sex<- data.frame(Sexo=c("Masculino","Masculino","Femenino","Femenino"), Sobrevivencia=c("Sí","No","Sí","No"),Valor=c(109,468,223,81))

ggplot(data = tabla_sex, aes(x= Sexo, y = Valor, fill = Sobrevivencia))+geom_bar(stat = "identity", position = position_dodge())+theme_minimal()+scale_fill_brewer(palette="Paired")
```

### Age
La variable edad tiene 177 valores no faltantes. Los cuales serán remplazados por la media de edad por la clase en la que viajan. Además es una variable cuantitativa.
```{r,echo=FALSE}
sapply(train,function(x) sum(is.na(x)))

Edad_first_class<- c()
for(i in 1:length(train)){
  if(Pclass[i] == 1){
    Edad_first_class[i] = Age[i]
  }
}
Edad_first_class<- na.omit(Edad_first_class)
Promedio_first_class<- mean(Edad_first_class)
Edad_s_class<- c()
for(i in 1:length(Pclass)){
  if(Pclass[i] == 2){
    Edad_s_class[i] = Age[i]
  }
}
Edad_s_class<- na.omit(Edad_s_class)
Promedio_s_class<- mean(Edad_s_class)
Edad_t_class<- c()
for(i in 1:length(Pclass)){
  if(Pclass[i] == 3){
    Edad_t_class[i] = Age[i]
  }
}
Edad_t_class<- na.omit(Edad_t_class)
Promedio_t_class<- mean(Edad_t_class)
for( i in 1:length(Age)){
  if( Pclass[i]==1 & is.na(Age[i])){
    Age[i]<- Promedio_first_class
  }else if ( Pclass[i]==2 & is.na(Age[i])){
    Age[i]<- Promedio_s_class
  }else if (Pclass[i]==3 & is.na(Age[i])){
    Age[i]<- Promedio_t_class
  }
}
train$Age<-Age
```
Media de edad primera clase | Media de edad segunda clase | Media de edad tercera clase
--------------------------- | --------------------------- | ---------------------------
42.3                        | 29.87                       | 25.14

### SibSp
La cantidad de familiares o pareja que están abordo del navío es lo que significa la variable. Dado que el valor más grande de esta variable es 8 será tratada como factor aunque puramente no lo sea.

La gráfica muestra que entre menos familiares o pareja acompañen al pasajero más probabilidades tiene de sobrevivir.

```{r,echo=FALSE}
Sib<- c()
for( i in 1:length(SibSp)){
    if( Survived[i] == 1 & SibSp[i] == 0){
    Sib[i] = "Ningún familiar y Sobrevivió" 
  } else if (Survived[i] == 0 & SibSp[i] == 0){
    Sib[i] = "Ningún familiar y No Sobrevivió"
  } else if( Survived[i] == 1 & SibSp[i] == 1){
    Sib[i] = "Un familiar y Sobrevivió" 
  } else if (Survived[i] == 0 & SibSp[i] == 1){
    Sib[i] = "Un familiar y No Sobrevivió"
  } else if (Survived[i] == 1 & SibSp[i] == 2){
    Sib[i] = "Dos familiares y Sobrevivió"
  } else if (Survived[i] == 0 & SibSp[i] == 2){
    Sib[i] = "Dos familiares y No Sobrevivió"
  } else if (Survived[i] == 1 & SibSp[i] == 3){
    Sib[i] = "Tres familiares y Sobrevivió"
  } else if (Survived[i] == 0 & SibSp[i] == 3){
    Sib[i] = "Tres familiares y No Sobrevivió"
  }else if (Survived[i] == 1 & SibSp[i] > 3){
    Sib[i] = "Cuatro o más familiares y Sobrevivió"
  } else if (Survived[i] == 0 & SibSp[i] > 3){
    Sib[i] = "Cuatro o más familiares y No Sobrevivió"
  }}

SibSp<-as.factor(SibSp)
train$SibSp<-SibSp

#table(Sib)
tabla_sib<- data.frame(Familiares=c("Ningún familiar","Ningún familiar","Un familiar","Un familiar","Dos familiares","Dos familiares","Tres Familiares","Tres Familiares","Cuatro o más familiares","Cuatro o más familiares"), Sobrevivencia=c("Sí","No","Sí","No","Sí","No","Sí","No","Sí","No"),Valor=c(210,398,112,97,13,15,4,12,3,27))


ggplot(data = tabla_sib, aes(x= Familiares, y = Valor, fill = Sobrevivencia))+geom_bar(stat = "identity", position = position_dodge())+theme_minimal()+scale_fill_brewer(palette="Paired")
```

### Parch
Muy similar a SibSo, indica la cantidad de hijos que viajan abordo. Igualmente será tratada como factor. 

El comportamiento es idéntico, entre menos descendencia lleves al viaje más probabilidades tienes de sobrevivir.
```{r,echo=FALSE}
Par<- c()
for( i in 1:length(Parch)){
    if( Survived[i] == 1 & Parch[i] == 0){
    Par[i] = "Ningún hijo y Sobrevivió" 
  } else if (Survived[i] == 0 & Parch[i] == 0){
    Par[i] = "Ningún hijo y No Sobrevivió"
  } else if( Survived[i] == 1 & Parch[i] == 1){
    Par[i] = "Un hijo y Sobrevivió" 
  } else if (Survived[i] == 0 & Parch[i] == 1){
    Par[i] = "Un hijo y No Sobrevivió"
  } else if (Survived[i] == 1 & Parch[i] == 2){
    Par[i] = "Dos hijos y Sobrevivió"
  } else if (Survived[i] == 0 & Parch[i] == 2){
    Par[i] = "Dos hijos y No Sobrevivió"
  } else if (Survived[i] == 1 & Parch[i] == 3){
    Par[i] = "Tres hijos y Sobrevivió"
  } else if (Survived[i] == 0 & Parch[i] == 3){
    Par[i] = "Tres hijos y No Sobrevivió"
  }else if (Survived[i] == 1 & Parch[i] > 3){
    Par[i] = "Cuatro o más hijos y Sobrevivió"
  } else if (Survived[i] == 0 & Parch[i] > 3){
    Par[i] = "Cuatro o más hijos y No Sobrevivió"
  }}

SibSp<-as.factor(SibSp)
train$SibSp<-SibSp

table(Par)
tabla_parch<- data.frame(Hijos=c("Ningún hijo","Ningún hijo","Un hijo","Un hijo","Dos hijos","Dos hijos","Tres hijos","Tres hijos","Cuatro o más hijos","Cuatro o más hijos"), Sobrevivencia=c("Sí","No","Sí","No","Sí","No","Sí","No","Sí","No"),Valor=c(233,445,65,53,40,40,3,2,1,9))


ggplot(data = tabla_parch, aes(x= Hijos, y = Valor, fill = Sobrevivencia))+geom_bar(stat = "identity", position = position_dodge())+theme_minimal()+scale_fill_brewer(palette="Paired")
```

### Fare
La tarifa es el precio de ticket, como esta está intimamente relacionada con la categoría en la que viaja el pasajero, se entiende que entre mayor sea la tarifa que el pasajero a pagado mejores serán sus posibilidades de vivir. Es una variable cuantitativa.

### Embarked
El Titánic sarpó de Southampton (Inglaterra), posteriormente llegó al puerto de Cherburgo (Francia) y finalmente abordó a sus últimos pasajeros en Queenstown (Irlanda). De ahí que las variables (categóricas) sean S, C y Q. Además contiene dos valores faltantes que serán reemplazados por la moda, es decir donde abordaron más pasajeros. 

La mejor relación de sobrevivencia es la de los pasajeros que abordaron en el puerto de Cherburgo.
```{r,echo = FALSE}
Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
for( i in 1:length(Embarked)){
  if (Embarked[i]== ""){
    Embarked[i]<-Mode(Embarked)
  }
}
train$Embarked<-Embarked
Em<- c()
for( i in 1:length(Embarked)){
  if( Survived[i] == 1 & Embarked[i] == "S"){
    Em[i] = "Southampton y Sobrevivió" 
  } else if (Survived[i] == 0 & Embarked[i] == "S"){
    Em[i] = "Southampton y No Sobrevivió"
  } else if (Survived[i] == 1 & Embarked[i] == "C"){
    Em[i] = "Cherburgo y Sobrevivió"
  } else if (Survived[i] == 0 & Embarked[i] == "C"){
    Em[i] = "Cherburgo y No Sobrevivió"
  } else if (Survived[i] == 1 & Embarked[i] == "Q"){
    Em[i] = "Queenstown y Sobrevivió"
  } else if (Survived[i] == 0 & Embarked[i] == "Q"){
    Em[i] = "Queenstown y No Sobrevivió"
  }}

Embarked<-as.factor(Embarked)
train$Embarked<-Embarked

#table(Em)
tabla_embarked<- data.frame(Puerto=c("Southampton","Southampton","Cherburgo","Cherburgo","Queenstown","Queenstown"), Sobrevivencia=c("Sí","No","Sí","No","Sí","No"),Valor=c(219,427,93,75,30,47))

ggplot(data = tabla_embarked, aes(x= Puerto, y = Valor, fill = Sobrevivencia))+geom_bar(stat = "identity", position = position_dodge())+theme_minimal()+scale_fill_brewer(palette="Paired")
```

Como paso adicional, la nueva tabla con los datos faltantes corregidos fue convertido en un csv con el nombre de "clean_data", misma que fue utilizada para el modelo y que se encuentra en la carpeta.

## Modelo
### Regresión logística.
Es un método de regresión que permite estimar la probabilidad de una variable cualitativa binaria en función de una o varias variables.
$Pr(Y_i=1|X_i) = {\frac{exp(\beta_0 + \beta_1X_i + \beta_2X_2 + \beta_3X_3 + \beta_4X_4 + \beta_5X_5)}{1 + exp (\beta_0 + \beta_1X_i + \beta_2X_2 + \beta_3X_3 + \beta_4X_4 + \beta_5X_5)}}$

```{r,echo=FALSE}
train_control<- trainControl(method = "cv",number=10)
logic_model<- train(Survived ~ .,data=train,trControl=train_control,method="glm",family = binomial("logit"))
print(logic_model)
```

### Árboles de Decisión
Los árboles de decisión representan una serie de decisiones y elecciones en forma de árbol. Usan las características de un objeto para decidir en qué clase se encuentra el objeto. Estas clases generalmente se encuentran en las hojas terminales de un árbol de decisión. Los árboles de decisión pueden ser clasificadores binarios o multiclase. Usan múltiples reglas con resultados binarios para formar una serie de comprobaciones que juzgan y dicen la clase de un objeto según sus características. Los árboles de decisión son un ejemplo de algoritmos de divide y vencerás, ya que usan las reglas para dividir los objetos repetidamente hasta que se toma una decisión final.
```{r,echo=FALSE}
tree0<- rpart(Survived~.,data=train)
rpart.plot(tree0)

tree_model<- train(Survived~Pclass+Sex+Age,data=train,trControl=train_control,method="rpart")
print(tree_model)
```

### Máquinas de Soporte Vectorial
Una máquina de vectores de soporte representa objetos de datos como puntos en el espacio. Luego diseña una función que puede dividir el espacio de acuerdo con las clases de salida de destino. SVM usa el conjunto de entrenamiento para trazar objetos en el espacio y ajustar la función que divide el espacio. Una vez finalizada la función, coloca los objetos en diferentes partes del espacio según la clase en la que se encuentren. Los SVM son muy livianos y altamente eficientes en espacios de dimensiones más altas.
```{r,echo=FALSE}
svm<- train(Survived~.,data=train,method="svmLinear",trControl=train_control)
print(svm)
```

## Resultado Final
Con mucha diferencia el mejor resultado fue el de la regresión logística, dando una precisión promedio del 80%. Es por ellos que será utilizado para crear la aplicación.
