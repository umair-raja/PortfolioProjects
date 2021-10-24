-- Exploring Global Covid Data from: https://ourworldindata.org/covid-deaths
-- Covid Data from Jan 28,2020 - Oct 22, 2021
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


SELECT 
	*
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4


-- Select Data to use

SELECT  
	Location,
	Date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM
	PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths in Canada
-- Shows liklihood of dying if you contract covid in Canada
SELECT  
	Location,
	Date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 AS DeathPercentage
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2


-- Looking at Total Cases vs Population in Canada
-- Shows percentage of population that has contracted Covid 
SELECT  
	Location,
	Date,
	population,
	total_cases,
	(total_cases/population) * 100 AS PercentPopulationInfected
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE location like '%Canada%'
and continent is not null
ORDER BY 1,2


-- Looking at countries with Highest Infection Rate compared to Population
SELECT  
	Location,
	population,
	MAX(total_cases) AS HighestInfectionCount,
	MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM
	PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
SELECT  
	Location,
	MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Showing Continents with Highest Death Count per Population
SELECT  
	continent,
	MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE continent is  not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers (Total Cases, Total Deaths, Death Percentage)
SELECT 
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as int)) AS total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM
	PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 1,2



-- Looking at Total Population vs Vaccinations
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
---	(RollingPeopleVaccinated/population)*100 
FROM
	PortfolioProject.dbo.CovidDeaths AS dea
	JOIN PortfolioProject.dbo.CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- USE CTE 
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
---	(RollingPeopleVaccinated/population)*100 
FROM
	PortfolioProject.dbo.CovidDeaths AS dea
	JOIN PortfolioProject.dbo.CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT
	*,
	(RollingPeopleVaccinated/Population)*100 
FROM
	PopvsVac



-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProject.dbo.CovidDeaths AS dea
	JOIN PortfolioProject.dbo.CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null 

SELECT
	*,
	(RollingPeopleVaccinated/Population)*100 
FROM
	#PercentPopulationVaccinated


-- Creating View to Store Data for Visualization
Create View PercentPopulationVaccinated AS 
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
	PortfolioProject.dbo.CovidDeaths AS dea
	JOIN PortfolioProject.dbo.CovidVaccinations AS vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null 



