select * 
from covidportfolio..coviddeath
WHERE continent IS NOT NULL
order by 3,4

--select * 
--from covidportfolio..covidvaccination
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covidportfolio..coviddeath
ORDER BY 1,2

--Likelihood of you dying if you get covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covidportfolio..coviddeath
--WHERE location = 'nigeria'
ORDER BY 1,2

--Percentage of population with Covid
SELECT location, date, population, total_cases,(total_cases/population)*100 AS PercentageWithCovid
FROM covidportfolio..coviddeath
WHERE continent IS NOT NULL
ORDER BY 1,2

--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population)*100) AS PercentageWithCovid
FROM covidportfolio..coviddeath
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY PercentageWithCovid desc

--Shows Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covidportfolio..coviddeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc

--DATA BY CONTINENT
--Death count per continent
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM covidportfolio..coviddeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--Total Daily Deaths accross the World
SELECT date, SUM(total_cases) AS Totalcases, SUM(cast(total_deaths as int)) AS Totaldeaths, SUM(CAST(total_deaths as INT))/SUM(total_cases)*100 AS DeathPercentage
FROM covidportfolio..coviddeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total  Deaths accross the World
SELECT SUM(total_cases) AS Totalcases, SUM(cast(total_deaths as int)) AS Totaldeaths, SUM(CAST(total_deaths as INT))/SUM(total_cases)*100 AS DeathPercentage
FROM covidportfolio..coviddeath
WHERE continent IS NOT NULL
ORDER BY 1,2
--USING CTE
--Total population vs vaccinations

WITH Totalvacinatedpercentage(continent, location, date, population, new_vaccinations,rollingpeoplevaccinated)
AS(
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations as float)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS rollingpeoplevaccinated
FROM covidportfolio..coviddeath de
JOIN covidportfolio..covidvaccination va
	ON de.location = va.location
		AND de.date = va.date
WHERE de.continent IS  NOT NULL
)
SELECT *, (rollingpeoplevaccinated/population)*100 AS Vaccinated
FROM Totalvacinatedpercentage

--USING TEMPORARY TABLE
--Total population vs vaccinations
DROP TABLE IF EXISTS #Totalvacinatedpercentage
CREATE TABLE #Totalvacinatedpercentage
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric,
)
INSERT INTO #Totalvacinatedpercentage
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations as float)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS rollingpeoplevaccinated
FROM covidportfolio..coviddeath de
JOIN covidportfolio..covidvaccination va
	ON de.location = va.location
		AND de.date = va.date
WHERE de.continent IS  NOT NULL

SELECT *, (rollingpeoplevaccinated/population)*100 AS Vaccinated
from #Totalvacinatedpercentage
ORDER BY 2

--CREATING VIEWS

CREATE VIEW Totalvacinatedpercentage AS
SELECT de.continent, de.location, de.date, de.population, va.new_vaccinations, SUM(cast(va.new_vaccinations as float)) OVER (PARTITION BY de.location ORDER BY de.location, de.date) AS rollingpeoplevaccinated
FROM covidportfolio..coviddeath de
JOIN covidportfolio..covidvaccination va
	ON de.location = va.location
		AND de.date = va.date
WHERE de.continent IS  NOT NULL

CREATE VIEW Totaldeaths AS
SELECT SUM(total_cases) AS Totalcases, SUM(cast(total_deaths as int)) AS Totaldeaths, SUM(CAST(total_deaths as INT))/SUM(total_cases)*100 AS DeathPercentage
FROM covidportfolio..coviddeath
WHERE continent IS NOT NULL
