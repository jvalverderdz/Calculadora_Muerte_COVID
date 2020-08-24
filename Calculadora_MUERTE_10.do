/*******************************************************************************
Calculadora_MUERTE_10.do
Calculadora de la MUERTE
Autor: Javier Valverde
Versión: 1.0
Insumos:
	-Conexión a Internet

Este do calcula tu probabilidad de muerte si te da Covid, basado en un modelo logístico estimado
con los datos de contagios de Covid de la Secretaría de Salud de México

*******************************************************************************/

clear all
set more off
cls

*La dirección de la carpeta donde guardo los archivos auxiliares
*CAMBIAR SI SE CORRE DESDE OTRA COMPUTADORA
capture mkdir "D:\Javier\Documents\Calculadora Muerte"
gl root = "D:\Javier\Documents\Calculadora Muerte"

*Importamos la base de datos del Covid
*Origen: https://www.gob.mx/salud/documentos/datos-abiertos-152127
*Es necesario descargar y descomprimir: Datos para el 22-08-2020
import delim "$root\200822COVID19MEXICO.csv", clear

drop if resultado == 2	//Quedarnos solo con los positivos

*Generamos variable de si se murió
gen muerte = .
replace muerte = 1 if fecha_def != "9999-99-99"
replace muerte = 0 if muerte == .

*Generamos variable de grupo de edad
gen grupo_edad = .
replace grupo_edad = 1 if edad < 12
replace grupo_edad = 2 if edad >= 12 & edad < 18
replace grupo_edad = 3 if edad >= 18 & edad < 26
replace grupo_edad = 4 if edad >= 26 & edad < 36
replace grupo_edad = 5 if edad >= 36 & edad < 46
replace grupo_edad = 6 if edad >= 46 & edad < 60
replace grupo_edad = 7 if edad >= 60 & edad < 76
replace grupo_edad = 8 if edad >= 76

*Etiquetas para el grupo de edad
label define grupo_edad_labels 1 "Niños: Menores De 12" 2 "Adolescentes: De 12 a 17" 3 "Adultos jóvenes: De 18 a 25" 4 "Chavorrucos: De 26 a 35" 5 "Adultos de 36 a 45" 6 "Adultos rucos: De 46 a 59" 7 "Viejitos de 60 a 75" 8 "Viejitos mayores de 75"
label values grupo_edad grupo_edad_labels

*Reemplazamos valores y etiquetas para variables relevantes
replace obesidad = 0 if obesidad == 2
replace tabaquismo = 0 if tabaquismo == 2
replace asma = 0 if asma == 2
replace hipertension = 0 if hipertension == 2
replace diabetes = 0 if diabetes == 2

replace sexo = 0 if sexo == 2
label define sexo_labels 0 "Hombre" 1 "Mujer"
label values sexo sexo_labels


logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, dydx(*) atmeans post

*Como tabaquismo e hipertensión no son estadísticamente significativas, pero el modelo en su conjunto sí, vamos a dejarlas
*pero no haremos predicciones con ellas

*==============SEGUNDA PARTE: ESTIMACIONES DE PROBABILIDADES====================

*Estimaciones para ellos mismos
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 3) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 3 obesidad = 1) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 3 asma = 1) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 3 obesidad = 1 asma = 1) atmeans post

*Estimaciones para sus papás
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 6 sexo = 0) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 6 sexo = 0 obesidad = 1) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 6 sexo = 0 obesidad = 1 diabetes = 1) atmeans post

*Estimaciones para sus mamás
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 6 sexo = 1) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 6 sexo = 1 obesidad = 1) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 6 sexo = 1 obesidad = 1 diabetes = 1) atmeans post

*Estimaciones para sus tixs
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 7) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 7 obesidad = 1) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 7 diabetes = 1) atmeans post


*Estimaciones para sus abuelitxs
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 8) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 8 obesidad = 1) atmeans post
qui logit muerte sexo i.grupo_edad obesidad tabaquismo asma hipertension diabetes
margins, at(grupo_edad = 8 diabetes = 1) atmeans post
