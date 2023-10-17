# Buildkite Multi-step Upload Bug

Steps to reproduce:
- Checkout this repository `git clone git@github.com:mitchbne/buildkite-multistep-upload.git && cd buildkite-multistep-upload && echo $PWD`
- Note the output of `echo $PWD`, you'll need it in the very next step.
- Create a pipeline in Buildkite with the following configuration:
  - Repository: `<echo $PWD>.git`
  - Steps:
    ```yaml
    steps:
      - command: "ruby massive_pipeline_creator.rb"
    ```
- Trigger a build in Builkdite
- Run an agent locally using `buildkite-agent start --token $AGENT_TOKEN` (you can create an agent token https://buildkite.com/organizations/~/unclustered/agent_tokens/new)

Result:
```
$ buildkite-agent pipeline upload pipeline.chunk-0.yml
2023-10-17 13:30:26 INFO   Reading pipeline config from "pipeline.chunk-0.yml"
2023-10-17 13:30:26 INFO   Updating BUILDKITE_COMMIT to "40a4daad38aa119d04e362d3de5b6be995a9d7ae"
2023-10-17 13:30:28 WARN   Pipeline upload not yet applied: processing (Attempt 1/60 Retrying in 5s)
2023-10-17 13:30:33 WARN   Pipeline upload not yet applied: processing (Attempt 2/60 Retrying in 5s)
2023-10-17 13:30:39 WARN   Pipeline upload not yet applied: processing (Attempt 3/60 Retrying in 5s)
2023-10-17 13:30:44 WARN   Pipeline upload not yet applied: processing (Attempt 4/60 Retrying in 5s)
2023-10-17 13:30:49 INFO   Successfully uploaded and parsed pipeline config

$ buildkite-agent pipeline upload pipeline.chunk-1.yml
2023-10-17 13:30:49 INFO   Reading pipeline config from "pipeline.chunk-1.yml"
2023-10-17 13:30:49 INFO   Updating BUILDKITE_COMMIT to "40a4daad38aa119d04e362d3de5b6be995a9d7ae"
2023-10-17 13:30:52 WARN   Pipeline upload not yet applied: processing (Attempt 1/60 Retrying in 5s)
2023-10-17 13:30:57 WARN   Pipeline upload not yet applied: processing (Attempt 2/60 Retrying in 5s)
2023-10-17 13:31:02 WARN   Pipeline upload not yet applied: processing (Attempt 3/60 Retrying in 5s)
2023-10-17 13:31:07 WARN   Pipeline upload not yet applied: processing (Attempt 4/60 Retrying in 5s)
...
2023-10-17 13:35:46 WARN   Pipeline upload not yet applied: processing (Attempt 57/60 Retrying in 5s)
2023-10-17 13:35:51 WARN   Pipeline upload not yet applied: processing (Attempt 58/60 Retrying in 5s)
2023-10-17 13:35:57 WARN   Pipeline upload not yet applied: processing (Attempt 59/60 Retrying in 5s)
2023-10-17 13:36:02 WARN   Pipeline upload not yet applied: processing (Attempt 60/60)
fatal: Failed to upload and process pipeline: Pipeline upload not yet applied: processing
massive_pipeline_creator.rb:46:in `system!': ["buildkite-agent", "pipeline", "upload", "pipeline.chunk-1.yml"] command failed: pid 39070 exit 1 (RuntimeError)
	from massive_pipeline_creator.rb:39:in `block in create'
	from massive_pipeline_creator.rb:24:in `each'
	from massive_pipeline_creator.rb:24:in `each_slice'
	from massive_pipeline_creator.rb:24:in `with_index'
	from massive_pipeline_creator.rb:24:in `create'
	from massive_pipeline_creator.rb:9:in `create'
	from massive_pipeline_creator.rb:51:in `<main>'
🚨 Error: The command exited with status 1
user command error: exit status 1
```
