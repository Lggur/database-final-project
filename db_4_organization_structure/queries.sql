USE organization_structure;

-- Задача 1
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM 
    	Employees
    WHERE 
    	EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM 
    	Employees e
    INNER JOIN
    	employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
)
SELECT
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    NULLIF(GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', '), '') AS ProjectNames,
    NULLIF(GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', '), '') AS TaskNames
FROM 
	employee_hierarchy eh
LEFT JOIN 
	Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN
	Roles r ON eh.RoleID = r.RoleID
LEFT JOIN
	Projects p ON p.DepartmentID = eh.DepartmentID
LEFT JOIN 
	Tasks t ON t.AssignedTo = eh.EmployeeID
GROUP BY
    eh.EmployeeID,
    eh.Name,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName
ORDER BY 
	eh.Name;
	
-- Задача 2
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM 
    	Employees
    WHERE 
    	EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM 
    	Employees e
    INNER JOIN 
    	employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
),
subordinates AS (
    SELECT
        e.ManagerID AS EmployeeID,
        COUNT(e.EmployeeID) AS SubordinateCount
    FROM
    	Employees e
    INNER JOIN 
    	employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
    GROUP BY
    	e.ManagerID
)

SELECT
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    NULLIF(GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', '), '') AS ProjectNames,
    NULLIF(GROUP_CONCAT(DISTINCT t.TaskName   ORDER BY t.TaskName   SEPARATOR ', '), '') AS TaskNames,
    COUNT(DISTINCT t.TaskID) AS TotalTasks,
    COALESCE(s.SubordinateCount, 0) AS TotalSubordinates
FROM 
	employee_hierarchy eh
LEFT JOIN 
	Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN 
	Roles r ON eh.RoleID = r.RoleID
LEFT JOIN 
	Projects p ON p.DepartmentID = eh.DepartmentID
LEFT JOIN 
	Tasks t ON t.AssignedTo = eh.EmployeeID
LEFT JOIN 
	subordinates s ON s.EmployeeID = eh.EmployeeID
GROUP BY
    eh.EmployeeID,
    eh.Name,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    s.SubordinateCount
ORDER BY
	eh.Name;

-- Задача 3
WITH RECURSIVE employee_hierarchy AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        e.EmployeeID AS RootManagerID
    FROM
    	Employees e
    INNER JOIN 
    	Roles r ON e.RoleID = r.RoleID
    WHERE
    	r.RoleName = 'Менеджер'

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        eh.RootManagerID
    FROM
    	Employees e
    INNER JOIN 
    	employee_hierarchy eh ON e.ManagerID = eh.EmployeeID
),
subordinates AS (
    SELECT
        RootManagerID AS EmployeeID,
        COUNT(EmployeeID) AS SubordinateCount
    FROM 
    	employee_hierarchy
    WHERE
    	EmployeeID <> RootManagerID  
    GROUP BY
    	RootManagerID
)
SELECT
    e.EmployeeID,
    e.Name,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    NULLIF(GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', '), '') AS ProjectNames,
    NULLIF(GROUP_CONCAT(DISTINCT t.TaskName   ORDER BY t.TaskName   SEPARATOR ', '), '') AS TaskNames,
    s.SubordinateCount AS TotalSubordinates
FROM
	Employees e
INNER JOIN 
	Roles r ON e.RoleID = r.RoleID
INNER JOIN 
	subordinates s ON s.EmployeeID = e.EmployeeID
LEFT JOIN  
	Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN  
	Projects p ON p.DepartmentID = e.DepartmentID
LEFT JOIN  
	Tasks t ON t.AssignedTo = e.EmployeeID
WHERE
	r.RoleName = 'Менеджер'
  	AND
  	s.SubordinateCount > 0
GROUP BY
    e.EmployeeID,
    e.Name,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    s.SubordinateCount
ORDER BY 
	e.Name;
