<?php

	header('Content-Type: application/vnd.google-earth.kmz');

	$dbtype = trim($_GET['dbtype']);
	$dbname = $_GET['dbname'];
	$schema = $_GET['schema'];
	$viewname = $_GET['viewname'];
	$filename = date('ymdhis') . '.kmz';
	$filedata = '<?xml version="1.0" encoding="UTF-8"?>
	<kml xmlns="http://earth.google.com/kml/2.2">
	<Document>

	';
	
	if ($dbtype == 'mssql') {
		
		include 'connect_mssql.php';
		$db_conn = mssql_connect($server,$user,$pass, true)
		or die("Couldn't connect to SQL Server"); 
	
		$query = 'SELECT * FROM [' . $dbname . '].[' . $schema . '].[' . $viewname . '];';
		
		$result1 = mssql_query($query) or die(mssql_get_last_message());
		$numfields = mssql_num_fields($result1);

	}else if($dbtype == 'postgis') {
		
		include 'connect_postgis.php';
		$conn_string = 'host=' . $server .
					   ' port=' . $port .
					   ' dbname=' . $dbname .
					   ' user=' . $user .
					   ' password=' . $pass;
					   
		$db_conn = pg_connect($conn_string) or die(pg_last_error());
		
		$query = 'SELECT * FROM ' . $schema . '."' . $viewname . '";';
	
		$result1 = pg_query($query) or die(pg_last_error());
		$numfields = pg_numfields($result1);
	
	}
	
	while ($myrow = ($dbtype == 'mssql' ? mssql_fetch_row($result1) : pg_fetch_array($result1))) {

		$fieldnumber = 0;
		$colour = '';
		while ($fieldnumber < $numfields) {

			$fieldname = ($dbtype == 'mssql' ? mssql_field_name($result1, $fieldnumber) : pg_field_name($result1, $fieldnumber));
			
			if ($fieldname === 'geom') { $geom = $myrow[$fieldnumber]; }
			elseif ($fieldname === 'name') { $name = $myrow[$fieldnumber]; }
			elseif ($fieldname === 'desc') { $desc = $myrow[$fieldnumber]; }
			elseif ($fieldname === 'colour') { $colour = $myrow[$fieldnumber]; }
			
			$fieldnumber = $fieldnumber + 1;
		}
		
		if ($colour != '') {

			if (strpos($geom, '<Polygon>') > -1) {
				$styletext = '<Style><PolyStyle><color>' . $colour . '</color><colorMode>normal</colorMode><fill>1</fill><outline>1</outline></PolyStyle></Style>';
			}elseif (strpos($geom, '<LineString>') > -1) {
				$styletext = '<Style><LineStyle><color>' . $colour . '</color></LineStyle></Style>';
			}elseif (strpos($geom, '<Point>') > -1) {
				// nothing yet.....
				$styletext = '';
			}
		}
		
		if (substr($geom, -1) === '>'){ 

			$filedata = $filedata . '<Placemark><name>' . $name . '</name><description>' . $desc . '</description>' . $styletext . $geom . '</Placemark>
			
			';
			
		}else{
			//print 'clipped at [' . strlen($geom) . ']  '; 
		}
	}
	 
	$filedata = $filedata . '
		</Document>
	</kml>';
	
	$zip = new ZipArchive;
	$res = $zip->open($filename, ZipArchive::CREATE);
	if ($res === TRUE) {
		$zip->addFromString('source.kml', $filedata);
		$zip->close();
		echo file_get_contents($filename);
		unlink($filename);

	} else {
		echo 'failed';
	}
?>
