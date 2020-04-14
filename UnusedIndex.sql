SELECT
  CASE
    WHEN CHARINDEX('$', o.name) > 1 THEN SUBSTRING(o.name, 1, CHARINDEX('$', o.name) - 1)
    ELSE ''
  END AS [Company],
  CASE
    WHEN CHARINDEX('$', o.name) > 1 THEN SUBSTRING(o.name, CHARINDEX('$', o.name) + 1, 1000)
    ELSE o.name
  END AS [Name],
  i.name AS [Index],
  i.index_id AS [Index ID],
  (user_seeks + user_scans + user_lookups) AS [Reads],
  user_updates AS [Writes],
  (
    SELECT
      SUM(p.rows)
    FROM
      sys.partitions p
    WHERE
      p.index_id = s.index_id
      AND s.object_id = p.object_id
  ) AS [Rows],
  REPLACE(
    CASE
      WHEN s.user_updates < 1 THEN 100
      ELSE 1.00 * (s.user_seeks + s.user_scans + s.user_lookups) / s.user_updates
    END,
    '.',
    ','
  ) AS [Reads per Writes]
FROM
  sys.dm_db_index_usage_stats s
  INNER JOIN sys.indexes i ON i.index_id = s.index_id
  AND s.object_id = i.object_id
  INNER JOIN sys.objects o on s.object_id = o.object_id
  INNER JOIN sys.schemas c on o.schema_id = c.schema_id
WHERE
  OBJECTPROPERTY(s.object_id, 'IsUserTable') = 1
  and CASE
    WHEN CHARINDEX('$', o.name) > 1 THEN SUBSTRING(o.name, CHARINDEX('$', o.name) + 1, 1000)
    ELSE o.name
  END like '%item led%'
  AND s.database_id = DB_ID()
  AND i.type_desc = 'nonclustered'
  AND i.is_primary_key = 0
  AND i.is_unique_constraint = 0
  AND (
    SELECT
      SUM(p.rows)
    FROM
      sys.partitions p
    WHERE
      p.index_id = s.index_id
      AND s.object_id = p.object_id
  ) > 10000
ORDER BY
  [Reads],
  [Writes] DESC