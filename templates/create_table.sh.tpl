aws athena start-query-execution \
	--query-string "${query_string}" \
	--result-configuration "${results_config}" \
	--query-execution-context "${execution_context}"
