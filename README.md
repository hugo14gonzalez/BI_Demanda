# BI_Demanda
Business intelligence para analizar la demanda de energía eléctrica
Business intelligence to analyze the demand for electrical energy

Proyecto de grado para optar el título de Ingeniero de sistemas. 
Universidad Uniremington - Colombia - Año 2020

# RESUMEN
La demanda y pérdidas de energía eléctrica son variables muy importantes para los agentes del mercado de energía eléctrica. Para enfrentar este problema fue creada una solución de Business intelligence (BI). La metodología fue basada en la “arquitectura bus” definida por Kimball, y fue construida una solución de software para analizar la información histórica de demanda y pérdidas de energía eléctrica.

El software construido es un data warehouse (DW) con un solo modelo estrella con las métricas de demanda y pérdidas de energía. Los datos para el sistema fueron facilitados por la empresa XM que coordina el mercado de energía eléctrica en Colombia. fueron creadas ETLs para cargar el DW y procesar los cubos OLAP. Fueron creados reportes tipo dashboar y gráficos y una aplicación web. También fue incluido bitácora para seguimiento a los procesos de carga y utilidades para la carga del sistema. Las herramientas seleccionadas fueron Microsoft SQL Server para la base de datos DW, cubos OLAP y reportes Reporting Services, y para la aplicación web Visual Studio .Net. También fueron empleados otros frameworsk como Bootstrap, JQuery y JavaScript. El proyecto incluye el código construido, manuales de instalación y operación.

El proyecto realiza un recorrido explicando la construcción de cada uno de los artefactos de la “arquitectura bus” para BI. El modelo estrella representa las “preguntas del negocio”, pero para que el proyecto de BI sea exitoso, es decir “que el usuario lo use” es porque le ofrece “lo que necesita”. El BI tiene desafíos como la calidad de datos y el desempeño, para enfrentar estos retos fue realizado un buen diseño de ETLs y cubos, e incluidos aspectos como bitácora para seguimiento a la carga de procesos, particiomiento de tablas y cubos, y utilidades para la carga diaria en forma automática y recarga de datos históricos.

# PALABRAS CLAVES
BI, business intelligence, inteligencia de negocios, bodega de datos, ETL, demanda, energía eléctrica.

# ABSTRACT
The demand and losses of electrical energy are very important variables for the agents of the electrical energy market. To deal with this problem, a Business intelligence (BI) solution was created. The methodology was based on the “bus architecture” defined by Kimball, and a software solution was built to analyze the historical information on demand and losses of electrical energy.

The built software is a data warehouse (DW) with a single star model with the metrics of demand and energy losses. The data for the system was provided by the XM company that coordinates the electricity market in Colombia. ETLs were created to load the DW and process the OLAP cubes. Dashboar reports and graphs and a web application were created. A bitacora was also included to track the loading processes and utilities for loading the system. The selected tools were Microsoft SQL Server for the DW database, OLAP cubes and Reporting Services reports, and for the web application Visual Studio .Net. Other frameworsk as Bootstrap, JQuery and JavaScript were also used. The project includes the built code, installation and operation manuals.

The project takes a tour explaining the construction of each of the artifacts of the "bus architecture" for BI. The star model represents the “business questions”, but for the BI project to be successful, that is, “for the user to use” it is because it offers what they need. The BI has challenges such as data quality and performance, in order to face these challenges, a good design of ETLs and cubes was carried out, and included aspects as bitacora for monitoring process loading, participation of tables and cubes, and utilities for the daily automatic loading and reloading of historical data.

# KEY WORDS
Business intelligence, data warehouse, ETL, demand, electric energy.
