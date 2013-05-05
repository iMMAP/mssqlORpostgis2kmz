--DROP FUNCTION dbo.GetColourRampVal

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
go
CREATE FUNCTION dbo.GetColourRampVal
(
  @begin_hex char(6),
	@end_hex char(6),
	@percent float
)
RETURNS char(8)
AS
BEGIN

	declare @begin_R as int
	declare @begin_G as int
	declare @begin_B as int
	declare @end_R as int
	declare @end_G as int
	declare @end_B as int
	declare @new_R as int
	declare @new_G as int
	declare @new_B as int
	declare @new_hex as char(8)

	if @percent is NULL 
		set @percent = 0

	set @begin_R = 16 * (CHARINDEX(SUBSTRING(@begin_hex, 1, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@begin_hex, 2, 1), '0123456789abcdef') - 1)
    set @begin_G = 16 * (CHARINDEX(SUBSTRING(@begin_hex, 3, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@begin_hex, 4, 1), '0123456789abcdef') - 1)
    set @begin_B = 16 * (CHARINDEX(SUBSTRING(@begin_hex, 5, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@begin_hex, 6, 1), '0123456789abcdef') - 1)

	set @end_R = 16 * (CHARINDEX(SUBSTRING(@end_hex, 1, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@end_hex, 2, 1), '0123456789abcdef') - 1)
    set @end_G = 16 * (CHARINDEX(SUBSTRING(@end_hex, 3, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@end_hex, 4, 1), '0123456789abcdef') - 1)
    set @end_B = 16 * (CHARINDEX(SUBSTRING(@end_hex, 5, 1), '0123456789abcdef') - 1) + (CHARINDEX(SUBSTRING(@end_hex, 6, 1), '0123456789abcdef') - 1)

	set @new_R = @begin_R + (@percent * (@end_R - @begin_R));
	set @new_B = @begin_G + (@percent * (@end_G - @begin_G));
	set @new_G = @begin_B + (@percent * (@end_B - @begin_B));
	
	return '88' + right(master.dbo.fn_varbintohexstr(CAST(@new_B AS varbinary)),2)
	+right(master.dbo.fn_varbintohexstr(CAST(@new_G AS varbinary)),2)
	+right(master.dbo.fn_varbintohexstr(CAST(@new_R AS varbinary)),2)

END 
GO
