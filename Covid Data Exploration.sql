/*
Covid 19 Data Exploration 
Date range: 2020/01/01 - 2023/03/07
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM covid_db.deaths;

SELECT *
FROM covid_db.vaccinations;

SELECT *
FROM covid_db.deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


-- Select data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_db.deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM covid_db.deaths
#WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM covid_db.deaths
#WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM covid_db.deaths
#WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths AS FLOAT)) AS TotalDeathCount
FROM covid_db.deaths
#WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population

SELECT continent, SUM(new_deaths) AS TotalDeathCount
FROM covid_db.deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_Cases)*100 AS DeathPercentage
FROM covid_db.deaths
#WHERE location like '%states%'
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    # , (RollingPeopleVaccinated/population)*100
FROM covid_db.deaths dea
JOIN covid_db.vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;


-- Using CTE to perform Calculation on Partition BY in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid_db.deaths dea
JOIN covid_db.vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
`Date` DATE,
Population BIGINT,
New_vaccinations BIGINT,
RollingPeopleVaccinated FLOAT
);

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid_db.deaths dea
JOIN covid_db.vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
#WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopVac AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM covid_db.deaths dea
JOIN covid_db.vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopVac;

