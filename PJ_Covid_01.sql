SELECT *
FROM portfolioproject.modcoviddeaths
ORDER BY 3,4;

--SELECT *
--FROM portfolioproject.modcovidvaccinations
--ORDER BY 3,4;

--Data Selection:

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.modcoviddeaths
ORDER BY 1,2;

-- Looking at Total Cases Vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM portfolioproject.modcoviddeaths
WHERE location LIKE '%Pakistan%'
ORDER BY 1,2;

-- Looking at Total Cases Vs Population
-- Shows what percentage of population contracted covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS casesperpopulation
FROM portfolioproject.modcoviddeaths
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM portfolioproject.modcoviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;
 
-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS DECIMAL)) AS totaldeathcount
FROM portfolioproject.modcoviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

-- Lets break things down by continent
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS DECIMAL)) AS totaldeathcount
FROM portfolioproject.modcoviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC;

-- Global Numbers 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)* 100 AS DeathPercentage
FROM portfolioproject.modcoviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Joining together two tables 

SELECT *
FROM portfolioproject.modcoviddeaths dea
JOIN portfolioproject.modcovidvaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

-- Looking at Total Population vs Vaccicated Population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_people_vaccinated_till_date
FROM portfolioproject.modcoviddeaths dea
JOIN portfolioproject.modcovidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = VAC.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- USE CTE

WITH PopvsVAC (continent, location, date, population, new_vaccinations, total_people_vaccinated_till_date)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_people_vaccinated_till_date
FROM portfolioproject.modcoviddeaths dea
JOIN portfolioproject.modcovidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = VAC.date
WHERE dea.continent IS NOT NULL
)
Select *, (total_people_vaccinated_till_date/Population)*100 as PercentageVacinated
From PopvsVac;


-- Temp Table

DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_people_vaccinated_till_date numeric
);

INSERT IGNORE INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, STR_TO_DATE(dea.date, "%m/%d/%Y"), dea.population, CAST(vac.new_vaccinations AS DECIMAL), 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_people_vaccinated_till_date
FROM portfolioproject.modcoviddeaths dea
JOIN portfolioproject.modcovidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = VAC.date
WHERE dea.continent IS NOT NULL;

Select *, (total_people_vaccinated_till_date/Population)*100 as PercentageVacinated
From PercentPopulationVaccinated;

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, STR_TO_DATE(dea.date, "%m/%d/%Y"), dea.population, CAST(vac.new_vaccinations AS DECIMAL), 
SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_people_vaccinated_till_date
FROM portfolioproject.modcoviddeaths dea
JOIN portfolioproject.modcovidvaccinations vac
	ON dea.location = vac.location
    AND dea.date = VAC.date
WHERE dea.continent IS NOT NULL;