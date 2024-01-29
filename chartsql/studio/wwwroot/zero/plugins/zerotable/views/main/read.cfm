<!DOCTYPE html>
<html lang='en'>
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


  <link href='/assets/vendor/nprogress-master/nprogress.css' rel='stylesheet' />  
  <!--- <script src="https://code.jquery.com/jquery-1.11.2.min.js"></script> --->
  <script src='/assets/vendor/nprogress-master/nprogress.js'></script>

  </head>

<body style='display: none'>
  <header class='page-header'>
    <span class='nprogress-logo fade out'></span>
    <h1>NProgress<i>.js</i></h1>
    <p class='fade out brief big'>A nanoscopic progress bar. Featuring realistic
    trickle animations to convince your users that something is happening!</p>
  </header>

  <div class='contents fade out'>
    <div class='controls'>
      <p>
        <button class='button play' id='b-0'></button>
        <i>NProgress</i><b>.start()</b>
        &mdash;
        shows the progress bar
      </p>
      <p>
        <button class='button play' id='b-40'></button>
        <i>NProgress</i><b>.set(0.4)</b>
        &mdash;
        sets a percentage
      </p>
      <p>
        <button class='button play' id='b-inc'></button>
        <i>NProgress</i><b>.inc()</b>
        &mdash;
        increments by a little
      </p>
      <p>
        <button class='button play' id='b-100'></button>
        <i>NProgress</i><b>.done()</b>
        &mdash;
        completes the progress
      </p>
    </div>
    <div class='actions'>
      <a href='https://github.com/rstacruz/nprogress' class='button primary big'>
        Download
        v<span class='version'></span>
      </a>
      <p class='brief'>Perfect for Turbolinks, Pjax, and other Ajax-heavy apps.</p>
    </div>
    <div class='hr-rule'></div>
    <div class='share-buttons'>
      <iframe src="http://ghbtns.com/github-btn.html?user=rstacruz&repo=nprogress&type=watch&count=true"
          allowtransparency="true" frameborder="0" scrolling="0" width="100" height="20"></iframe>
      <iframe src="http://ghbtns.com/github-btn.html?user=rstacruz&type=follow&count=true"
          allowtransparency="true" frameborder="0" scrolling="0" width="175" height="20"></iframe>
      <a href="https://news.ycombinator.com/submit" class="hn-button" data-title="NProgress" data-url="http://ricostacruz.com/nprogress/" data-count="horizontal" data-style="twitter">HN</a>
    </div>
  </div>

  <script>
    $('body').show();
    $('.version').text(NProgress.version);
    NProgress.start();
    setTimeout(function() { NProgress.done(); $('.fade').removeClass('out'); }, 1000);
    $("#b-0").click(function() { NProgress.start(); });
    $("#b-40").click(function() { NProgress.set(0.4); });
    $("#b-inc").click(function() { NProgress.inc(); });
    $("#b-100").click(function() { NProgress.done(); });
  </script>

  <script>var HN=[];HN.factory=function(e){return function(){HN.push([e].concat(Array.prototype.slice.call(arguments,0)))};},HN.on=HN.factory("on"),HN.once=HN.factory("once"),HN.off=HN.factory("off"),HN.emit=HN.factory("emit"),HN.load=function(){var e="hn-button.js";if(document.getElementById(e))return;var t=document.createElement("script");t.id=e,t.src="//hn-button.herokuapp.com/hn-button.js";var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(t,n)},HN.load();</script>
</body>
</html>
<!--- <cfset request.layout = false> --->