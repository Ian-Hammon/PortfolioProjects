SELECT *
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..Covid_Vaccinations
--order by 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
order by 1,2

-- Looking at the total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
WHERE location like '%states%'
order by 1,2

-- Looking at the total cases versus the population
-- Shows what percentage of population got covid
SELECT location, date,population, total_cases, (total_cases/population)*100 as PopulationPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
WHERE location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to populations

SELECT location, population, MAX (total_cases) as HighestInfectionCount, (MAX(total_cases/population))*100 as PercentofPopulationInfected
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location, population
order by PercentofPopulationInfected desc

-- Showing Countries with highest death rate compared to population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location
order by TotalDeathCount desc

-- Break down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent is null
--WHERE location like '%states%'
GROUP BY location
order by TotalDeathCount desc

-- Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY continent
order by TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location like '%states%'
Group by date
order by 1,2

-- Total World Cases Deaths and Death Percentage

SELECT SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..Covid_Deaths
WHERE continent is not null
--WHERE location like '%states%'
--Group by date
order by 1,2

--Vaccinations

SELECT *
FROM PortfolioProject..Covid_Vaccinations

--Joining the Deaths and Vaccination Tables
SELECT *
FROM PortfolioProject..Covid_Deaths cd
JOIN PortfolioProject..Covid_Vaccinations cv
	ON cd.location=cv.location
	and cd.date=cv.date

-- Looking at Total Population vs Vaccination

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition BY cd.location Order by cd.location, cd.date) as RollingVaccinationCount
FROM PortfolioProject..Covid_Deaths cd
JOIN PortfolioProject..Covid_Vaccinations cv
	ON cd.location=cv.location
	and cd.date=cv.date
WHERE cd.continent is not null
order by 2,3

-- Using a CTE

With PopvsVacc(continent, location, date, population, new_vaccinations, RollingVaccinationCount)
as
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition BY cd.location Order by cd.location,
cd.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..Covid_Deaths cd
JOIN PortfolioProject..Covid_Vaccinations cv
	ON cd.location=cv.location
	and cd.date=cv.date
WHERE cd.continent is not null
--order by 2,3
)
SELECT*, (RollingVaccinationCount/population)*100 as VaccinationPercentage
FROM PopvsVacc 



-- Using a Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinationCount numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition BY cd.location Order by cd.location,
	cd.date) as RollingVaccinationCount
-- , (RollingVaccinationCount/population)*100
FROM PortfolioProject..Covid_Deaths cd
JOIN PortfolioProject..Covid_Vaccinations cv
	ON cd.location = cv.location
	and cd.date = cv.date
-- WHERE cd.continent is not null
-- order by 2,3

SELECT*, (RollingVaccinationCount/population)*100 as VaccinationPercentage
FROM #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations

CREATE View PopvsVacc as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition BY cd.location Order by cd.location,
cd.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..Covid_Deaths cd
JOIN PortfolioProject..Covid_Vaccinations cv
	ON cd.location=cv.location
	and cd.date=cv.date
WHERE cd.continent is not null
-- order by 2,3




