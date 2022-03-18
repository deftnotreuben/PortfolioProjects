Select *
From PortfolioProject..CovidDeaths
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths
--Likelyhood of dying if contracted
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
order by 1,2

--Total Cases vs Population
--Total Percentage of Population affected due to Covid
Select location,date,total_cases,population,(total_cases/population)*100 as Covid_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%india%'
order by 1,2


--Highest Infection Percentage

Select location, population, MAX(total_cases) as Highest_infection_Count, MAX((total_cases/population))*100 as Percent_Population_Affected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
group by location, population
order by Percent_Population_Affected desc


--Countries with Highest Death Count

Select location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
where continent is not null
group by location
order by Total_Death_Count desc


--Showing Continents with Highest Death Count
Select continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
where continent is not null
group by continent
order by Total_Death_Count desc


--Showing Total Death Percentage
Select SUM(cast(new_deaths as int)) as Total_New_Deaths, SUM(new_cases) as Total_New_Cases, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as New_Death_Percentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%india%'
where continent is not null
--group by date
order by 1,2


Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as Total_Vac,
(MAX(Total_Vac)/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3


--Population vs Vaccinated CTE
With PopvsVac (continent,location,date,population,new_vaccinations,Total_Vac)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as Total_Vac
--(MAX(Total_Vac)/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and dea.location like '%india%'
--order by 2,3
)
Select *, (Total_Vac/population)*100
FROM PopvsVac



--- Pop vs Vac Temp Table

DROP TABLE if exits #PercentPopVac

CREATE TABLE #PercentPopVac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_Vac numeric
)

Insert into #PercentPopVac
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as Total_Vac
--(MAX(Total_Vac)/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null and dea.location like '%india%'
--order by 2,3

Select *, (Total_Vac/population)*100
FROM #PercentPopVac


DROP View if exists PercentPopVac
Create View PercentPopVac as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as Total_Vac
--(MAX(Total_Vac)/dea.population)*100
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null and dea.location like '%india%'
--order by 2,3

Select *
FROM PercentPopVac

