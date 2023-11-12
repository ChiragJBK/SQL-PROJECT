--Select *
--From First_Project..CovidDeaths
--order by 3,4

--Select *
--From First_Project..CovidVaccinations$
--order by 3,4

--Select location, date, total_cases, new_cases, total_deaths, population
--From First_Project..CovidDeaths
--order by 1,2

-- TOTAL CASES VS TOTAL DEATHS 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From First_Project..CovidDeaths
WHERE location like '%India%'
order by 1,2


-- TOTAL CASES VS POPULATION 


Select location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
From First_Project..CovidDeaths
WHERE location like '%India%'
order by 1,2


-- LOOKING AT A COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 
Select location, population, MAX(total_cases) as HighestCovidRates, population, MAX((total_cases/population))*100 as HighestInfectionRate
From First_Project..CovidDeaths
group by location, population
order by HighestInfectionRate desc

-- LOOKING AT A COUNTRIES WITH HIGHEST DEATH COUNT 
Select location, MAX(CAST(total_deaths as INT)) as HIGHESTDEATHCOUNT
From First_Project..CovidDeaths
WHERE continent is not null 
group by location 
order by HIGHESTDEATHCOUNT desc

-- CONTINENTS WITH HIGHEST DEATH RATE

Select continent, MAX(CAST(total_deaths as INT)) as HighestDeathCount
From First_Project..CovidDeaths
Where continent is not null
group by continent
order by HighestDeathCount desc

-- GLOBAL NUMBERS 
Select SUM(CAST(new_cases as INT)) as Totalcases, SUM(CAST(new_deaths as INT)) as TotalDeaths, SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
From First_Project..CovidDeaths 
Where continent is not null

-- Population VS New Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as TotalVaccinationsWithDate
From First_Project..CovidDeaths dea
Join First_Project..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null 
order by 2,3 

-- USING CTE FOR POPULATION VS NEW_VACCINATIONS
With PopVsVac (continent, location, date, population, new_vaccinations, TotalVaccinationsWithDate)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as TotalVaccinationsWithDate
From First_Project..CovidDeaths dea
Join First_Project..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3 
)
Select *, (TotalVaccinationsWithDate/population)*100  as VaccinationPercentage
From PopVsVac
order by 2,3

-- TEMP TABLE 
DROP TABLE IF EXISTS #PERCENTPEOPLEVACCIANTED
CREATE TABLE #PERCENTPEOPLEVACCIANTED
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
TotalVaccinationsWithDate numeric
)
INSERT INTO #PERCENTPEOPLEVACCIANTED
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as TotalVaccinationsWithDate
From First_Project..CovidDeaths dea
Join First_Project..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
--Where dea.continent is not null 
--order by 2,3 

Select *, (TotalVaccinationsWithDate/population)*100  as VaccinationPercentage
From #PERCENTPEOPLEVACCIANTED
order by 2,3

Create View PERCENTPEOPLEVACCIANTE as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as INT)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as TotalVaccinationsWithDate
From First_Project..CovidDeaths dea
Join First_Project..CovidVaccinations vac
 ON dea.location = vac.location
 and dea.date = vac.date
Where dea.continent is not null 
--order by 2,3 