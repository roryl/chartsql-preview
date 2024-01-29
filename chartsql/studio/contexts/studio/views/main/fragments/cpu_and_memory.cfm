<div class=" me-3" style="width:125px; font-size:.7rem; padding:1px;">
	<div class="progressbg p-0 ps-1">
		<div class="progress progressbg-progress" style="opacity:.8;">
			<div class="progress-bar bg-primary-lt" style=" width: {{data.keyPerformanceInfo.cpuLoad}}%" role="progressbar" aria-valuenow="35" aria-valuemin="0" aria-valuemax="100" aria-label="35% Complete">
				<span class="visually-hidden"></span>
			</div>
		</div>
		<div class="progressbg-text">CPU</div>
		<div class="progressbg-value">{{data.keyPerformanceInfo.cpuLoad}}%</div>
	</div>
</div>
<div class="" style="width:125px; font-size:.7rem; padding:1px;">
	<div class="progressbg p-0 ps-1">
		<div class="progress progressbg-progress" style="opacity:.8;">
			<div class="progress-bar bg-primary-lt" style=" width: {{data.keyPerformanceInfo.memoryPercent}}%" role="progressbar" aria-valuenow="35" aria-valuemin="0" aria-valuemax="100" aria-label="35% Complete">
				<span class="visually-hidden"></span>
			</div>
		</div>
		<div class="progressbg-text">MEM</div>
		<div class="progressbg-value">{{data.keyPerformanceInfo.maxMemoryUseEver}}mb</div>
	</div>
</div>