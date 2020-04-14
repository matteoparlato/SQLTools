SELECT
    OBJECT_NAME(id) AS [Object Name],
    COUNT (id) AS [No. of Indexes]
FROM
    sysindexes
WHERE
    (name NOT LIKE '_WA_%')
    AND (id > 255)
GROUP BY
    id
ORDER BY
    [No. of Indexes] DESC,
    [Object Name]