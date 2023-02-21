aws athena start-query-execution \
	--query-string 'DROP TABLE IF EXISTS alb_logs;' \
	--result-configuration "${results_config}" \
	--query-execution-context "${execution_context}"
