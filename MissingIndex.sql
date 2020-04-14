SELECT
        D.index_handle,
        [statement] AS full_object_name,
        unique_compiles,
        avg_user_impact,
        user_scans,
        user_seeks,
        column_name,
        column_usage,
        GS.last_user_seek
FROM
        sys.dm_db_missing_index_groups G
        JOIN sys.dm_db_missing_index_group_stats GS ON G.index_group_handle = GS.group_handle
        JOIN sys.dm_db_missing_index_details D ON G.index_handle = D.index_handle
        CROSS APPLY sys.dm_db_missing_index_columns (D.index_handle) DC
where
        column_usage <> 'INCLUDE'
ORDER BY
        GS.user_seeks DESC,
        D.index_handle,
        [statement];