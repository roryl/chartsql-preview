<li class="d-none">
	<input type="color" class="js-color-picker color-picker" value="#FDDB80">
	<input type="range" class="js-line-range" min="1" max="72" value="5">
</li>
<!---
	Setup the the PresentationMode script which currently allows the user
	to draw a canvas overlaying the chart.  --->
<script>
	ChartSQLStudio.presentationMode = new PresentationMode().init();
</script>