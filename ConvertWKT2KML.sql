--DROP FUNCTION dbo.ConvertWKT2KML
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Keith Doyle
-- Create date: 03-May-13
-- Description:	Converts WKT to KML
-- =============================================

CREATE FUNCTION dbo.ConvertWKT2KML
(
	@wkt nvarchar(MAX)
)
RETURNS nvarchar(MAX)
AS
BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------

	DECLARE @kml nvarchar(MAX)
	DECLARE @searchindex int
	DECLARE @foundindex int

IF RIGHT(@wkt, 1) = ')'
BEGIN	

	----------------------------------------------------
	-- MULTIPOLYGON 
	----------------------------------------------------
	IF LEFT(@wkt, 16) = 'MULTIPOLYGON (((' 
	BEGIN
		set @kml = RIGHT(@wkt, LEN(@wkt) - 16)
		set @kml = '<MultiGeometry><Polygon><outerBoundaryIs><LinearRing><coordinates>' + @kml
		set @kml = replace(@kml, ')),((', '</coordinates></LinearRing></???BoundaryIs></Polygon><Polygon><outerBoundaryIs><LinearRing><coordinates>')	
		set @kml = replace(@kml, '),(', '</coordinates></LinearRing></outerBoundaryIs></Polygon><Polygon><innerBoundaryIs><LinearRing><coordinates>')	
		set @kml = left(@kml, LEN(@kml) - 3)
		set @kml = @kml + '</coordinates></LinearRing></???BoundaryIs></Polygon></MultiGeometry>'

		set @searchindex = CHARINDEX('???',@kml)

		WHILE @searchindex > 1 
		BEGIN

			set @foundindex = @searchindex - CHARINDEX(REVERSE('BoundaryIs'), REVERSE(left(@kml, @searchindex))) 
			
			IF SUBSTRING(@kml, @foundindex - 13, 5) = 'inner'
				set @kml = STUFF(@kml, @searchindex, 3, 'inner')
			ELSE
				set @kml = STUFF(@kml, @searchindex, 3, 'outer')

			set @searchindex = CHARINDEX('???',@kml)

		END
	
	END

	----------------------------------------------------
	-- MULTILINESTRING
	----------------------------------------------------
	IF LEFT(@wkt, 18) = 'MULTILINESTRING ((' 
	BEGIN
		set @kml = RIGHT(@wkt, LEN(@wkt) - 18)
		set @kml = replace(@kml, '),(', '</coordinates></LineString><LineString><coordinates>')	
		set @kml = left(@kml, LEN(@kml) - 2)
		set @kml = '<MultiGeometry><LineString><coordinates>' + @kml
		set @kml = @kml + '</coordinates></LineString></MultiGeometry>'
	END

	----------------------------------------------------
	-- MULTIPOINT
	----------------------------------------------------
	IF LEFT(@wkt, 12) = 'MULTIPOINT (' 
	BEGIN
		set @kml = RIGHT(@wkt, LEN(@wkt) - 12)
		set @kml = replace(@kml, '), (', ', ')	
		set @kml = replace(@kml, ', ', '</coordinates></Point><Point><coordinates>')
		set @kml = replace(@kml, '((', ')')	
		set @kml = replace(@kml, '))', ')')	
		IF LEFT(@kml, 1) = '('
			set @kml = right(@kml, LEN(@kml) - 1)
		set @kml = left(@kml, LEN(@kml) - 1)
		set @kml = '<MultiGeometry><Point><coordinates>' + @kml
		set @kml = @kml + '</coordinates></Point></MultiGeometry>'
	END

	----------------------------------------------------
	-- POLYGON
	----------------------------------------------------
	IF (LEFT(@wkt, 10) = 'POLYGON ((' )
		BEGIN

			set @kml = @wkt

			IF CHARINDEX('),(',@kml) > 0  
				BEGIN
					set @kml = replace(@kml, '),(', '</coordinates></LinearRing></outerBoundaryIs></Polygon><Polygon><innerBoundaryIs><LinearRing><coordinates>')
					set @kml = RIGHT(@kml, LEN(@kml) - 10)
					set @kml = left(@kml, LEN(@kml) - 2)
					set @kml = '<Polygon><outerBoundaryIs><LinearRing><coordinates>' + @kml
					set @kml = @kml + '</coordinates></LinearRing></innerBoundaryIs></Polygon>'	
				END 
			ELSE
				BEGIN
					set @kml = RIGHT(@kml, LEN(@kml) - 10)
					set @kml = left(@kml, LEN(@kml) - 2)
					set @kml = '<Polygon><outerBoundaryIs><LinearRing><coordinates>' + @kml
					set @kml = @kml + '</coordinates></LinearRing></outerBoundaryIs></Polygon>'
				END
		END

	----------------------------------------------------
	-- POINT
	----------------------------------------------------
	IF LEFT(@wkt, 7) = 'POINT (' 
	BEGIN
		set @kml = RIGHT(@wkt, LEN(@wkt) - 7)
		set @kml = left(@kml, LEN(@kml) - 1)
		set @kml = '<Point><coordinates>' + @kml
		set @kml = @kml + '</coordinates></Point>'
	END

	----------------------------------------------------
	-- LINESTRING
	----------------------------------------------------
	IF LEFT(@wkt, 12) = 'LINESTRING (' 
	BEGIN
		set @kml = RIGHT(@wkt, LEN(@wkt) - 12)
		set @kml = left(@kml, LEN(@kml) - 1)
		set @kml = '<LineString><coordinates>' + @kml
		set @kml = @kml + '</coordinates></LineString>'
	END
	
	----------------------------------------------------
	-- CLEANUP
	----------------------------------------------------
	set @kml = replace(@kml, ' ', ',')
	set @kml = replace(@kml, ',,', ' ')

	--SELECT  @kml 
END
	-- Return the result of the function
	RETURN @kml

------------------------------------------------------------------------------------------------------------------------------------------------------------
END
GO

