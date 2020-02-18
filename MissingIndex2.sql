SELECT [statement] AS full_object_name,
       D.index_handle,
       user_seeks,
       COLUMN_NAME,
       avg_user_impact,
       GS.last_user_seek,
       unique_compiles,
       column_usage
FROM sys.dm_db_missing_index_groups G
JOIN sys.dm_db_missing_index_group_stats GS ON G.index_group_handle = GS.group_handle
JOIN sys.dm_db_missing_index_details D ON G.index_handle = D.index_handle CROSS APPLY sys.dm_db_missing_index_columns (D.index_handle) DC
WHERE column_usage<>'INCLUDE'
ORDER BY GS.user_seeks DESC,
         D.index_handle,
         [statement];
