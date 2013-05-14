-- Function: public.getcolourrampval(character, character, integer)

-- DROP FUNCTION public.getcolourrampval(character, character, integer);

CREATE OR REPLACE FUNCTION public.getcolourrampval(end_hex text, begin_hex text, percent integer)
  RETURNS text AS
$BODY$

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
	new_Rtext text;
	new_Gtext text;
	new_Btext text;
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

	new_hex = '7f'::text;
	new_Rtext = to_hex( new_R )::text;
	new_Gtext = to_hex( new_G )::text;
	new_Btext = to_hex( new_B )::text;

	if (length(new_Rtext) = 1) then  new_Rtext = '0'::text  || new_Rtext; end if;
	if (length(new_Gtext) = 1) then  new_Gtext = '0'::text  || new_Gtext; end if;
	if (length(new_Btext) = 1) then  new_Btext = '0'::text  || new_Btext; end if;

	RETURN new_hex || new_Btext || new_Gtext || new_Rtext;
	
  END;
  
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.getcolourrampval(text, text, integer)
  OWNER TO postgres;
