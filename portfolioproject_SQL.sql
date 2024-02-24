USE [PORTFOLIOPROJECTDB]

--QUERYING THE BASIC COVIDE DEATH INFORMATION FROM COVID DEATH TABLE
--SELECT * 
--FROM PORTFOLIOPROJECTDB..COVIDDEATHS
--WHERE CONTINENT !=''
--ORDER BY 3,4


--SELECT *
--FROM PORTFOLIOPROJECTDB..COVIDVACCINATIONS
--ORDER BY 3,4

--TOTAL DATASET WE ARE CONSIDERING FOR DATA ANALYSIS FROM COVIDDEATHS TABLE
--SELECT LOCATION,DATE,TOTAL_CASES,NEW_CASES,TOTAL_DEATHS,POPULATION
--FROM PORTFOLIOPROJECTDB..COVIDDEATHS
--ORDER BY LOCATION,DATE ASC

--LOOKING AT TOTALCASES VS DEATHS (PERCENATGE OF DEATH) = (DEATHS/AFFECTED [I.E TOTAL CASES] )
--SHOWS THE LIKELIHOOD OF DIEING IF YOU COME IN CONTRACT OF COVID IN YOUR COUNTRY(ACCORDING TO THE DATA PROVIDED)

SELECT LOCATION, DATE , TOTAL_CASES, NEW_CASES, TOTAL_DEATHS, (TOTAL_DEATHS/TOTAL_CASES)*100 AS DEATHPERCENTAGE
FROM PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE LOCATION LIKE '%INDIA%' AND CONTINENT !=''
ORDER BY LOCATION, DATE ASC

--LOOKING AT THE TOTAL CASES VS POPULATION--
--SHOWS WHAT % OF POPULATION GOT COVID--

SELECT LOCATION, DATE, TOTAL_CASES, POPULATION, (TOTAL_CASES/POPULATION)*100 AS COVIDAFFECTEDPOPULATION
FROM PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE LOCATION LIKE '%INDIA%' AND CONTINENT !=''
ORDER BY LOCATION, DATE

--FINDINGS:: 1% OF TOTALPOPULATION OF INDIA GETS AFFECTED ON 13-0-2021

---WHAT COUNTRY HAS THE HIGHEST INFECTION RATE?
---MAXIMUM INFECTION RATE = MAX( TOTAL_CASES / POPULATION )


SELECT LOCATION, MAX(TOTAL_CASES) AS HIGHESTINFECTEDCOUNT, POPULATION, MAX( TOTAL_CASES / POPULATION )*100 AS INFECTEDPERCENTAGE
FROM
PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE CONTINENT !=''
GROUP BY LOCATION, POPULATION
ORDER BY INFECTEDPERCENTAGE DESC
ORDER BY LOCATION

--NOW LETS FIND THE MAXIMUM DEATHS PER COUNTRY AND HIGHEST DEATHPERCENTAGE(PER COUNTRY)

--SELECT * FROM PORTFOLIOPROJECTDB..COVIDDEATHS

SELECT LOCATION, MAX(CAST(TOTAL_DEATHS AS INT)) AS HIGHESTDEATHCOUNTS, POPULATION, MAX(CAST(TOTAL_DEATHS AS INT)/POPULATION)*100 DEATHPERCENTAGE 
FROM 
PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE CONTINENT !=''
GROUP BY LOCATION, POPULATION
ORDER BY HIGHESTDEATHCOUNTS DESC

--LET'S HAVE A LOOK AT THE DEATH RATES PER CONTINENT

SELECT CONTINENT, MAX(CAST(TOTAL_DEATHS AS INT)) AS TOTALDEATHCOUNTPERCONTINENT
FROM PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE CONTINENT !=''
GROUP BY CONTINENT
ORDER BY TOTALDEATHCOUNTPERCONTINENT DESC


----SHOWING EVERYTGHING GLOBALLY
---SUM OF TOTAL NEW CASES REGISTERED ACROSS THE GLOBE

SELECT DATE, SUM(NEW_CASES) AS NEWCASES
FROM
PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE CONTINENT != ''
GROUP BY DATE
ORDER BY DATE, NEWCASES

--SUM OF TOTAL CASES AND TOTAL DEATHS ACROSS THE GLOBE ORDERED BY DEATH


SELECT DATE, SUM(CAST(NEW_CASES AS INT)) AS NEWCASESREGISTERED, SUM(CAST(TOTAL_DEATHS AS INT)) AS NEWDEATHSREGISTERED
FROM PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE CONTINENT != ''
GROUP BY DATE
ORDER BY DATE, NEWCASESREGISTERED, NEWDEATHSREGISTERED

---SHOWING NEW_CASES, NEW_DEATHS, DEATHPERCENTAGE GLOBALLY

SELECT DATE, SUM(CAST(NEW_CASES AS INT)) AS NEWCASECOUNT ,SUM(CAST(NEW_DEATHS AS INT)) AS NEWDEATHCOUNT, SUM(CAST(NEW_DEATHS AS INT))/ SUM((NEW_CASES))* 100 AS DEATHPERCENTAGE
FROM PORTFOLIOPROJECTDB..COVIDDEATHS
WHERE CONTINENT !=''
GROUP BY DATE
ORDER BY DATE, NEWCASECOUNT, NEWDEATHCOUNT, DEATHPERCENTAGE

--- SHOWING TOTAL DEATHS/ TOTAL CASES/ TOTAL DEATH PERCENTAGE GLOBALLY


SELECT SUM(NEW_CASES) AS TOTALCASES, SUM(CAST(NEW_DEATHS AS INT)) AS TOTALDEATHS, SUM(CAST(NEW_DEATHS AS INT)) / SUM(NEW_CASES)* 100 AS DEATHPERCENATAGE
FROM PORTFOLIOPROJECTDB..COVIDDEATHS
ORDER BY
TOTALCASES, TOTALDEATHS, DEATHPERCENATAGE


----------------------------------------------------------

--LOOKING AT TOTAL POPULATION VS VACCINATION
--GIVEN WE HAVE TWO SET OF TABLES COVIDDEATHS(WE GET TOTAL POPULATION FROM HERE) & COVIDVACCINATIONS TABLE (WE JOIN TOTAL VACCINATEDCOUNT FROM HERE)

SELECT DEA.DATE,SUM(DEA.POPULATION) AS TOTALPOPULATION,SUM(CAST(VAC.NEW_VACCINATIONS AS INT)) AS TOTALVACCINATED, SUM(CAST(VAC.NEW_VACCINATIONS AS INT))/SUM(DEA.POPULATION) *100 as VACCINATIONPERCENTAGE
FROM
PORTFOLIOPROJECTDB..COVIDDEATHS AS DEA
FULL OUTER JOIN PORTFOLIOPROJECTDB..COVIDVACCINATIONS AS VAC
ON DEA.LOCATION = VAC.LOCATION AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT !=''
GROUP BY DEA.DATE
ORDER BY DEA.DATE

--SELECT * FROM PORTFOLIOPROJECTDB..COVIDDEATHS AS DEA


--LOOKING AT VACCINATION PER CONTINENT

SELECT DEA.LOCATION AS CONTINENT, DEA.DATE AS DATE, DEA.POPULATION AS POPULATION, CONVERT(INT,VAC.NEW_VACCINATIONS) AS NEWLYVACCINATED ,
SUM(CAST(VAC.NEW_VACCINATIONS AS INT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE )AS TOTALROLLINGCOUNT,
SUM(CAST(VAC.NEW_VACCINATIONS AS INT)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION, DEA.DATE ) / DEA.POPULATION * 100 AS VACCINATION_PERCENTAGE
FROM PORTFOLIOPROJECTDB..COVIDDEATHS AS DEA
FULL OUTER JOIN PORTFOLIOPROJECTDB..COVIDVACCINATIONS AS VAC
	ON DEA.LOCATION = VAC.LOCATION
	AND DEA.DATE = VAC.DATE
	WHERE DEA.CONTINENT !=''
ORDER BY DEA.LOCATION, DEA.DATE

--NOW BY USING CTE

WITH POPVSVAC
( LOCATION_NAME, DATE_RECORDED, TOTAL_POPULATION, NEWLYVACCINATED_COUNT, ROLLINGVACCINE_COUNT)
AS
(
SELECT DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,
SUM(CONVERT(INT,NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE)
FROM PORTFOLIOPROJECTDB..COVIDDEATHS AS DEA
FULL OUTER JOIN PORTFOLIOPROJECTDB..COVIDVACCINATIONS AS VAC
ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT!=''
)

SELECT *, ROLLINGVACCINE_COUNT/TOTAL_POPULATION * 100 AS PERCENTOFPOPUALTIONVACCINATED FROM POPVSVAC
ORDER BY LOCATION_NAME, DATE_RECORDED


--NOW BY USING TEMPTABLE
DROP TABLE IF EXISTS #PERCENTOFPOPULATIONVACCINATED
CREATE TABLE #PERCENTOFPOPULATIONVACCINATED
(
LOCATION_NAME NVARCHAR(255), 
DATE_RECORDED DATE, 
TOTAL_POPULATION INTEGER, 
NEWLYVACCINATED_COUNT INTEGER, 
ROLLINGVACCINE_COUNT INTEGER
)
INSERT INTO #PERCENTOFPOPULATIONVACCINATED
SELECT DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,
SUM(CONVERT(INT,NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE)
FROM PORTFOLIOPROJECTDB..COVIDDEATHS AS DEA
FULL OUTER JOIN PORTFOLIOPROJECTDB..COVIDVACCINATIONS AS VAC
ON DEA.LOCATION = VAC.LOCATION
AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT!=''

SELECT * 
FROM #PERCENTOFPOPULATIONVACCINATED


--CREATING VIEW FOR VISUALISATION OF DATA

--CREATE VIEW PERCENTOFPOPULATIONVACCINATED
--AS
--(
--SELECT DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,
--SUM(CONVERT(INT,NEW_VACCINATIONS)) OVER (PARTITION BY DEA.LOCATION ORDER BY DEA.LOCATION,DEA.DATE) AS ROLLINGVACCINE_COUNT
--FROM PORTFOLIOPROJECTDB..COVIDDEATHS AS DEA
--FULL OUTER JOIN PORTFOLIOPROJECTDB..COVIDVACCINATIONS AS VAC
--ON DEA.LOCATION = VAC.LOCATION
--AND DEA.DATE = VAC.DATE
--WHERE DEA.CONTINENT!=''
--)

SELECT * FROM PERCENTOFPOPULATIONVACCINATED