#!/bin/sh
if [ ! $# -eq 4 ] ; then
	echo "Error datos de Servidor FTP: Ejemplo: usuario_bd/clave_bd reclamos_correos.sh host user clave"
	exit 0
fi
nom_host=$2	#nom_host
cod_usua=$3	#Usuario
cod_pass=$4	#Password
sqlplus -s  $1 <<EOF
SET LINESIZE 200
SET PAGESIZE 100
set HEADING OFF
set FEEDBACK OFF
SET SERVEROUTPUT ON
column dcol new_value mydate noprint;
select to_char(sysdate,'YYYYMMDD') dcol from dual;
spool $HOME/facturacion/txt/reclamos_correos&mydate..txt; 

declare
  cursor cur is  
SELECT a.num_identclie, d.nom_cliente, (f.nom_calle || ' - ' || f.num_calle) AS DIRECCION, i.des_comuna, g.des_region, SYSDATE AS SYSDATE1, a.fec_reclamo, '' as ESPACIO1 , e.num_terminal, a.num_reclamo, a.tip_reclamo, b.email, c.des_valor, DECODE(a.cod_solucion, NULL, 'INGRESO', j.des_solucion) as notificacion, '' as espacio2, b.cod_reg_notif, 0 as cod_det_reg_notif, a.cod_estado, a.cod_solucion, USER, SYSDATE as Sysdate2
FROM re_reclamos a, re_notif_reclamos_to b, 
        (SELECT cod_valor, des_valor FROM ged_codigos WHERE cod_modulo = 'AC' AND nom_tabla = 
'CA_TIPINCIDENCIAS' AND nom_columna = 'MEDIORESP') c,
        ge_clientes d, re_terminales e, ge_direcciones f, ge_regiones g, ge_ciudades h, ge_comunas i, 
re_respuesta j
WHERE a.num_reclamo = b.num_reclamo AND
           a.tip_categoria = b.tip_categoria AND
           a.num_identclie = d.num_ident AND
           a.cod_cliente = d.cod_cliente AND
           a.num_reclamo = e.num_reclamo AND
           a.tip_categoria = e.tip_categoria AND 
           a.tip_categoria = 'S'  AND
           a.cod_solucion = j.cod_solucion(+) AND
           a.cod_solucion IS NOT NULL AND
           b.cod_reg_notif NOT IN (SELECT cod_reg_notif FROM re_det_notif_reclamos_to WHERE cod_reg_notif = b.cod_reg_notif AND cod_solucion = a.cod_solucion) AND
           b.tip_notif = c.cod_valor AND
           b.cod_direccion = f.cod_direccion AND
           f.cod_region = g.cod_region AND
           f.cod_region = h.cod_region AND
           f.cod_provincia = h.cod_provincia AND
           f.cod_ciudad = h.cod_ciudad AND
           f.cod_region = i.cod_region AND
           f.cod_provincia = i.cod_provincia AND
           f.cod_comuna = i.cod_comuna AND
           b.tip_notif = 1 AND
           exists (select 1 from re_carta_notif_td k 
                   where k.cod_solucion =  a.cod_solucion);
begin
for v_reg in cur loop  
 dbms_output.put_line ( v_reg.num_identclie ||','|| v_reg.nom_cliente ||','||v_reg.DIRECCION ||','||v_reg.DES_COMUNA ||','||v_reg.DES_REGION||','||to_CHAR(v_reg.SYSDATE1,'DD-MM-YYYY HH24:MI:SS')||','||to_CHAR(v_reg.FEC_RECLAMO,'DD-MM-YYYY HH24:MI:SS')||','||v_reg.ESPACIO1 ||','||v_reg.NUM_TERMINAL ||','||v_reg.NUM_RECLAMO||','||v_reg.TIP_RECLAMO||','||v_reg.EMAIL ||','||v_reg.DES_VALOR||','||v_reg.NOTIFICACION||','||v_reg.ESPACIO2||'');
if (v_reg.cod_det_reg_notif='0')then 
    INSERT INTO re_det_notif_reclamos_to (cod_det_reg_notif, cod_reg_notif, cod_estado, cod_solucion, usu_ultmod, fec_impres)
    VALUES (re_det_notif_reclamos_to_sq.NEXTVAL,v_reg.cod_reg_notif, v_reg.cod_estado, v_reg.cod_solucion,v_reg.user,v_reg.SYSDATE2); 
end if; 
  end loop;
end;
/ 
commit;
spool off


set TERM ON
set ECHO ON
SET autoprint ON
column dcol2 new_value mydate2 noprint;
select to_char(sysdate,'YYYYMMDD') dcol2 from dual;
spool  $HOME/facturacion/log/reclamos_correo&mydate2..log append
select to_CHAR(sysdate,'DD-MM-YYYY HH24:MI:SS') from dual;
declare 
VCOUNT INTEGER:= 0;	  
begin
SELECT COUNT(*) INTO VCOUNT
FROM (
SELECT a.num_identclie, d.nom_cliente, (f.nom_calle || ' - ' || f.num_calle ) AS DIRECCION, i.des_comuna, g.des_region, SYSDATE AS SYSDATE1, a.fec_reclamo, '' as ESPACIO1 , e.num_terminal, a.num_reclamo, a.tip_reclamo, b.email, c.des_valor, DECODE(a.cod_solucion, NULL, 'INGRESO', j.des_solucion) as notificacion, '' as espacio2, b.cod_reg_notif, 0 as cod_det_reg_notif, a.cod_estado, a.cod_solucion, USER, SYSDATE as Sysdate2
FROM re_reclamos a, re_notif_reclamos_to b, 
        (SELECT cod_valor, des_valor FROM ged_codigos WHERE cod_modulo = 'AC' AND nom_tabla = 
'CA_TIPINCIDENCIAS' AND nom_columna = 'MEDIORESP') c,
        ge_clientes d, re_terminales e, ge_direcciones f, ge_regiones g, ge_ciudades h, ge_comunas i, 
re_respuesta j
WHERE a.num_reclamo = b.num_reclamo AND
           a.tip_categoria = b.tip_categoria AND
           a.num_identclie = d.num_ident AND
           a.cod_cliente = d.cod_cliente AND
           a.num_reclamo = e.num_reclamo AND
           a.tip_categoria = e.tip_categoria AND 
           a.tip_categoria = 'S'  AND
           a.cod_solucion = j.cod_solucion(+) AND
           a.cod_solucion IS NOT NULL AND
           b.cod_reg_notif NOT IN (SELECT cod_reg_notif FROM re_det_notif_reclamos_to WHERE cod_reg_notif = b.cod_reg_notif AND cod_solucion = a.cod_solucion) AND
           b.tip_notif = c.cod_valor AND
           b.cod_direccion = f.cod_direccion AND
           f.cod_region = g.cod_region AND
           f.cod_region = h.cod_region AND
           f.cod_provincia = h.cod_provincia AND
           f.cod_ciudad = h.cod_ciudad AND
           f.cod_region = i.cod_region AND
           f.cod_provincia = i.cod_provincia AND
           f.cod_comuna = i.cod_comuna AND
           b.tip_notif = 1 AND
           exists (select 1 from re_carta_notif_td k 
                   where k.cod_solucion =  a.cod_solucion)
 );		   
IF (VCOUNT=0) THEN
dbms_output.put_line ('creacion archivo finalizado con exito');
ELSE 
dbms_output.put_line ('HA OCURRIDO UN PROBLEMA EN LA EJECUCION');
END IF;
end;
/
spool off
EOF
FILE=`sqlplus -s '/' << EOF
set serveroutput on
set feedback off
set head off
select 'reclamos_correos'||to_char(sysdate,'YYYYMMDD')||'.txt' from dual;
exit;
EOF`
cd $HOME/facturacion/txt/
FILE=`echo $FILE`
echo "+-----------------------------------------------------------------------+"
echo "                       PROCESO DE TASPASO FTP                           " 
echo "+-----------------------------------------------------------------------+"
echo " Host         :["$nom_host"]"
echo " Usuario      :["$cod_usua"]"
echo " Password     :["$cod_pass"]"
echo " Archivo      :["$FILE"]"
ftp -n $nom_host <<END_SCRIPT
quote USER $cod_usua
quote PASS $cod_pass
put $FILE
quit
cd -
echo 'Archivo '$FILE' Enviado a '$nom_host' Con exito'
END_SCRIPT
exit;
