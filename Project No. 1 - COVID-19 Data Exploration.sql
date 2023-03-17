--COVID-19 Data Exploration

--Selecting the data with which we are going to start

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--Looking at the total number of cases compared to the U.S. population

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
FROM CovidDeaths
WHERE location LIKE '%States' AND total_cases IS NOT NULL
ORDER BY 1, 2

--Looking at the total number of cases compared to the total number of deaths in the U.S.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location LIKE '%States' AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1, 2

--Looking at the countries with the highest infection rate compared to the population

SELECT location, population, SUM(new_cases) AS infection_count, (SUM(new_cases)/population)*100 AS infection_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_percentage DESC

--Showing the countries with the highest number of deaths

SELECT location, SUM(new_deaths) AS death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY death_count DESC

--Showing the continents with the highest number of deaths

SELECT continent, SUM(new_deaths) AS death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_count DESC

--Looking at total deaths compared to cases worldwide

SELECT SUM(new_deaths) AS world_death_count, SUM(new_cases) AS world_infection_count, (SUM(new_deaths)/SUM(new_cases))*100 AS cases_death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL

--Looking at total deaths compared to population worldwide

SELECT SUM(new_deaths) AS world_death_count,
(SELECT population FROM CovidDeaths WHERE location LIKE 'World' GROUP BY population) AS world_population,
(SUM(new_deaths)/(SELECT population FROM CovidDeaths WHERE location LIKE 'World' GROUP BY population))*100 AS world_death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL

--Looking at the total population and vaccinations

SELECT dea.continent, dea.location, dea.population, SUM(vac.new_vaccinations) AS applied_vaccines
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent, dea.location, dea.population

--Looking at the total population and vaccination count

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_applied_vaccines
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--Looking at the total population compared to applied vaccines using CTE

WITH PopVac (continent, location, date, population, new_vaccinations, rolling_applied_vaccines)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_applied_vaccines
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)

SELECT *, (rolling_applied_vaccines/population)*100 AS applied_vaccines_percentage
FROM PopVac

--Looking at the total population compared to applied vaccines using temporary tables

DROP TABLE IF EXISTS #VaccinatedPopulation

CREATE TABLE #VaccinatedPopulation (
continent varchar(50), location varchar(50), date date, population numeric(18,0),
new_vaccinations numeric(18,0), rolling_applied_vaccines numeric(18,0)
)

INSERT INTO #VaccinatedPopulation
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_applied_vaccines
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *, (rolling_applied_vaccines/population)*100 AS applied_vaccines_percentage
FROM #VaccinatedPopulation

--Dropping a view

DROP VIEW IF EXISTS AppliedVaccines

--Creating a view

CREATE VIEW AppliedVaccines AS

WITH PopVac (continent, location, date, population, new_vaccinations, rolling_applied_vaccines)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_applied_vaccines
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)

SELECT *, (rolling_applied_vaccines/population)*100 AS applied_vaccines_percentage
FROM PopVac