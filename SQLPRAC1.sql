Select * FROM SQLPRA.dbo.[Covid Death]
WHERE continent is not null
ORDER by 3,4

--Select * FROM SQLPRA.dbo.[Covid Vaccination]
--ORDER by 3,4

-- select data that i will be using

select location, date, total_cases, new_cases, total_deaths, population
From SQLPRA.dbo.[Covid Death]
order by 1, 2

---Looking at the total death, total deaths
---Shows Likeliyhood of dying if you contraact  covid in your country

SELECT location, date, total_cases, total_deaths, 
    CASE 
        WHEN CAST(total_cases AS FLOAT) = 0 THEN 0 
        ELSE (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 
    END AS DeathPercentage
FROM 
    SQLPRA.dbo.[Covid Death]
WHERE 
    location LIKE '%kenya%'
ORDER BY 1, 2

-- looking at total Cases Vs Populaton
-- show what percentage of population got covid

SELECT location, date, population, total_cases, 
    CASE 
        WHEN CAST(population AS FLOAT) = 0 THEN 0 
        ELSE (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 
    END AS InfectionPercentage
FROM 
    SQLPRA.dbo.[Covid Death]
ORDER BY 1, 2

-- Looking at country  with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfection, 
    CASE 
        WHEN CAST(population AS FLOAT) = 0 THEN 0 
        ELSE MAX( (CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100)
    END AS InfectionPercentage
FROM 
    SQLPRA.dbo.[Covid Death]
ORDER BY 1, 2

SELECT location, population, MAX(total_cases) AS HighestInfection, 
    CASE 
        WHEN CAST(population AS FLOAT) = 0 THEN 0 
        ELSE MAX((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100) 
    END AS PercentagePopulationInfected
FROM 
    SQLPRA.dbo.[Covid Death]
GROUP BY 
    location, 
    population
ORDER BY PercentagePopulationInfected desc

-- Showing country with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM SQLPRA.dbo.[Covid Death]
Where continent IS NOT NULL
GROUP BY  location
ORDER BY TotalDeathCount DESC;

-- In Continet

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM SQLPRA.dbo.[Covid Death]
Where continent IS NULL
GROUP BY  continent
ORDER BY TotalDeathCount DESC;

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM SQLPRA.dbo.[Covid Death]
WHERE continent IS NOT NULL
GROUP BY continent  -- Grouping by continent
ORDER BY TotalDeathCount DESC;

--Global Number.

SELECT date, total_cases, total_deaths, 
    CASE 
        WHEN CAST(total_cases AS FLOAT) = 0 THEN 0 
        ELSE (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100 
    END AS DeathPercentage
FROM 
    SQLPRA.dbo.[Covid Death]
WHERE 
    continent is not null
ORDER BY 1, 2

SELECT 
    SUM(CAST(new_cases AS BIGINT)) AS total_case, 
    SUM(CAST(new_deaths AS BIGINT)) AS total_deaths, 
    (SUM(CAST(new_deaths AS BIGINT)) * 100.0 / NULLIF(SUM(CAST(new_cases AS BIGINT)), 0)) AS DeathPercentage
FROM 
    SQLPRA.dbo.[Covid Death]
WHERE 
    continent IS NOT NULL
ORDER BY 
    total_case, total_deaths;

	-- LOOKING AT THE TOTAL POPULATION Vs Vaccination

SELECT *
FROM SQLPRA.dbo.[Covid Death] dea
JOIN SQLPRA.dbo.[Covid Vaccination] vac
on dea.location = vac.location
and dea.date = vac.date;

--SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
--, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location)
--FROM SQLPRA.dbo.[Covid Death] dea
--JOIN SQLPRA.dbo.[Covid Vaccination] vac
--on dea.location = vac.location
--and dea.date = vac.date
--Where dea.continent is not null
--order by continent;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) AS total_vaccinations
FROM 
    SQLPRA.dbo.[Covid Death] dea
JOIN 
    SQLPRA.dbo.[Covid Vaccination] vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.continent;

--- USE CTE  

WITH PoPvsVac (continent, Location, Date, Population, new_vaccinations, total_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) AS total_vaccinations
FROM 
    SQLPRA.dbo.[Covid Death] dea
JOIN 
    SQLPRA.dbo.[Covid Vaccination] vac
ON 
    dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
--ORDER BY 
--    dea.continent
)
SELECT * , (total_vaccinations/Population)*100
FROM PoPvsVac

---Correct Querly-- 

WITH PoPvsVac (continent, location, date, population, new_vaccinations, total_vaccinations) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
    FROM 
        SQLPRA.dbo.[Covid Death] dea
    JOIN 
        SQLPRA.dbo.[Covid Vaccination] vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *
FROM PoPvsVac
ORDER BY continent;

WITH PoPvsVac (continent, location, date, population, new_vaccinations, total_vaccinations) AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS total_vaccinations
    FROM 
        SQLPRA.dbo.[Covid Death] dea
    JOIN 
        SQLPRA.dbo.[Covid Vaccination] vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)
SELECT *
FROM PoPvsVac
ORDER BY continent;

--- TEMP Table

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
total_vaccitation numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) AS total_vaccinations
FROM 
    SQLPRA.dbo.[Covid Death] dea
JOIN 
    SQLPRA.dbo.[Covid Vaccination] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 
--    dea.continent

SELECT * , (total_vaccinations/Population)*100
FROM #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR VISUALIZATION
-- Work Table --

Create View  PercentPopulatonVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) AS total_vaccinations
FROM SQLPRA.dbo.[Covid Death] dea
JOIN SQLPRA.dbo.[Covid Vaccination] vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY dea.continent

select *
FROM PercentPopulatonVaccinated