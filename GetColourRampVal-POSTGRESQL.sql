
CREATE OR REPLACE FUNCTION GetColourRampVal
	(	end_hex char(6),
		begin_hex char(6),
		percent int
	) RETURNS text AS $$

  DECLARE 
	begin_R int;
	begin_G int;
	begin_B int;
	end_R int;
	end_G int;
	end_B int;
	new_R int;
	new_G int;
	new_B int;
	new_hex text;
  BEGIN

	begin_R = 16 * (strpos('0123456789abcdef',SUBSTRING(begin_hex, 1, 1)) - 1) + (strpos('0123456789abcdef',SUBSTRING(begin_hex, 2, 1)) - 1);
	begin_G = 16 * (strpos('0123456789abcdef',SUBSTRING(begin_hex, 3, 1)) - 1) + (strpos('0123456789abcdef',SUBSTRING(begin_hex, 4, 1)) - 1);
	begin_B = 16 * (strpos('0123456789abcdef',SUBSTRING(begin_hex, 5, 1)) - 1) + (strpos('0123456789abcdef',SUBSTRING(begin_hex, 6, 1)) - 1);

	end_R = 16 * (strpos('0123456789abcdef',SUBSTRING(end_hex, 1, 1)) - 1) + (strpos('0123456789abcdef',SUBSTRING(end_hex, 2, 1)) - 1);
    	end_G = 16 * (strpos('0123456789abcdef',SUBSTRING(end_hex, 3, 1)) - 1) + (strpos('0123456789abcdef',SUBSTRING(end_hex, 4, 1)) - 1);
    	end_B = 16 * (strpos('0123456789abcdef',SUBSTRING(end_hex, 5, 1)) - 1) + (strpos('0123456789abcdef',SUBSTRING(end_hex, 6, 1)) - 1);

	new_R = begin_R + (percent * (end_R - begin_R))/100;
	new_G = begin_G + (percent * (end_G - begin_G))/100;
	new_B = begin_B + (percent * (end_B - begin_B))/100;

	RETURN '7f' || right(cast( to_hex( new_B ) as varchar( 20 ) ),2)
	|| right(cast( to_hex( new_G ) as varchar( 20 ) ),2)
	|| right(cast( to_hex( new_R ) as varchar( 20 ) ),2);
	
  END;
  
$$ LANGUAGE plpgsql;





 