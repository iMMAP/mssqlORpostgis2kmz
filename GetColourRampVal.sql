--DROP FUNCTION dbo.GetColourRampVal

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION dbo.GetColourRampVal
(
	@end_hex char(6),
	@begin_hex char(6),
	@percent bigint
)
RETURNS char(8)
AS
BEGIN

	declare @begin_R as bigint
	declare @begin_G as bigint
	declare @begin_B as bigint
	declare @end_R as bigint
	declare @end_G as bigint
	declare @end_B as bigint
	declare @new_R as bigint
	declare @new_G as bigint
	declare @new_B as bigint
	declare @new_hex as char(8)

	if @percent is NULL 
		set @percent = 0

	set @begin_R = 16 * (CHARINDEX(SUBSTRING(@begin_hex, 1, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@begin_hex, 2, 1), '0123456789abcdef') - 1) 
    	set @begin_G = 16 * (CHARINDEX(SUBSTRING(@begin_hex, 3, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@begin_hex, 4, 1), '0123456789abcdef') - 1)
    	set @begin_B = 16 * (CHARINDEX(SUBSTRING(@begin_hex, 5, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@begin_hex, 6, 1), '0123456789abcdef') - 1)

	set @end_R = 16 * (CHARINDEX(SUBSTRING(@end_hex, 1, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@end_hex, 2, 1), '0123456789abcdef') - 1)
    	set @end_G = 16 * (CHARINDEX(SUBSTRING(@end_hex, 3, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@end_hex, 4, 1), '0123456789abcdef') - 1)
    	set @end_B = 16 * (CHARINDEX(SUBSTRING(@end_hex, 5, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@end_hex, 6, 1), '0123456789abcdef') - 1) 

	set @new_R = @end_R + (@percent * (@begin_R - @end_R))
	set @new_G = @end_G + (@percent * (@begin_G - @end_G))
	set @new_B = @end_B + (@percent * (@begin_B - @end_B))
	
	return '7f' + right(master.dbo.fn_varbintohexstr(CAST(@new_B AS varbinary)),2)
	+right(master.dbo.fn_varbintohexstr(CAST(@new_G AS varbinary)),2)
	+right(master.dbo.fn_varbintohexstr(CAST(@new_R AS varbinary)),2)
	
END 
GO
