-- Data Exploration

SELECT * FROM PortfolioProject..covid_deaths
WHERE continent is not null
ORDER BY 3,4


-- Select Data that we are going to be using 

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..covid_deaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Shows likelihood of dying from covid in respective country 
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at total cases vs population
-- Shows percentage of pop got covid
SELECT location,date,population,total_cases, (total_cases/population)*100 AS death_percentage
FROM PortfolioProject..covid_deaths
WHERE location like '%states%'
ORDER BY 1,2

-- What countries have highest infection rates compared to population?

SELECT location,population,MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_pop_infected
FROM PortfolioProject..covid_deaths
GROUP BY location, population
ORDER BY percent_pop_infected DESC

-- Total death count by continent  

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC


-- Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null	
ORDER BY 1,2

-- Join tables 
SELECT *
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
ON dea.location = vac.location
AND	dea.date = vac.date

-- Looking at total pop vs vaccinations
-- USE CTE

With PopvsVac (continent,location,date,population,new_vaccinations,rolling_people_vaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
---, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent is not null
---ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac

-- TEMP Table
DROP TABLE if exists #percent_people_vaccinated
CREATE TABLE #percent_people_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_people_vaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
---, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent is not null
---ORDER BY 2,3
SELECT *, (rolling_people_vaccinated/population)*100
FROM #percent_people_vaccinated


--Creating View to store data for later visualizations
CREATE VIEW percent_people_vaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS rolling_people_vaccinated
---, (rolling_people_vaccinated/population)*100
FROM PortfolioProject..covid_deaths dea
JOIN PortfolioProject..covid_vaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent is not null
---ORDER BY 2,3

SELECT * 
FROM percent_people_vaccinated