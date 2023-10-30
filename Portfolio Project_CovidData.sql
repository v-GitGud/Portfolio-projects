SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS DeathPercentage
from PortfolioProject..covidDeaths
order by 1,2

-- Total Cases vs Population

SELECT location, date, total_cases, population,
(CONVERT(FLOAT, population) / NULLIF(CONVERT(FLOAT, total_cases),0)) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%serbia%'
ORDER BY 1,2

SELECT location, date, total_cases, population, (CONVERT(FLOAT,total_cases)/ NULLIF(CONVERT(FLOAT, population),0)) *100 as PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%serbia%'
ORDER BY 1,2

-- Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CONVERT(FLOAT,total_cases)/ NULLIF(CONVERT(FLOAT, population),0))) *100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentOfPopulationInfected desc


--SELECT location, population, MAX(total_cases), MAX((CONVERT(FLOAT,total_cases) / NULLIF(CONVERT(FLOAT,population), 0)))*100
--FROM PortfolioProject..CovidDeaths
--GROUP BY location, population
--ORDER BY 1,2

-- BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Countries with the highest death count per population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers

SELECT SUM(new_cases)AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY DeathPercentage


-- total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated 
AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated