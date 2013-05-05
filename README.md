mssqlORpostgis2kmz
==================
Converts mssql or postgis native spatial formats into KML, compresses and submits to Google Maps Api v3 via KMZ. 
This tool is designed to be simple to implement and once setup only requires that views on the database(s) 
are of a certain structure.  This tool will also allow styles to be applied to the output layer.  

mssql demo:   
http://54.243.146.241/google/googleKMZ.html?dbtype=mssql&dbname=OasisDB-Syria&schema=dbo&viewname=testKML2   
http://54.243.146.241/google/googleKMZ.html?dbtype=mssql&dbname=OasisDB-Atlantis&schema=dbo&viewname=testKMLStyles   

postgis demo:    
http://54.243.146.241/google/googleKMZ.html?dbtype=postgis&dbname=postgres&schema=public&viewname=vIrishCounties  
  
- MSSQL function which converts WKT format to KML.  
- PHP script which creates a KMZ file for download.  
- HTML document which renders the KMZ file on Google Maps.  
  
To setup MSSQL support on linux:

    just go here: http://davejamesmiller.com/blog/connecting-php-to-microsoft-sql-server-on-debianubuntu
    solid instructions - 
    
    Note if you are loosing polygons it might be due to the text size limitation in the provider.
    If so, you should increase your text size (I made mine x10 to 645120) in /etc/freetds/freetds.conf 

    Test the mssql function using:

      SELECT 
       WKB.STAsText() as WKT, 
       [dbo].[ConvertWKT2KML](WKB.STAsText()) AS KML
       FROM [databasename].[dbo].[tablename]

Requires web server running PHP and mssql and/or postgis server.  

For Apache, add these lines to the httpd.conf file:
- AddType application/vnd.google-earth.kml+xml .kml
- AddType application/vnd.google-earth.kmz .kmz

For IIS - please Google it!  

This solution requires you to create views of the format:

    postgis:
      CREATE OR REPLACE VIEW public."vIrishCounties" AS 
       SELECT st_askml(irl_adm1.geom) AS geom, irl_adm1.name_1 AS name, irl_adm1.type_1 AS "desc"
        FROM irl_adm1;

    mssql (coloring features based on value within a range):
      SELECT dbo.ConvertWKT2KML(WKB.STAsText()) AS geom, 
             District AS name, 
             'Households in 2012: ' + CAST(Households2012 AS nvarchar(100)) AS [desc], 
             dbo.GetColourRampVal('ff0000', '00ff00', Households2012 * 100 / 
                (SELECT MAX(Households2012) FROM dbo.dd_NfiDistributions_qryDistrict_WKB)) AS colour
      FROM dbo.dd_NfiDistributions_qryDistrict_WKB 
      WHERE (Households2012 IS NOT NULL)

Also note you need to set write permissions (chmod 777) to allow the temp file to be created and deleted

