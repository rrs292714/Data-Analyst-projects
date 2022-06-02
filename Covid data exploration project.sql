Select * 
FROM PortfolioProject..CovidDeaths
Order by 3,4

--Select * 
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject..CovidDeaths


--Total deaths VS Total cases

Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%ndia%'


--Total cases vs Population

Select location, date, population, total_cases,(total_cases/population)*100 as PrecentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%ndia%'


--Looking at Countries with highest Infection Rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location,population
order by PercentPopulationInfected desc


--Countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc


-- Total death per continent

Select location, Max(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
Where continent is  null
Group by location
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as Total_cases,SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null


--Vaccination Table

Select *
From PortfolioProject..CovidVaccinations

--Joining both table on location and date

Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date

 --Total population vs total vaccination of all countries
 Select dea.location,dea.population,MAX(cast(vac.total_vaccinations as int)) as Total_vaccination
 From PortfolioProject..CovidDeaths dea
 join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 Group by dea.location,dea.population
 Order by 3 desc

 --CTE

 with popvsvac(continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
 as
 (
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null
 )
 select *,(RollingPeopleVaccinated/population)*100 
 from popvsvac


 --TEMP TABLE

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
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 select *,(RollingPeopleVaccinated/population)*100 
 from #PercentPopulationVaccinated



 --creating view 

 CREATE VIEW 
 PercentPopulationVaccinated as
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(Convert(int,vac.new_vaccinations))
over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent is not null

 SELECT * FROM PercentPopulationVaccinated