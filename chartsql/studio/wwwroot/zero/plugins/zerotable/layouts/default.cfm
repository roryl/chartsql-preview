<!DOCTYPE html>
<html lang="en">
	<head>
		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
		<meta name="description" content="">
		<meta name="author" content="">
		<link rel="icon" href="../../favicon.ico">

		<title>Framework Zero Progressive Enhangement Examples</title>

		<!-- Bootstrap core CSS -->
		<link href="/assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

		<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
		<link href="/assets/vendor/bootstrap/css/ie10-viewport-bug-workaround.css" rel="stylesheet">

		<!-- Custom styles for this template -->
		<link href="/assets/css/navbar-fixed-top.css" rel="stylesheet">

		<!-- Just for debugging purposes. Don't actually copy these 2 lines! -->
		<!--[if lt IE 9]><script src="/assets/vendor/bootstrap/js/ie8-responsive-file-warning.js"></script><![endif]-->
		<script src="/assets/vendor/bootstrap/js/ie-emulation-modes-warning.js"></script>

		<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">

		<!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
		<!--[if lt IE 9]>
		  <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
		  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
		<![endif]-->

		<!-- Bootstrap core JavaScript
		================================================== -->
		<!-- Placed at the end of the document so the pages load faster -->

		<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
		<script>window.jQuery || document.write('<script src="/assets/vendor/bootstrap/js/vendor/jquery.min.js"><\/script>')</script>
		<script src="/assets/vendor/bootstrap/js/bootstrap.min.js"></script>

		<script src="/assets/vendor/velocity-master/velocity.min.js"></script>
		<script src="/assets/vendor/velocity-master/velocity.ui.min.js"></script>

		<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
		<!--- <script src="/assets/vendor/bootstrap/js/ie10-viewport-bug-workaround.js"></script> --->
		<script src="/zero-js/zero-animate.js"></script>
	</head>
	<body>

	<!-- Fixed navbar -->
	<nav class="navbar navbar-default navbar-fixed-top">
		<div class="container">
		<div class="navbar-header">
			<button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
			<span class="sr-only">Toggle navigation</span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			</button>
			<a class="navbar-brand" href="#">Project name</a>
		</div>
		<div id="navbar" class="navbar-collapse collapse">
			<ul class="nav navbar-nav">
				<li class="active"><a href="#">Home</a></li>
				<li><a href="/customers">Customers</a></li>
				<li><a href="#contact">Contact</a></li>
				<li class="dropdown">
					<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Zero State<span class="caret"></span></a>
					<ul class="dropdown-menu">
					<li><a href="/submit_overload">submit_overload</a></li>
					<li><a href="#">Another action</a></li>
					<li><a href="#">Something else here</a></li>
					<li role="separator" class="divider"></li>
					<li class="dropdown-header">Nav header</li>
					<li><a href="#">Separated link</a></li>
					<li><a href="#">One more separated link</a></li>
					</ul>
				</li>
			</ul>
			<ul class="nav navbar-nav navbar-right">
			<li><a href="../navbar/">Default</a></li>
			<li><a href="../navbar-static-top/">Static top</a></li>
			<li class="active"><a href="./">Fixed top <span class="sr-only">(current)</span></a></li>
			</ul>
		</div><!--/.nav-collapse -->
		</div>
	</nav>

	<div class="container">
		<cfoutput>#body#</cfoutput>
	</div> <!-- /container -->


	<!-- Bootstrap core JavaScript
	================================================== -->
	<!-- Placed at the end of the document so the pages load faster -->
	<!--- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
	<script>window.jQuery || document.write('<script src="/assets/vendor/bootstrap/js/vendor/jquery.min.js"><\/script>')</script>
	<script src="/assets/vendor/bootstrap/js/bootstrap.min.js"></script> --->
	<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->


	<script src="/assets/vendor/bootstrap/js/ie10-viewport-bug-workaround.js"></script>
	<script src="/framework-zero/zero/zeroAjax.js"></script>
	<script>
		zeroInit();
	</script>


	<script type="text/javascript">
	// window.scrollTo(0,100);
	// alert('test');
	// Keeps scroll position on postbacks
	// http://codepen.io/patrickkahl/pen/KFmAb
	;(function($){
	  /**
	   * Store scroll position for and set it after reload
	   *
	   * @return {boolean} [loacalStorage is available]
	   */
	   $.fn.scrollPosReaload = function(){
	   	if (localStorage) {
	   		var posReader = localStorage["posStorage"];
	   		if (posReader) {
	   			$(window).scrollTop(posReader);
	   			localStorage.removeItem("posStorage");
	   		}
	   		$(this).click(function(e) {
	   			localStorage["posStorage"] = $(window).scrollTop();
	   		});

	   		return true;
	   	}

	   	return false;
	   }

	   /* ================================================== */

	   $(document).ready(function() {
	  	// alert('test');
	      // Feel free to set it for any element who trigger the reload
	      // $('select').scrollPosReaload();
	      $('body').scrollPosReaload();
	      // $('body').removeAttr('style');
	      // $('html').scrollPosReaload();

	      // $('##main').smoothState();

	      $(function () {
	      	$('[data-toggle="tooltip"]').tooltip();
	      	$('[data-toggle="dropdown"]').dropdown();
	      })

	  });

	 }(jQuery));


	</script>
	</body>
</html>
