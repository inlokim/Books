<?php

// THIS IS ABSOLUTELY ESSENTIAL - DO NOT FORGET TO SET THIS
@date_default_timezone_set("GMT");

$writer = new XMLWriter();
// Output directly to the user

$writer->openURI('php://output');
$writer->startDocument('1.0');

$writer->setIndent(4);

// declare it as an rss document
$writer->startElement('reviews');

/**************************************************************************************/
$site = "http://inlokim.com/wonli/";
$user="inlokimc_erphome";
$password="dnfl1213";
$database="inlokimc_erphome";

$connect = mysql_connect(localhost,$user,$password);
mysql_set_charset('utf8',$connect);

@mysql_select_db($database) or die( "Unable to select database");

//$query="select * from reviews where `book_id` = 54521 order by date";

$query="select * from Reviews order by date";


$result = mysql_query($query, $connect);
$num=mysql_numrows($result);

$array = array($num);
$i = 0;
while ($list = mysql_fetch_array($result)) {

$writer->startElement("review");
//----------------------------------------------------
//$writer->writeElement('ttl', '0');
$writer->writeElement('subject', $list[subject]);
$writer->writeElement('writer', $list[writer]);
$writer->writeElement('date', $list[date]);
$writer->writeElement('score', $list[score]);
$writer->writeElement('content', $list[content]);
$writer->writeElement('book_id', $list[book_id]);
//----------------------------------------------------
// End review
$writer->endElement();
}

// End reviews
$writer->endElement();

$writer->endDocument();

$writer->flush();
?>
