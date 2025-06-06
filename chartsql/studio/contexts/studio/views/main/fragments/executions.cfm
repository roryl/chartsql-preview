<style>
	.executionsTable td {
		white-space: nowrap;
  	}
</style>
<table class="executionsTable table table-sm mb-0" style="">
	{{#each data.EditorSession.ExecutionRequests}}
	<tr>
		<td>
			<span class="
				ms-2
				status-dot
				{{#if IsSuccess}}
				status-success
				{{else if IsError}}
				status-red
				{{else if IsRunning}}
				status-dot-animated status-azure
				{{else if IsCancelled}}
				status-orange
				{{/if}}
			"></span>

		</td>
		<td class="px-3">
			<small>
				<span class="text-muted me-3">file</span>
			</small>
			<span class="
				badge
				{{#if IsSuccess}}
				bg-green-lt
				{{else if IsError}}
				bg-red-lt
				{{else if IsRunning}}
				bg-azure-lt
				{{else if IsCancelled}}
				bg-orange-lt
				{{/if}}
			">
				{{name}}
			</span>
		</td>
		<td class="px-3">
			<small>
				<span class="text-muted me-3">elapsed</span>
			</small>
			 <span class="
			 	badge
			 	{{#if IsSuccess}}
				bg-green-lt
				{{else if IsError}}
				bg-red-lt
				{{else if IsRunning}}
				bg-azure-lt
				{{else if IsCancelled}}
				bg-orange-lt
				{{/if}}
			">
				{{toString ExecutionTime}} ms</span>		</td>
		<td class="px-3">
			<small>
				<span class="text-muted me-3">record count</span>
			</small>
			 <span class="
			 	badge
			 	{{#if IsSuccess}}
				bg-green-lt
				{{else if IsError}}
				bg-red-lt
				{{else if IsRunning}}
				bg-azure-lt
				{{else if IsCancelled}}
				bg-orange-lt
				{{/if}}
			">
				{{#if RecordCount}}{{toString RecordCount}}{{else}}-{{/if}}
			 </span>
		</td>
		<td class="px-3">
			<small>
				<span class="text-muted me-3">run at</span>
			</small>
			 <span class="
			 	badge
			 	{{#if IsSuccess}}
				bg-green-lt
				{{else if IsError}}
				bg-red-lt
				{{else if IsRunning}}
				bg-azure-lt
				{{else if IsCancelled}}
				bg-orange-lt
				{{/if}}
			">
				{{dateFormat CompletedAt "hh:mm:ss"}}
			 </span>
		</td>
		<td class="px-3">
			<small>
				<span class="text-muted me-3">folder</span>
			</small>
			 <span class="
			 	badge
			 	{{#if IsSuccess}}
				bg-green-lt
				{{else if IsError}}
				bg-red-lt
				{{else if IsRunning}}
				bg-azure-lt
				{{else if IsCancelled}}
				bg-orange-lt
				{{/if}}
			">
				{{PackageFullName}}
			 </span>
		</td>
		<td class="px-3">
			<small>
				<span class="text-muted me-3">status</span>
			</small>

			{{#if IsSuccess}}
			<span class="badge bg-green-lt">finished</span>
			{{else if IsError}}
			<span class="badge bg-red-lt">error</span>
			{{else if IsRunning}}
			<span class="badge bg-azure-lt">Running</span>
			{{else if IsCancelled}}
			<span class="badge bg-orange-lt">Cancelled</span>
			{{/if}}
		</td>
	</tr>
	{{#if IsError}}
	<tr>
		<td colspan="7"><p class="text-warning" style="max-width:500px;">{{ErrorMessage}}</p></td>
	</tr>
	<!--- <tr>
		<td colspan="7">
			<pre>
				{{{ErrorStackTrace}}}
			</pre>
		</td>
	</tr> --->
	{{/if}}
	{{/each}}
</table>