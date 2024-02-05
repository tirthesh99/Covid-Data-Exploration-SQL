select * 
from coviddeaths -- Table 1- First, we will be exploring this table.
order by 3,4

--select * 
--from covidvaccinations -- Table 2
--order by 3,4

select location, date, total_cases,new_cases, total_deaths, population 
from CovidDeaths
order by 1,2

--------------------------------------------------------------------------------------------------------------------------

--Total cases vs Total deaths --> Death Percentage in United States
--In United states, Death percentage went up to 6% in the mid 2020 and droppped down to just under 2% by the end of 2020. 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
from CovidDeaths
where location like '%states%' 
order by 1,2

--------------------------------------------------------------------------------------------------------------------------

--Total cases vs Population - United States
--Shows what Percentage of population got affected by Covid --> Almost 10 % of US population got Covid till April, 2021
select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
from CovidDeaths
where location like '%states%'
order by 1,2

--------------------------------------------------------------------------------------------------------------------------

--Looking at countries with Highest Infection Rates compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) AS 
MaxPercentPopulationInfected
from CovidDeaths
group by location, population
order by MaxPercentPopulationInfected DESC

--------------------------------------------------------------------------------------------------------------------------

--Countries showing highest Death count per location/country
--US followed by Brazil has the highest death counts dated 2021-04-30 
select location , max(cast(total_deaths AS INT)) as TotalDeathCount
from CovidDeaths
where continent is NOT NULL
group by location
order by TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------

--LETS BREAK THINGS DOWN BY CONTINENT
--Showing continents with the highest death count per population
select continent , max(cast(total_deaths AS INT)) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount DESC

--------------------------------------------------------------------------------------------------------------------------

--GLOBAL NUMBERS
--New deaths vs New cases per day basis
select date , sum(new_cases) AS total_cases, sum(cast(new_deaths AS INT)) As total_deaths, 
(sum(cast(new_deaths AS INT))/ sum(new_cases))*100 as DeathPercentage_Perday
from CovidDeaths
where continent is not NULL
group by date 
order by 1,2

--------------------------------------------------------------------------------------------------------------------------

--Overall Death Percentage across the world is 2.11 % 
select sum(new_cases) AS total_cases, sum(cast(new_deaths AS INT)) As total_deaths, 
(sum(cast(new_deaths AS INT))/ sum(new_cases))*100 as DeathPercentage_world
from CovidDeaths
where continent is not NULL
order by 1,2

--------------------------------------------------------------------------------------------------------------------------

--Joining 2 Tables - CovidDeaths and CovidVaccinations
--We used Partition By location to get rolling vaccination on day basis
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vacination
from CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL 
order by 2,3

---------------------------------------------------------------------------------------------------------------------------

--Using CTE
With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vacination)
AS
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vacination
from CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL 
)
--Percentage of people got vaccinated each day  
select *, (rolling_vacination/population)*100 AS Vaccinated_percentage
from PopvsVac

-------------------------------------------------------------------------------------------------------------------------

--Using TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
( 
continent nvarchar(255), location nvarchar(255), date datetime, Population INT, new_vaccinations INT, rolling_vacination INT
) 

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vacination
from CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL

select *, (rolling_vacination/population)*100 AS Vaccinated_percentage 
from #PercentPopulationVaccinated

-----------------------------------------------------------------------------------------------------------------------

--Creating a VIEW
CREATE VIEW PercentPopulationVaccinated AS 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vacination
from CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
where dea.continent IS NOT NULL

-----------------------------------------------------------------------------------------------------------------------







