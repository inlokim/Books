<html>
<body>

<?
$site = "http://inlokim.com/wonli/";
$user="inlokimc_erphome";
$password="dnfl1213";
$database="inlokimc_erphome";



$connect = mysql_connect(localhost,$user,$password);
@mysql_select_db($database) or die( "Unable to select database");

$query="update books set paid = paid +1 where id='$id'";

print $query;

mysql_query($query, $connect);
mysql_close();

?>

</body>
</html>