SELECT *
  FROM portfolioproject.dbo.CovidDeaths
 WHERE continent is NOT NULL
 ORDER BY 3,4

 --SELECT *
 --  FROM portfolioproject.dbo.CovidVaccinations
 -- ORDER BY 3,4

 SELECT location, date, total_cases, new_cases, total_deaths, population
   FROM portfolioproject.dbo.CovidDeaths
  WHERE continent is NOT NULL
  ORDER BY 1,2

 -- Looking at Total Cases vs Total Deaths for the world
 -- Shows likelihood of dying if you contract covid worldwide
SELECT location, date, total_cases, total_deaths,
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
  FROM portfolioproject.dbo.CovidDeaths
 WHERE continent is NOT NULL
 ORDER BY 1,2

 -- Looking at Total Cases vs Total Deaths for India
 -- Shows likelihood of dying if you contract covid in India
 SELECT location, date, total_cases, total_deaths,
(CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
  FROM portfolioproject.dbo.CovidDeaths
 WHERE lower(location) like 'india' AND continent is NOT NULL
 ORDER BY 1,2

 -- Looking at Total Cases vs Population worldwide
 -- Shows what percentage of population got covid worldwide
 SELECT location, date, total_cases, population,
(NULLIF(CONVERT(float,total_cases),0)/NULLIF(CONVERT(float,population),0))*100 AS PositivityRate
  FROM portfolioproject.dbo.CovidDeaths
  WHERE continent is NOT NULL
 ORDER BY 1,2

 -- Looking at Total Cases vs Population for India
 -- Shows what percentage of population got covid in India
 SELECT location, date, total_cases, population,
(NULLIF(CONVERT(float,total_cases),0)/NULLIF(CONVERT(float,population),0))*100 AS PositivityRate
  FROM portfolioproject.dbo.CovidDeaths
 WHERE lower(location) like 'india' AND continent is NOT NULL
 ORDER BY 1,2

 -- Looking at countries with highest infection rate compared to Population
SELECT location, population, MAX(convert(int,total_cases)) AS HighestInfectionCount,
MAX(CONVERT(float,total_cases)/CONVERT(float,population))*100 AS PositivityRate
  FROM portfolioproject.dbo.CovidDeaths
 --WHERE lower(location) like 'india' AND continent is NOT NULL
 GROUP BY location,population 
 ORDER BY PositivityRate DESC

 -- Let's break things down by continent
 
 SELECT location, MAX(convert(int,total_deaths)) AS TotalDeathCount
  FROM portfolioproject.dbo.CovidDeaths
 WHERE continent is NULL
 GROUP BY location 
 ORDER BY TotalDeathCount DESC

-- Showing the continent with the highest death count per population
SELECT location, MAX(convert(int,total_deaths)) AS TotalDeathCount
  FROM portfolioproject.dbo.CovidDeaths
 WHERE continent is NOT NULL
 GROUP BY location 
 ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT SUM(new_cases) AS newcasesum,SUM(new_deaths) AS newdeathsum,
SUM(nullif(new_deaths,0))/SUM(nullif(new_cases,0))*100 AS DeathPercentage
  FROM portfolioproject.dbo.CovidDeaths
 WHERE continent is NOT NULL
-- GROUP BY date
 ORDER BY 3 desc

 --Looking at Total Population vs Vaccinations
 
 SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
 SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS RollingAvgVaccinated
 FROM portfolioproject.dbo.CovidDeaths AS cd
 JOIN portfolioproject.dbo.CovidVaccinations AS cv
   ON cd.location=cv.location AND cd.date=cv.date
 WHERE cd.continent is NOT NULL
 ORDER BY 1,2,3

 -- USE CTE

 with PopvsVac(Continent, Location, Date, Population,New_Vaccinations, RollingAvgVaccinated)
 AS
 (
 SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
 SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS RollingAvgVaccinated
 FROM portfolioproject.dbo.CovidDeaths AS cd
 JOIN portfolioproject.dbo.CovidVaccinations AS cv
   ON cd.location=cv.location AND cd.date=cv.date
 WHERE cd.continent is NOT NULL
 --ORDER BY 1,2,3
 )

 SELECT *,(RollingAvgVaccinated/Population)*100
   FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingAvgVaccinated numeric
)

 INSERT INTO #PercentagePopulationVaccinated
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
 SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS RollingAvgVaccinated
 FROM portfolioproject.dbo.CovidDeaths AS cd
 JOIN portfolioproject.dbo.CovidVaccinations AS cv
   ON cd.location=cv.location AND cd.date=cv.date
 WHERE cd.continent is NOT NULL
 --ORDER BY 1,2,3

 SELECT *,(RollingAvgVaccinated/Population)*100
   FROM #PercentagePopulationVaccinated 

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
 SUM(CAST(cv.new_vaccinations AS bigint)) OVER (PARTITION BY cd.location order by cd.location,cd.date) AS RollingAvgVaccinated
 FROM portfolioproject.dbo.CovidDeaths AS cd
 JOIN portfolioproject.dbo.CovidVaccinations AS cv
   ON cd.location=cv.location AND cd.date=cv.date
 WHERE cd.continent is NOT NULL
 --ORDER BY 1,2,3

 SELECT *
   FROM PercentPopulationVaccinated
