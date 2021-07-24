
--Exploring overall data
SELECT * FROM cov_deaths
ORDER BY 3, 4;

SELECT * FROM cov_vacc
ORDER BY 3, 4;

--Looking at individual location
SELECT location, date, population, total_cases, new_cases, total_deaths FROM cov_deaths
WHERE location = 'India'
ORDER BY 1,2;

-- Percentage of deaths pertaining to infections
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS Death_Percentage FROM cov_deaths
WHERE location = 'India'
ORDER BY 1,2;

-- Percentage of cases pertaining to population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Infected_Percentage FROM cov_deaths
WHERE location = 'India'
ORDER BY 1,2;

-- Looking at Highest infected percentage for every location 
SELECT location, population, MAX(total_cases) AS Highest_Cases, MAX((total_cases/population))*100 AS Infected_Percentage FROM cov_deaths
GROUP BY location, population
ORDER BY Infected_Percentage DESC;

-- Looking at Highest death count per location(country)
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count FROM cov_deaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC;

-- Looking at Highest death count per location(continent)
SELECT location, MAX(cast(total_deaths AS int)) AS total_death_count FROM cov_deaths
WHERE continent is null
GROUP BY location
ORDER BY total_death_count DESC;

-- Worldwide total cases, total deaths and death percentage overall (AKA topline metrics)
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 AS Death_Percentage FROM cov_deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;

-- Using CTE and windows functions for getting a rolling count of total vaccinations
WITH PopVsVacc(Continent, Location, Date, Population, New_vaccinations, Rolling_total_vaccinations)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(INT, vacc.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_total_vaccinations
FROM cov_deaths dea
JOIN cov_vacc vacc ON
dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null
)
SELECT *, (Rolling_total_vaccinations/population)*100
FROM PopVsVacc

--Using alternative temporary table method to acheive the result above
USE Project
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_total_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_total_vaccinations
From cov_deaths dea
Join cov_vacc vacc
	On dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null 
--order by 2,3

Select *, (Rolling_total_vaccinations/Population)*100
From #PercentPopulationVaccinated;

--Creating views for later usage
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CONVERT(INT, vacc.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_total_vaccinations
FROM cov_deaths dea
JOIN cov_vacc vacc ON
dea.location = vacc.location
AND dea.date = vacc.date
WHERE dea.continent is not null;

SELECT * FROM PercentPopulationVaccinated
order by 1,2,3


