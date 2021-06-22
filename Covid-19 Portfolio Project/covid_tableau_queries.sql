
-- Queries that were used for my Tableau Dashboard
-- Tableau Table 1 Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..covid_deaths
WHERE continent is not null	
ORDER BY 1,2

-- Tableau Table 2 Total Deaths by Continent 
SELECT location, SUM(cast(new_deaths as int)) as total_death_count
FROM PortfolioProject..covid_deaths
WHERE continent is null
AND location not in ('World','European Union','International')
GROUP BY location
ORDER BY total_death_count DESC

--Tableau Table 3 Percent of Pop. Infected by Country

SELECT location,population,MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_pop_infected
FROM PortfolioProject..covid_deaths
GROUP BY location, population
ORDER BY percent_pop_infected DESC

-- Tableau Table 4 Percent of Pop Infected Time Series
SELECT location,population,date,MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_pop_infected
FROM PortfolioProject..covid_deaths
GROUP BY location, population, date
ORDER BY percent_pop_infected DESC

