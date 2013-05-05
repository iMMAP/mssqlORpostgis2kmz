mssqlORpostgis2kmz
==================
mssql demo:   
http://54.243.146.241/google/googleKMZ.html?dbtype=mssql&dbname=OasisDB-Syria&schema=dbo&viewname=testKML2   

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

    Test using:

      SELECT 
       WKB.STAsText() as WKT, 
       [dbo].[ConvertWKT2KML](WKB.STAsText()) AS KML
       FROM [databasename].[dbo].[tablename]

Requires web server running PHP and a postgis server.  

For Apache, add these lines to the httpd.conf file:
- AddType application/vnd.google-earth.kml+xml .kml
- AddType application/vnd.google-earth.kmz .kmz

For IIS - please Google it!  

This solution requires you create views of the format:

    postgis:
    CREATE OR REPLACE VIEW public."vIrishCounties" AS 
     SELECT st_askml(irl_adm1.geom) AS geom, irl_adm1.name_1 AS name, irl_adm1.type_1 AS "desc"
       FROM irl_adm1;

    mssql:
    SELECT   dbo.ConvertWKT2KML(WKB.STAsText()) AS geom, AdminLev_3 AS name, AdminLev_2 AS [desc]
    FROM     dbo.dd_Demographics_ddAdmin3_FEA
    ORDER BY name

Also note you need to set write permissions (chmod 777) to allow the temp file to be created and deleted

