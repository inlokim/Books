<html>
<body>

<?

$book_id = $_REQUEST["book_id"];
$subject = $_REQUEST["subject"];
$writer = $_REQUEST["writer"];
$score = $_REQUEST["score"];
$content = $_REQUEST["content"];


$site = "http://inlokim.com/wonli/";
$user="inlokimc_erphome";
$password="dnfl1213";
$database="inlokimc_erphome";


$connect = mysql_connect(localhost,$user,$password);
mysql_set_charset('utf8',$connect);

@mysql_select_db($database) or die( "Unable to select database");

$query="INSERT INTO Reviews (book_id, subject, writer, score, content, date)
VALUES ($book_id,'$subject','$writer',$score,'$content', current_date())";

print $query;

//echo phpversion();

mysql_query(addslashes($query), $connect);
mysql_close();

?>

</body>
</html>