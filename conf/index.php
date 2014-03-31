<!doctype html>
<html>
<head>
    <title><?php echo $_SERVER['HTTP_HOST']; ?> Vhost - <?php echo gethostname(); ?></title>
</head>
<body>
<h1><?php echo $_SERVER['HTTP_HOST']; ?></h1>
<h2>Hello world</h2>
<p>Server: <?php echo gethostname(); ?></p>
</body>
</html>
